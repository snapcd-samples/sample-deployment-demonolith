# How to run

```
source demono.env
tofu init
export TF_VAR_source_url="git@github.com:snapcd-samples/sample-deployment-demonolith.git"
export TF_VAR_source_revision="refactored"
tofu apply --var-file demono.root.tfvars
```

The demono.* files are written by the `demonolith migrate` pipeline.
