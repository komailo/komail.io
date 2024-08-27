---
draft: false
date: 2024-08-26T20:11:49-05:00
title: "Getting started with Kubernetes Dashboard"
description: ""
slug: ""
tags:
  - k8s
  - kubernetes-dashboard
categories:
  - How To
  - Blogging
externalLink: ""
series:
  - Running a Local Kubernetes Cluster
---

{{< notice note >}}
Kubernetes dashboard should not be exposed to the public. By all means you should protect the external service IP and not expose it to the internet.
The sample user created in the manefest earlier will have administrative privileges and is for educational purposes only.
{{< /notice >}}

In my last post we installed ArgoCD on our local K8s cluster and added the application Kubernetes dashboard. In this post we will talk about logging in to Kubernetes dashboard.

## Why Kubernetes Dashboard

We will make use of ArgoCD to deploy applications but Kubernetes Dashboard can also be used to do that in the same way you can use `kubectl`. However, the main purpose of us using Kubernetes Dashboard is to visualize the cluster as configuration is going to be handled by ArgoCD.

## ArgoCD View

I did a deployment of Kubernetes dashboard via ArgoCD in the previous post. You can find the manifests [here](https://github.com/komailo/argocd-example-manifests/tree/main/applicationset/all-clusters/kubernetes-dashboard)

## Conclusion

With ArgoCD successfully installed and configured on your local Kubernetes cluster, you now have a powerful GitOps tool to manage and automate your application deployments. We started by creating a GitHub App to securely connect to your repositories without exposing SSH keys, then used Helm to install ArgoCD with a custom configuration tailored to your environment. We also bootstrapped ArgoCD by deploying an initial application that serves as the foundation for managing future deployments. Finally, we accessed the ArgoCD UI, where you can now monitor, manage, and synchronize your applications directly from your Git repository.

By following these steps, you’ve set up a scalable and automated system for continuous delivery within your Kubernetes cluster, leveraging the full power of GitOps. This is just the beginning—moving forward, you can continue to build on this setup by adding more applications, configuring additional security measures, and fine-tuning ArgoCD to suit your development workflow.

Stay tuned to this series as we continue to explore more advanced Kubernetes topics, including application deployments, secret management, local volume management, and tunneling via Cloudflared.
