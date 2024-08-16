---
draft: false
date: 2024-08-13T20:34:11-05:00
title: "Getting started with K3s"
description: "A post about getting started with a lightweight K3s Kubernetes cluster on a local machine"
slug: ""
tags:
  - homelab
  - k8s
  - K3s
categories:
  - How To
  - Blogging
externalLink: ""
series:
  - Running a Local Kubernetes Cluster
---

In my various jobs as an SRE, I needed to learn how to interact with Kubernetes (k8s), build upon the fundamentals of k8s, and try out different scenarios without worrying too much about leaving behind breadcrumbs. To do this, I wanted a locally running k8s cluster that I could easily replicate on machines running Linux, MacOS, and (as a bonus) Windows.

My home lab is not equipped with a state-of-the-art compute stack, so resource constraints were a key consideration.

The goal of this guide is to give you a Kubernetes cluster to experiment with. It is not meant for production use and does not include any highly available components.

## Why K3s?

K3s emerged as the best solution for my needs due to its lightweight nature, minimal resource consumption, and flexibility. It's a CNCF-certified Kubernetes distribution backed by Rancher Labs, ensuring that the skills and configurations I develop will translate to more robust Kubernetes environments.

**Key Benefits of K3s**:

- **Lightweight**: Runs on resource-constrained machines.
- **Portability**: Works across Linux, MacOS, and Windows.
- **Simplicity**: Installed directly on the host, without heavy overhead.
- **Support**: Backed by Rancher Labs, a leader in Kubernetes management.
- **Multi-arch Support**: Works on various CPU architectures.

Before settling on K3s, I explored a few other alternatives. Below, I've listed them in the order I tried them. This is just to offer insight into my thought process and is not intended to be a comprehensive comparison.

### Docker Desktop

This was the first option I tried. However, due to the licensing restrictions introduced by Docker Inc. (not the software itself), it became impractical for work-related use. Given these restrictions, I decided to steer away from Docker Desktop, especially when considering setups that need to be easily replicated on work machines.

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

These steps were verified on Ubuntu 22.04 but should work on any Linux distribution.

```sh
mkdir -p /etc/rancher/k3s/
```

The configuration file lives in `/etc/rancher/k3s/config.yaml`. We will start with the basic configuration for now. More information about this configuraiton file and its syntax can be found [here](https://docs.k3s.io/installation/configuration#configuration-file)

- The kube config file is written to `/etc/rancher/k3s/k3s.yaml`. It contains secrets to interact with the cluster. A good idea to secure it.
- Make sure to replace the `flannel-iface` with the interface you want K3s to use to reach out to other nodes.
- The `cluster-cidr` and `service-cidr` were set for understanding purposes when looking at resources.

```yaml
write-kubeconfig-mode: "0600"
flannel-iface: eth0

cluster-cidr: 172.16.0.0/16
service-cidr: 172.17.0.0/16
```

To install the K3s binaries and set it up as a system service run:

```sh
curl -sfL https://get.k3s.io | sh -
```

Refer to [K3s Quick Start Guide](https://docs.k3s.io/quick-start) if adding more nodes.

Refer to [More configuration options](https://docs.k3s.io/installation/configuration) for more options commonly used when setting up K3s for the first time.

## Setup kubectl

Once the installtion completes the k3s binary will provide a sub-command `kubectl`. You can continue to use kubectl that way or write the kube config file to `~/.kube/config`.

```sh
k3s kubectl config view --raw > ~/.kube/config
```

## Verify

Run `kubectl get nodes` to confirm the health of the nodes.

```
kubectl get nodes
NAME                        STATUS   ROLES                  AGE    VERSION
myhost.local                Ready    control-plane,master   2d6h   v1.30.3+k3s1
```

There you have it. You have a ready to use k8s cluster. Will be back with more on how to configure networking and DNS.
