# [k8sage][project] a.k.a. k3s-argocd-container

Kubernetes with Argo CD using containers.
Enables running infrastructure code locally for developers.


## Usage


### 1. Configure the `applications.yaml` file

```shell
wget -O applications.yaml https://github.com/nedix/k3s-argocd-container/applications.yaml.example
```


### 2. Start the container

```shell
docker run \
    --cgroupns host \
    --mount "type=bind,source=${PWD}/applications.yaml,target=/etc/k8sage/repositories/config/applications.yaml" \
    --name k8sage \
    --privileged \
    --rm \
    -p 127.0.0.1:80:80 \
    -p 127.0.0.1:443:443 \
    -p 127.0.0.1:6443:6443 \
    nedix/k8sage
```


### 3. Access the Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/root/.kube/config "${PWD}/kubeconfig.yaml"
```

Connect to `127.0.0.1:6443` for access to the API


### 4. Access the Argo CD GUI

- Navigate to [http://127.0.0.1:80](http://127.0.0.1:80)
- Optionally sign in with `admin:admin` as the credentials


[project]: https://hub.docker.com/r/nedix/k8sage
