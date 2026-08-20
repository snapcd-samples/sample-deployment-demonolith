# sample-deployment-demonolith

This sample shows the full journey from a monolithic OpenTofu root to a bootstrapped Snap CD project: one big state gets split into per-module states with [demonolith](https://github.com/schrieksoft/demonolith) (0.3.0 or newer), the split is proven to change nothing, and the new modules are then wired into Snap CD, which takes over the ordering and value-passing the monolith used to do implicitly.

This is the **remote-store flavour**: the monolith's state lives in a remote S3-compatible store — a MinIO container standing in for a real bucket — and its shared platform context is read live from external data sources. [`sample-deployment-demonolith-local`](../sample-deployment-demonolith-local) is the same monolith with plain local state, for running with no infrastructure at all. It is the migration-story counterpart to [`sample-deployment`](../sample-deployment), which builds the same vpc → cluster/database → app landscape from scratch. Everything here is a mock (`random`, `tls`, `time` providers, JSON-backed `http` data sources, an S3 API served from a local container) — no cloud account, no real credentials, nothing leaves your machine except two reads of public JSON.

## Stage 1 — the monolith

The root of this repo is the starting point: a single root module with everything in one state. It is deliberately shaped like a real monolith, with the knots that make splitting one non-trivial:

- **Remote state** — the monolith's own state sits in an S3-compatible store via the `s3` backend in `root.tf` (MinIO behind endpoint overrides; the `skip_*` settings are what point the backend at a non-AWS store). demonolith derives each new module's backend from that block: the key gets a per-module suffix (`my-states/sample.tfstate` → `my-states/sample-networking.tfstate`), so the whole migration stays inside the same bucket.
- **Local child modules** — `./modules/subnet` (called twice) and `./modules/dns-record`. A module call carries state, so each call has to land in exactly one of the new modules.
- **External modules from GitHub** — `module.database` and `module.cluster` are pulled straight from `github.com/snapcd-samples/...` (plain Terraform-style modules, *not* Snap CD modules).
- **Data sources read by many future modules** — `data.http.platform` (the platform registry's record for this deployment) feeds the networking, database, and app sections; `data.http.oncall` (the owning on-call team) feeds cluster and app. Data sources never carry a placement comment — they follow their consumers into every module that reads them — and they are read live on every plan, which is exactly why demonolith's prove and verify list them up front.
- **Shared variables and locals** — `var.name_prefix`, `local.name`, `local.network_zone` and friends are referenced across every future seam.
- **Cross-section references** — the database sits in the private subnet, the cluster references the vpc and both subnets, the app references the cluster, the database, the deploy key, and the network zone; `time_sleep.network_propagation` gates the cluster via `depends_on`.
- **Unclaimed odds and ends** — `random_uuid.audit_log_bucket_id` and `random_pet.backup_plan` belong to nobody; they end up in the catchall remainder (`legacy`).
- **Scattered inputs** — the values arrive the way a grown monolith's do, through every channel at once: three variables in `terraform.tfvars`, two as `TF_VAR_*` in the session environment (`.env`), one only ever passed as a `-var` flag, and the store's access/secret key as `-backend-config` flags at init. Every channel matters (no variable has a default), because reconstructing exactly this spread is the part of a migration people get subtly wrong.

The seams are already marked: every block that carries state has a `# @demono:move <module>` comment naming its target module (networking / database / cluster / app), except the ops odds and ends, which deliberately have none. One placement choice is worth reading: `tls_private_key.deploy_signer` lives with the app because its provider marks the PEM as sensitive, and a sensitive value must not cross a module boundary — demonolith's `LIMITATIONS.md` explains that constraint, and colocating the key with everything that reads it is the recommended handling.

Prerequisites: demonolith 0.3.0 or newer on the PATH, Docker, and OpenTofu. Then start the store and establish the baseline:

```bash
./step0_store.sh      # starts the simulated S3 store (MinIO, one container,
                      # docker-compose.yml) and creates the tfstate bucket
./step1_env.sh        # creates .env and terraform.tfvars from their committed
                      # .sample counterparts; edit them to change inputs
./step2_baseline.sh   # loads .env, inits with the -backend-config
                      # credentials, applies, and gates on a clean plan —
                      # state lands in the store, nothing real is deployed
```

Together these are the "pin the working session" step of a manual split, made executable. Steps 2 and 4 each load `.env` themselves, so every command runs in the same environment — which matters because demonolith deliberately captures neither provider environment nor `-var`-only values; it documents them as session prerequisites instead.

## The seams

The split mirrors `sample-deployment`'s landscape:

```
           |-----> cluster  ----- |
networking |                      | ---> app        (+ a catchall remainder, `legacy`)
           |-----> database ----- |
```

## The journey

1. **Decorate and split the code** — `./step3_refactor.sh` (`demonolith refactor -y --monorepo --engine tofu --overwrite`) runs map → run → validate → diff (`--overwrite` because the module directories from the last run are committed here — run owns them outright and deletes them before rewriting): the map (`demonolith-refactor-map.yaml`) records the whole split for review — including where every module's state will live in the store — `refactor run` executes it, `refactor validate` has the engine check that every written module directory is valid, and `refactor diff` is the CI gate that the committed output still matches the source. The new module directories land in `modules/` (the default), beside the reusable child modules — `--monorepo` makes them reference `./modules/subnet` and `./modules/dns-record` by relative path instead of receiving copies. The script sources nothing from `.env`: the validate step is credential-free (it contacts only the provider registry), and every other refactor step is offline and touches nothing but files.
2. **Migrate the state** — `./step4_migrate.sh` (`demonolith migrate --engine tofu -y --force --var database_port=5432`) runs map → prove → run → verify: pull the monolith's state read-only from the store, back it up, split it into local per-module copies, prove every new module plans to zero changes with producer outputs fed into consumer inputs, push each module's state into its derived bucket key (empty destinations only, never forced — the monolith's own state is never written), and verify the result against the real backends. The input spread is reconstructed on the way through: the store credentials step 2's init resolved flow into gitignored per-module `demono.env` files (as `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` — the s3 backend's own variables), and each module's resolved variable values (tfvars, `TF_VAR_*`, and the re-supplied `-var`) land in its `demono.root.tfvars` and `demono.graph.tfvars`.
3. **Bootstrap into Snap CD** — `refactor` already generated `modules/snapcd/`: a bootstrap module with one `snapcd_module` per module, the map's `cross_edges` realized as `snapcd_module_input_from_output` wirings, its `ordering_edges` as `snapcd_depends_on_module`, and the external inputs passed through as literals bound to the bootstrap's variables — plus, because the split is `--monorepo`, `default_trigger_path_filter_enabled = true` on the namespace, so each module only redeploys when a commit touches its own directory. Apply it (`tofu apply` in `modules/snapcd/` with `source_url` set to this repo), retire the monolith, and Snap CD passes the values between modules at runtime — the same passing the proofs performed locally.

## The same story in CI

[`.github/workflows/split.yml`](.github/workflows/split.yml) runs the journey as the three lanes a real team would use: `refactor diff` as the standing gate on every PR and push (offline, no credentials), a read-only migration rehearsal on every PR (`migrate map` + `migrate prove` — nothing pushed, so a rejected PR leaves the world untouched), and the migration itself only on a manual `workflow_dispatch` — the cutover is a deliberate, once-off action taken after the merge, not a side effect of CI. Because this sample has no persistent world, each job first builds its own: the simulated S3 store (`./step0_store.sh` — the same one command as locally, up in seconds) and the baseline apply. In a real repository those steps disappear and the `.env` values come from CI secrets.
