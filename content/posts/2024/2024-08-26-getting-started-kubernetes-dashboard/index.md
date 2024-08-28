---
draft: false
date: 2024-08-26T20:11:49-05:00
title: "Getting started with Kubernetes Dashboard"
description: "Discover how to access and manage the Kubernetes Dashboard on a local cluster using ArgoCD. This post covers login steps, credential retrieval, and the deployment process within ArgoCD."
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

{{< notice warning >}}
The Kubernetes Dashboard should never be exposed to the public. Ensure that the external service IP is protected and not accessible from the internet. The sample user created in the earlier manifest has administrative privileges and is intended for educational purposes only.
{{< /notice >}}

In the previous post, we explored how to install ArgoCD on our local Kubernetes (K8s) cluster and deploy applications, including the Kubernetes Dashboard. The Kubernetes Dashboard is a web-based UI that allows you to monitor and manage your Kubernetes cluster visually.

In this post, we’ll dive into how to access the Kubernetes Dashboard, focusing on the steps to securely log in using the credentials we set up during the deployment. By the end of this guide, you’ll be able to navigate the Dashboard and leverage its features to gain insights into your cluster’s operations.

## Why Kubernetes Dashboard

While ArgoCD is our primary tool for deploying applications, the Kubernetes Dashboard offers similar functionality to `kubectl` for managing resources. However, our main focus in using the Dashboard is to visualize the cluster, as configuration management will be handled by ArgoCD.

## Kubernetes Dashboard Deployment in ArgoCD

In the previous post, I deployed the Kubernetes Dashboard using ArgoCD. You can find the manifests [here](https://github.com/komailo/argocd-example-manifests/tree/main/applicationset/all-clusters/kubernetes-dashboard).

{{< figure link="./images/kubernetes-dashboard-argocd-app.png" src="./images/kubernetes-dashboard-argocd-app.png" caption="Kubernetes Dashboard ArgoCD Application" >}}

The above screenshot and manifest shows all the resources that were created as part of the application.

These resources collectively ensure that the Kubernetes Dashboard is deployed correctly and operates securely within the cluster. The Namespace isolates the Dashboard resources, the Service Account and Secret provide authentication and authorization mechanisms, the Helm application manages the deployment, and the ClusterRoleBinding grants the required permissions. Together, they form the necessary components to run the Kubernetes Dashboard while adhering to security and organizational best practices within the Kubernetes environment.

This structure, as visualized in ArgoCD, highlights the interconnectedness of these resources and how they work together to support the application’s deployment and functionality.

## Accessing the Dashboard

**Getting the external IP**
To access the Kubernetes Dashboard, first, retrieve the external IP assigned to it by running the following command: `kubectl get svc --namespace kubernetes-dashboard`

In the example output below you can see the external IP:

```sh
kubectl get svc --namespace kubernetes-dashboard
NAME                                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
kubernetes-dashboard-api               ClusterIP      172.17.246.214   <none>        8000/TCP                        21h
kubernetes-dashboard-auth              ClusterIP      172.17.119.45    <none>        8000/TCP                        21h
kubernetes-dashboard-kong-manager      NodePort       172.17.189.225   <none>        8002:32585/TCP,8445:31008/TCP   21h
kubernetes-dashboard-kong-proxy        LoadBalancer   172.17.5.224     10.1.2.211    443:31738/TCP                   21h
kubernetes-dashboard-metrics-scraper   ClusterIP      172.17.33.146    <none>        8000/TCP                        21h
kubernetes-dashboard-web               ClusterIP      172.17.130.237   <none>        8000/TCP                        21h
```

Head to the dashboard UI via the browser. Make sure to use `https`. Example `https://10.1.2.211`. Once you head to that page you will be prompted to enter the bearer token.

{{< figure link="./images/kuberenetes-dashboard-bearer-token.png" src="./images/kuberenetes-dashboard-bearer-token.png" caption="Kubernetes Dashboard Login Page" >}}

**Getting the Bearer Token**
To obtain the Bearer Token needed for login, run the following command to retrieve the secret for the `admin-user` service account:

```sh
kubectl get secret admin-user --namespace kubernetes-dashboard --output jsonpath={".data.token"} | base64 --decode && echo ""
```

See [Using Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#using-dashboard) for more information views of the Kubernetes Dashboard UI; what they provide and how can they be used.

## Conclusion

In this post, we explored how to access and use the Kubernetes Dashboard, a powerful tool for visualizing your cluster's resources. By deploying the Dashboard via ArgoCD, we ensure that our infrastructure is both manageable and secure. Remember, while the Dashboard provides significant insights, it should be used cautiously in a production environment due to its powerful administrative access.
