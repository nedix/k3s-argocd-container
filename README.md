# [k3s-argocd-container][project] a.k.a. k8sage

Kubernetes with Argo CD inside a container.
Can be used to test infrastructure code locally.


## Usage


### 1. Configure your Helm and Kustomize applications

```shell
wget -O applications.yaml https://github.com/nedix/k3s-argocd-container/applications.yaml.example
```


### 2. Start the container

```shell
docker run --rm --pull always --name k8sage \
    -v ${PWD}/applications:/etc/k8sage/repositories/argocd-example-apps/ \
    --mount="type=bind,source=${PWD}/applications.yaml,target=/etc/k8sage/repositories/config/applications.yaml" \
    nedix/k3s-argocd
```


### 3a. Access the Argo CD GUI

- Navigate to [http://127.0.0.1](http://127.0.0.1)
- Optionally sign in with `admin:admin` as the credentials


### 3b. Access the Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/root/.kube/config ${PWD}/kubeconfig.yaml
```


[project]: https://hub.docker.com/r/nedix/k3s-argocd
