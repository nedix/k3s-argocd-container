# [k3s-argocd-container][project] a.k.a. k8sage

Kubernetes with Argo CD inside a container.
Can be used to test infrastructure code locally.


## Usage


### 1. Configure the `applications.yaml` file

```shell
wget -O applications.yaml https://github.com/nedix/k3s-argocd-container/applications.yaml.example
```


### 2. Start the container

```shell
docker run --rm -d --name k8sage \
    --privileged \
    --cgroupns="host" \
    --mount="type=bind,source=${PWD}/applications.yaml,target=/etc/k8sage/repositories/config/applications.yaml" \
    -p 127.0.0.1:80:80 \
    -p 127.0.0.1:443:443 \
    -p 127.0.0.1:6443:6443 \
    nedix/k8sage
```


### 3a. Access Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/root/.kube/config "${PWD}/kubeconfig.yaml"
```

Connect to `127.0.0.1:6443` for access to the API


### 4. Access the Argo CD GUI

- Navigate to [http://127.0.0.1:80](http://127.0.0.1:80)
- Optionally sign in with `admin:admin` as the credentials


[project]: https://hub.docker.com/r/nedix/k8sage
