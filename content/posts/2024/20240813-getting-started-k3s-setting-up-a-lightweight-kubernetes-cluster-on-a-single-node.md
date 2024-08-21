---
draft: false
date: 2024-08-13T20:34:11-05:00
title: "Getting Started with K3s: Setting Up a Lightweight Kubernetes Cluster on a Single Node"
description: "A guide to setting up a lightweight Kubernetes cluster using K3s on a single bare-metal node in a resource-constrained environment, perfect for homelab experimentation"
slug: ""
tags:
  - homelab
  - K8s
  - K3s
categories:
  - How To
  - Blogging
externalLink: ""
series:
  - Running a Local Kubernetes Cluster
---

In my career as an SRE, I often needed a reliable way to experiment with Kubernetes (K8s), whether to test new configurations, explore features, or refine my skills. However, I didn’t want to spin up a full production-grade cluster just to run experiments. Instead, I wanted a lightweight Kubernetes setup that I could deploy locally on resource-constrained machines, while still allowing me to replicate the setup across different operating systems like Linux, macOS, and even Windows.

Setting up a local Kubernetes cluster in my homelab environment posed several challenges due to hardware limitations and the need for flexibility. After trying several options, I found that K3s provided the perfect balance between simplicity, portability, and resource efficiency.

This guide walks through the process of setting up a lightweight Kubernetes cluster using K3s on a single bare-metal node. Whether you’re an SRE looking to experiment with Kubernetes or a hobbyist building out a homelab, this setup will help you get started quickly without overwhelming your hardware.

> **Note**: This guide focuses on experimentation and learning. It is not intended for production workloads or high availability setups.

## Why K3s?

K3s emerged as the best solution for my needs due to its lightweight nature, minimal resource consumption, and flexibility. It's a CNCF-certified Kubernetes distribution backed by Rancher Labs, ensuring that the skills and configurations I develop will translate to more robust Kubernetes environments.

**Key Benefits of K3s**:

- **Lightweight**: Runs on resource-constrained machines.
- **Portability**: Works across Linux, MacOS, and Windows.
- **Simplicity**: Installed directly on the host, without heavy overhead.
- **Support**: Backed by Rancher Labs, a leader in Kubernetes management.
- **Multi-arch Support**: Works on various CPU architectures.

Before settling on K3s, I explored a few other alternatives. Below, I've listed them in the order I tried them. This is just to offer insight into my thought process and is not intended to be a comprehensive comparison. Feel free to skip to the [Installation](#installation) section.

### Docker Desktop

- **Pros**: Easy to install and integrate with existing Docker workflows; provides a smooth Kubernetes experience on desktop environments.
- **Cons**: Licensing restrictions introduced by Docker Inc. limited its use for work-related purposes; less suitable for environments requiring easy replication across multiple machines.

### Minikube

- **Pros**: Easy to set up multiple clusters; good for testing different Kubernetes versions; supports tunneling to expose services.
- **Cons**: Required newer hardware with proper virtualization support, limiting its usability on my older systems.

### K3d

- **Pros**: Seamless integration with Docker; lightweight; customizable with configuration files.
- **Cons**: Networking complexities arose when trying advanced configurations, especially when exposing services to external networks.

### MicroK8s

- **Pros**: Lightweight and production-grade; auto-high availability with three or more nodes; easy addon management (e.g., K8s dashboard).
- **Cons**: Tied to the Snap package manager, which limited portability across non-Ubuntu systems; configuration defaults were more suited to production than experimentation.

## Installation

### Prerequisite

Tools required:

