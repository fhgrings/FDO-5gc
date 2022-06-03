

# 5G Core Auto Scale Network Slicing

 This project focus on observability to visualize core communication and implement Network Slicing in the future

Technological advances in the fifth-generation (5G) mobile networks are based on native cloud computing platforms and Kubernetes has emerged as the orchestration  ystem for virtualized infrastructure. However, these platforms were not designed to natively support 5G services. To illustrate, Kubernetes is designed to be agnostic to the services which orchestrates and is not able to dynamically reconfigure the 5G core according to existing network resources, i.e., it provides a partial dynamic orchestration to perform network slicing. This paper proposes is an easy to use infrastructure and monitoring implementation of the [free5GC](www.free5gc.org)+[open-free5gc-helm](https://github.com/fhgrings/open-free5gc-helm) project. Running on AWS or Proxmox environment using Terraform and Ansible as IaC.a solution integrated with Kubernetes to allow full dynamic  orchestration of network slicing at runtime, with neededs adjust in the 5G core. This integration is accomplished through a Kubernetes-integrated controller and   proxy for control plane. The controller adjusts the 5G core and adapts the virtualized infrastructure, while the proxy creates an abstraction for the  ontrol communication between access and transport networks with the core. The experimental results showed a reconfiguration based on total dynamic orchestration without interruption of the services provided, reducing the total reconfiguration requests number by network slices by 47.5%.


## Requirements

AWS Account **or** ProxMox Hypervisor

For one-step deploy Linux is required Or

Terraform;

Ansible.


## Architecture

High Level architecture is based in Proxmox Hypervisor (AWS compatible) using 3 virtual machines, 2 Kuberentes Worker and 1 Kubernetes Master. The projetct uses observability principles described on "Production-Ready Microsservices", by  O"Reilly. The project load metrics from hosts using Prometheus and send to grafana. The applications send tracing logs, and metrics via PinPoint Goland Agent to PinPoint APM. Jaeger was tested but the technology is not matture to easy-to-use on this project.

![](./imgs/proxmox-architecture.png)



The AWS architecture was designed to provide the entire AWS VPC and security resources. Terraform with AWS provider build the entire infrastructure that corresponds to:

* 1x Global VPC - Cloud network and security configurations;
* 2x Subnets (Public and Private) - Separate Master and Nodes Public access;
* 2x Routers (Public and Private) - Co ingress and outgress trafic;
* 1x Gateway to expose public Router to internet;
* 1x NAT to private Subnet;
* 2x Security Groups with same configuration to implements in the future port restrictions.

![](./imgs/aws-architecture.png)



Kubernetes cluster is configured by Ansible Playbook using Kubespray Project:

After Kubernetes installed these modules are required:

* GTP5G Kernel Module - For UPF tunneling communication;
* open-free5gc-helm from this repo;
* Prometheus (Optional);
* Nginx (Optional);

After configuring Free5GC Helm specifications you will get the following scenario:

![](./imgs/cluster-architecture.png)

![](./imgs/overview.png)

### Prototype
![](./imgs/prototype.png)

## Installation and Getting Started

To run you need to follow 3 steps
* Terraform
* Build k8s Cluster
* Install GTP5G Linux Kernel Module 
* Deploy 5G Core environment

In Terraform stage you can choose between AWS or Proxmox, so:

If you already have VMs ingore the first step.

## Infrastructure

#### Build AWS Infrastructure

Create AWS account

Define AWS Credentials (Access Keys)

```bash
cd terraform-prov-aws
./run.sh (Create Buckets for terraform Backend)
terraform init
terraform plan
terraform apply --auto-approve
```

#### Build Local VMs Infrastructure
[Docs](./terraform-vms-proxmox/README.md)

## Environment

### Prepare OS to 5G

Install [GTP5G Linux Kernel Module](https://github.com/free5gc/gtp5g) 

Install [Helm Project](https://helm.sh/docs/intro/install/)

### Build Kubernetes Environment

Install Kubernetes using [Kubespray Project](https://github.com/kubernetes-sigs/kubespray )

Before Install

* Update inventory group_vars to use Calico as default CNI 

### Install Free5gc Core

Connect on Kubernetes Master VM

```bash
git clone https://github.com/fhgrings/open-free5gc-helm
kubectl create namespace free5gc
kubectl config set-context --current --namespace=free5gc
helm install open -n free5gc open-free5gc-helm/
```


### Check Availability
```bash
kubectl get pods 
```
Check if all pods are running 

![](./imgs/cluster.png)



## Tests

#### Install my5G-RANTester

```bash
git clone https://github.com/my5G/my5g-RANTester-helm.git
kubectl apply -f my5g-RANTester-helm/5g-tester.yaml
```

Docs:

https://github.com/my5G/my5G-RANTester

#### SSH Tunneling (Optional)

```bash
ssh -L 5000:intra.example.com:5000 gw.example.com
```



## FAQ

Problem

Mongodb pending with message "1 node(s) had volume node affinity conflict"

Solution

Persistent volume with wrong domain refering. Recreate the PV with right destin values (Update on ./ansible-free5gc/k8s-master/tasks/main.yml @task-name[create free5gc pvc] values)

### Monitoring

For a better cluster overview I recommend to install Lens IDE and connect to Kubernetes Cluster:


![](./imgs/cluster-map.jpeg)


- [x] **PinPoint**
- [x] **Elastic APM**
- [x] ~~NewRelic~~ (Not Working - Go Agent needs Go 1.17+)
- [x] ~~OpenTelemtry~~ (No Agent for gin/gonic)
- [x] ~~Datadog~~ (No Agent for gin/gonic)


It was possible to group all the requests made in the applications, but without tracking the senders, only the receivers.

![](./imgs/pinpoint-service-map.png)





![](./imgs/pinpoint-tracing.png)

Refs:

https://opentelemetry.io/docs/instrumentation/go/getting-started/

https://github.com/pinpoint-apm/pinpoint-go-agent/tree/main/plugin/gin

https://pkg.go.dev/net/http

https://pkg.go.dev/golang.org/x/net/http2/h2c

https://github.com/free5gc/amf/blob/e857bcd091ec69e66a2d390345fb4faf5c5d89e2/consumer/nf_mangement.go (Class example: Nnrf_NFManagement)



## Refs

https://github.com/pinpoint-apm/pinpoint-go-agent/tree/main/plugin/gin

https://pkg.go.dev/net/http

https://pkg.go.dev/golang.org/x/net/http2/h2c

https://docs.aws.amazon.com/

https://www.free5gc.org/

https://github.com/ciromacedo/5GCore-easy-install

https://github.com/Orange-OpenSource/towards5gs-helm
