# Changelog

## v0.1.3

[changes]
- bump dependencies

## v0.1.2

[changes]
- bump version of `:openstex_adapters_ovh` to `0.3.5`
- Add `:openstex_adapters_ovh` to list of applications to avoid
mix release warnings.


## v0.1.1

[bugfix]
- Delete url when the scope is not passed. Before, failed due to absent scope.

[documentation]
- remove use of pseudofolder from documentation as it is
completely optional.


## v0.1.0

- Initial commit
- Consists of:
    - `ArcOvh.Client.Cloudstorage`, an OVH client
    - `ArcOvh.Application`, an Application to supervise the OVH client
    - `Arc.Storage.Ovh.Cloudstorage`, an adapter for storage for [arc](https://github.com/stavro/arc)
- Basic docs in readme