1. [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
1. [helm](https://helm.sh/docs/intro/install/)
1. [dig](https://www.cloudns.net/blog/linux-dig-command-install-use/#How_to_install_the_dig_command_on_Linux)

These steps were verified on Ubuntu 22.04 but should work on any Linux distribution.

### Setting up K3s Server

The configuration file for K3s resides in `/etc/rancher/k3s/config.yaml`. Starting with a basic configuration to get the cluster up and running. For more details about the configuration file and its syntax, you can refer to the official [K3s Configuration Documentation](https://docs.k3s.io/installation/configuration#configuration-file).

Key configurations include:

- The kube config file is generated in `/etc/rancher/k3s/k3s.yaml`, which contains secrets needed to interact with the cluster. It’s advisable to secure this file.
- The `cluster-cidr` and `service-cidr` settings are customized to avoid conflicts with the current 10.0.0.0/8 address block being used in my environment.
- The `cluster-dns` IP is set to a static address, as I will be configuring a custom CoreDNS instance. For this reason, the default K3s CoreDNS is disabled.
- Load balancing will be managed by MetalLB, which we will set up later. Thus, the default servicelb is disabled.
- To conserve compute resources, the metrics server is disabled, as it’s not needed for this setup.
- An ingress controller like Traefik can be installed later if required, but it’s disabled for now.
- Since this guide focuses on a homelab or single-node Kubernetes setup, the cloud controller is also disabled.
- Finally, as the intent is to use ArgoCD for application management, the Helm controller is disabled for now

Refer to [K3s Package Components](https://docs.k3s.io/installation/packaged-components#packaged-components) to learn more about the addons that K3s comes with.

As part of my local network address allocation, I use 172.16.0.0/12 for locally unroutable addresses and 10.0.0.0/8 for locally routable addresses.

Start by creating the directory for the configuration file:

```sh
mkdir -p /etc/rancher/k3s/
```

Now, create the configuration file `/etc/rancher/k3s/config.yaml` with the following content:

```yaml
# /etc/rancher/k3s/config.yaml
write-kubeconfig-mode: "0644"
flannel-iface: eno1

cluster-cidr: 172.16.0.0/16
service-cidr: 172.17.0.0/16
cluster-dns: 172.17.17.17
disable:
  - coredns
  - metrics-server
  - servicelb
  - traefik
disable-cloud-controller: true
disable-helm-controller: true
```

To install the K3s binaries and set it up as a system service, run the following command:

```sh
curl -sfL https://get.k3s.io | sh -s - server --config /etc/rancher/k3s/config.yaml
```

For a more detailed setup guide, refer to the [K3s Quick Start Guide](https://docs.k3s.io/quick-start), which includes instructions for adding additional nodes to your cluster.

To explore additional configuration options for your K3s setup, check out [More configuration options](https://docs.k3s.io/installation/configuration).

### Configuring kubectl

Once the installation completes, K3s provides a built-in `kubectl` sub-command. You can either use `kubectl` this way or configure it to run as a standalone command by writing the Kubeconfig file to your home directory. This ensures that `kubectl` can be used independently without referencing the K3s binary each time.

To write the Kubeconfig file to the standard `~/.kube/config` location, use the following command:

```sh
k3s kubectl config view --raw > ~/.kube/config
```

### Verifying the K8s cluster

To verify that your Kubernetes cluster is set up correctly and the nodes are healthy, run the following command:

```sh
kubectl get nodes
```

Look for the STATUS=Ready and the ROLES=control-plane,master in the output. You might need to wait a few seconds for the status to update to "Ready".

```sh
$ kubectl get nodes
NAME                        STATUS   ROLES                  AGE    VERSION
myhost.local                Ready    control-plane,master   2d6h   v1.30.3+k3s1
```

To list all services running in the cluster, use the following command:

```sh
kubectl get svc --all-namespaces
```

You can also view all running resources (pods, deployments, replicasets, etc.) across all namespaces with:

```sh
kubectl get all --all-namespaces
```

Example output:

```sh
$ kubectl get all --all-namespaces
NAMESPACE     NAME                                          READY   STATUS    RESTARTS   AGE
kube-system   pod/local-path-provisioner-6795b5f9d8-x2k6x   1/1     Running   0          23s

NAMESPACE   NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
default     service/kubernetes   ClusterIP   172.17.0.1   <none>        443/TCP   41s

NAMESPACE     NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/local-path-provisioner   1/1     1            1           37s

NAMESPACE     NAME                                                DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/local-path-provisioner-6795b5f9d8   1         1         1       23s
```

These commands allow you to verify that your K3s cluster is up and running, with all core components operating as expected.

### Installing MetalLB

MetalLB enables your Kubernetes services to be accessible from outside the local machine by assigning external IP addresses. In this setup, MetalLB is configured to use the same subnet as the host machine. Later, I plan to move Kubernetes services to their own subnet, which will be covered in a future post.

In my environment, the host node’s main interface and default route are on the `10.1.2.0/24` subnet. I configure my DHCP server to reserve IP addresses from `10.1.2.200-254` for MetalLB, which will assign these IPs to Kubernetes services.

To install MetalLB, download the manifest and place it in the `/var/lib/rancher/k3s/server/manifests` directory. Placing the manifest here ensures it will be automatically applied by K3s.

```sh
wget -O /var/lib/rancher/k3s/server/manifests/metallb.yaml https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```

**Alernatively** you can directly apply the manifest directly with the following kubectl command:

```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml`
```

### Verifying MetalLB Installation

Once MetalLB is installed, it's crucial to verify that the components are running correctly. This step ensures that MetalLB is properly integrated into your Kubernetes cluster and ready to assign IP addresses to services

To verify the status of the MetalLB components, you can inspect the resources running in the `metallb-system` namespace. The following command will display the pods, services, deployments, and other resources in this namespace.

```sh
kubectl get all --namespace metallb-system
```

```sh
$ kubectl get all --namespace metallb-system
NAME                              READY   STATUS    RESTARTS   AGE
pod/controller-6dd967fdc7-dbmdz   1/1     Running   0          3m31s
pod/speaker-hcbt8                 1/1     Running   0          3m31s

NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/metallb-webhook-service   ClusterIP   172.17.69.80   <none>        443/TCP   3m31s

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/speaker   1         1         1       1            1           kubernetes.io/os=linux   3m31s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller   1/1     1            1           3m31s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-6dd967fdc7   1         1         1       3m31s
```

In the output, you should see that the controller and speaker pods are in a Running state with no restarts. This indicates that MetalLB has been successfully deployed and is operating correctly. If any pods are not running or have restart counts, you may need to investigate further.

The controller assigns IPs to the servcies, while the speaker is responsible for announcing the services via Layer 2. The metallb-webhook-service provides validation for configuration changes. Each component must be operational for MetalLB to function properly.

If you encounter any issues, such as pods not being in the `Running` state or having high restart counts, consult the [MetalLB troubleshooting documentation](https://metallb.universe.tf/troubleshooting/). You can also inspect the pod logs using `kubectl logs` to identify potential errors.

Refer to [MetalLB Installation](https://metallb.universe.tf/installation/) for more details and other installation methods.

### Configuring MetalLB

Now that MetalLB is installed, the next step is to configure the IP address pool that MetalLB will use to assign external IPs to your Kubernetes services. This configuration ensures that services can be reached from outside your Kubernetes cluster.

You need to pick an IP range from your host's subnet that MetalLB can assign to services. In this example, I’ve chosen `10.1.2.200-10.1.2.209` for statically assigned IPs and `10.1.2.210-10.1.2.254` for dynamically assigned IPs. This range allows a total of 55 services, with 10 static and 45 dynamic IPs.

It’s essential to ensure that the range you select does not overlap with your DHCP server's IP range. Overlapping ranges can cause IP conflicts, leading to network instability.

After adjusting the IP range to match your host’s subnet, save the configuration manifest in `/var/lib/rancher/k3s/server/manifests/metallb-config.yaml`. Placing the manifest in this directory ensures K3s will automatically apply the configuration.

The configuration file defines two IP address pools: `host-lan-reserved` for static IP assignments and `host-lan-assignable` for dynamic assignments. The `L2Advertisement` section tells MetalLB to advertise these IPs over layer 2, making Kubernetes services accessible externally.

```yaml
# /var/lib/rancher/k3s/server/manifests/metallb-config.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: host-lan-reserved
  namespace: metallb-system
spec:
  addresses:
    - 10.1.2.200-10.1.2.209
  avoidBuggyIPs: true
  autoAssign: false

---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: host-lan-assignable
  namespace: metallb-system
spec:
  addresses:
    - 10.1.2.210-10.1.2.255
  avoidBuggyIPs: true
  autoAssign: true

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: host-lan
  namespace: metallb-system
spec:
  ipAddressPools:
    - host-lan-assignable
    - host-lan-reserved
```

Depending on your environment, you might need to adjust additional settings in MetalLB. Refer to the official [MetalLB Usage](https://metallb.universe.tf/usage/) for more advanced configuration options.

### Installing CoreDNS via Helm

CoreDNS is a flexible and scalable DNS server for Kubernetes, providing DNS-based service discovery. In this setup, we will install CoreDNS using Helm to manage DNS resolution within the Kubernetes cluster. Using Helm allows for easier management and customization of the CoreDNS deployment.

CoreDNS needs to have a static IP address configured to ensure consistent DNS resolution. This IP address (`172.17.17.17`) was already specified in the cluster-dns setting within the K3s configuration file (`/etc/rancher/k3s/config.yaml`). Setting this static IP ensures that all cluster services use the same DNS resolver.

**Adding the Helm Repository**
First, add the CoreDNS Helm repository to your Helm installation. This repository contains the official CoreDNS Helm chart:

```sh
helm repo add coredns https://coredns.github.io/helm
```

**Setting up ConfigMap with External TLD**
In this step, we configure a `ConfigMap` to enable CoreDNS to resolve domain names for services that should be accessible externally. This allows you to handle DNS-based service discovery for services outside of the Kubernetes cluster.

First, place the following `ConfigMap` in the `/var/lib/rancher/k3s/server/manifests/coredns-config-map-k8s-external.yaml` file. This `ConfigMap` defines the external domain that CoreDNS should resolve. Once the file is placed, K3s will auto apply it.

Replace `example.com` with the domain name that you plan to use for your external services.

```yaml
# /var/lib/rancher/k3s/server/manifests/coredns-config-map-k8s-external.yaml
coredns-config-map-k8s-external.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-k8s-external
  namespace: kube-system
data:
  coredns-k8s-external.conf: |
    example.com:53 {
      kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
        ttl 30
      }
      k8s_external
    }
```

**Installing the CoreDNS Helm Chart**
Now that the `ConfigMap` is ready, install CoreDNS using Helm to manage DNS within your Kubernetes cluster. We will configure the service IP to `172.17.17.17` for internal DNS resolution and expose CoreDNS externally via a LoadBalancer with the IP `10.1.2.200` from the `host-lan-reserved` range.

```sh
helm  --namespace=kube-system install coredns coredns/coredns \
      --set service.clusterIP=172.17.17.17 \
      --set serviceType=LoadBalancer \
      --set service.loadBalancerIP=10.1.2.200 \
      --set extraConfig.import.parameters="/opt/coredns/*.conf" \
      --set extraVolumes[0].name=coredns-k8s-external \
      --set extraVolumes[0].configMap.name=coredns-k8s-external \
      --set extraVolumeMounts[0].name=coredns-k8s-external \
      --set extraVolumeMounts[0].mountPath=/opt/coredns
```

Once the Helm installation is complete, it will provide some commands to verify the deployment. Before verifying, wait for the CoreDNS pods to be ready. You can monitor the readiness of the pods by using the following command:

```sh
kubectl wait --namespace kube-system --for=condition=Ready pod --all --timeout=300s
```

**Verifying DNS Resolution**
To verify that CoreDNS is resolving DNS correctly within your cluster, you can create a temporary pod and use it to query the DNS record for the `kubernetes` service. This will confirm that CoreDNS is functioning properly:

```sh
kubectl run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools --command host kubernetes
```

The output should confirm that the kubernetes service is resolvable and returning the correct IP address (`172.17.0.1`) as shown in the example output below.

```sh
$ kubectl run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools --command host kubernetes
kubernetes.default.svc.cluster.local has address 172.17.0.1
```

**Verifying Service DNS Resolution**
After setting up CoreDNS, verify that it resolves both internal and external DNS queries correctly.

To check internal DNS resolution, run the following from another machine or the same node:

```sh
dig +short @10.1.2.200 coredns.kube-system.svc.cluster.local
```

For external DNS resolution:

```sh
dig +short @10.1.2.200 coredns.kube-system.example.com
```

Expected output:

```sh
$ dig +short @10.1.2.200 coredns.kube-system.svc.cluster.local
172.17.17.17
$ dig +short @10.1.2.200 coredns.kube-system.example.com
10.1.2.200
```

## Conclusion

Setting up a lightweight Kubernetes cluster with K3s on a single node offers a powerful yet resource-efficient way to experiment with Kubernetes, especially in a homelab environment. By utilizing MetalLB for external IP allocation and configuring CoreDNS for both internal and external DNS resolution, you can extend the reach of your Kubernetes services beyond the cluster, making them accessible to other devices on your network.

This setup allows you to simulate production-like scenarios in a controlled environment without the overhead of a full-scale cluster, enabling you to refine your skills, test new configurations, and explore various Kubernetes features. Whether you're deploying services like ArgoCD or simply experimenting with Kubernetes, this guide provides a solid foundation to build upon as you expand your homelab capabilities.

Remember that while this setup is ideal for experimentation and learning, it is not recommended for production workloads. However, the skills and knowledge gained here will translate well into more robust and scalable Kubernetes environments.

With the groundwork laid, you can continue to enhance your setup, exploring additional tools and configurations such as ingress controllers, monitoring solutions, and automated application deployment with ArgoCD. Kubernetes offers nearly limitless possibilities, and with a properly configured homelab, you're well-positioned to dive deeper into this dynamic and evolving technology.

In the next post, I will add ArgoCD to continue configuring the cluster further via ArgoCD.
