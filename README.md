## Crossplane Health Checks

**WARNING**: The unit testing framework does not support wildcards for the resource kind and type. Therefore, all the test cases were put into `argo-cd/resource_customizations/repositories.argocd.crossplane.io/Repository` and the header of the file set to
```yaml
apiVersion: repositories.argocd.crossplane.io/v1alpha1
kind: Repository
```
This was to allow the lua tests to see the resources under test instead of having multiple lua health-checks.

To run the tests for the crossplane resources:
```bash
cd util/lua
go test -v -run TestLuaHealthScript .
```
