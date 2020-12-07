#!/bin/bash
set -x

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

apt-get update
apt-get -y install git vim snapd screen docker.io build-essential golang jq libghc-yaml-dev openvpn yarn nodejs

snap install kubectl --classic

git clone https://github.com/gardener/gardener.git

git clone https://github.com/gardener/dashboard.git

cat << 'FIRST' > first.sh
#!/bin/bash
set -x

make local-garden-up

mkdir ~/.kube/
cp hack/local-development/local-garden/kubeconfigs/default-admin.conf ~/.kube/config

make dev-setup

kubectl create serviceaccount testuser

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name:  garden.sapcloud.io:dashboard:admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: testuser
  namespace: default
EOF

TOKEN=$(kubectl get secret $(kubectl get serviceaccount/testuser -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}'| base64 --decode)
echo $TOKEN | tee testuser-token
FIRST

cat > screenrc-gardener <<EOF
screen -t setup bash -x -c "( chmod a+x ../first.sh && ../first.sh ) 2>&1 | tee -a ../setup.txt"
screen -t apiserver bash -x -c "( sleep 30 && make start-apiserver ) 2>&1 | tee -a ../apiserver.txt"
screen -t controller-manager bash -x -c "( sleep 30 && make start-controller-manager ) 2>&1 | tee -a ../controller-manager.txt"
screen -t scheduler bash -x -c "( sleep 30 && make start-scheduler ) 2>&1 | tee -a ../scheduler.txt"
screen -t gardenlet bash -x -c "( sleep 30 && make start-gardenlet ) 2>&1 | tee -a ../gardenlet.txt"
EOF

pushd gardener
screen -mdS gardener -c ../screenrc-gardener
popd


cat > screenrc-dashboard <<EOF
screen -t backend bash -x -c "( sleep 60 && cd backend && mkdir -p ~/.gardener/ && cp lib/config/test.yaml ~/.gardener/config.yaml && yarn && yarn serve ) 2>&1 | tee -a ../backend.txt"
screen -t frontend bash -x -c "( sleep 120 && cd frontend && yarn && yarn serve ) 2>&1 | tee -a ../frontend.txt"
EOF

pushd dashboard
screen -mdS dashboard -c ../screenrc-dashboard
popd