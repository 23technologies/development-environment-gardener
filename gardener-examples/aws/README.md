This is not intended for full automation, but to understand and easily modify what is happening at which layer of your setup.

```
git clone https://github.com/gardener/etcd-backup-restore.git

kubectl apply -f dev/00-namespace-garden.yaml
helm install --namespace garden etcd ../etcd-backup-restore/chart/etcd-backup-restore --set tls=

helm install --namespace garden gardener charts/gardener/controlplane -f charts/gardener/controlplane/local-values.yaml -f dev/gardener-values.yaml

kubectl apply -f dev/05-project-dev.yaml 


kubectl apply -f https://raw.githubusercontent.com/gardener/gardener-extension-provider-aws/v1.19.0/example/controller-registration.yaml
kubectl apply -f https://raw.githubusercontent.com/gardener/gardener-extension-networking-calico/v1.14.0/example/controller-registration.yaml
kubectl apply -f https://raw.githubusercontent.com/gardener/external-dns-management/v0.7.21/examples/controller-registration.yaml
kubectl apply -f https://raw.githubusercontent.com/gardener/gardener-extension-os-coreos/v1.5.0/example/controller-registration.yaml
# kubectl apply -f https://raw.githubusercontent.com/gardener/gardener-extension-os-ubuntu/v1.9.0/example/controller-registration.yaml

cat dev/kops-gardendev.yaml | base64 -w 0  ## insert to 40-secret-seed.yaml

kubectl apply -f dev/30-cloudprofile.yaml
kubectl apply -f dev/40-secret-seed.yaml

# insert kubeconfig to gardenlet-values.yaml
helm install gardenlet charts/gardener/gardenlet --namespace garden -f dev/gardenlet-values.yaml

kubectl apply -f dev/50-seed.yaml

kubectl apply -f dev/70-secret-provider.yaml
kubectl apply -f dev/80-secretbinding.yaml
kubectl apply -f dev/90-shoot.yaml

kubectl -n garden-dev get secret test1-aws.kubeconfig -o json | jq -r .data.kubeconfig | base64 -d  
```