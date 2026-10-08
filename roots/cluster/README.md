# How to run

```
source demono.env
tofu init
tofu plan --var-file demono.root.tfvars --var-file demono.graph.tfvars
```

The demono.* files are written by the `demonolith migrate` pipeline.
