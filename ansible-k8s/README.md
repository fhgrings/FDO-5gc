# K8S Single Cluster spinup
This is a project willing to summarize some of the DevOps topics.
## Used Tools
The main idea was to use as much tools as I could:

 - Ansible
 - AWS
 - Kubernetes

## How does  it work?

- Ansible installs and configure Kubernetes over AWS env or local VMs env.

## The goal
The goal is just to setup a Kubernetes cluster within instances.

## Run Local
Update variables ansible-k8s-KEY.perm @ groups_vars/all.yaml
Run the script run-local.sh

## If nodes not connecting run

```bash
kubeadm join --token b0f7b8.8d1767876297d85c \
          --discovery-token-unsafe-skip-ca-verification \
          200.137.215.86:6443
```
