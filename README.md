# Terraform-wordpress-GCP



Overview

This Terraform configuration creates a Kubernetes cluster on Google Cloud and deploys a WordPress application on it. The following resources are created:

    Google Kubernetes Engine (GKE) cluster with one node pool and autopilot enabled.
    Kubernetes deployment for the WordPress application with two replicas.
    Kubernetes service that exposes the WordPress deployment with a load balancer.
    Kubernetes horizontal pod autoscaler that scales the WordPress deployment based on CPU utilization.
    Kubernetes ingress that routes traffic from the domain "liwaadev.com" to the WordPress service, and configures HTTPS with a Let's Encrypt SSL certificate.

Prerequisites

Before running this Terraform configuration, make sure you have the following:

    A Google Cloud Platform account with billing enabled.
    The Google Cloud SDK installed on your local machine.
    A Google Cloud project with the necessary APIs enabled.
    The gcloud command-line tool authenticated to your Google Cloud account.
    A domain name that you control and can configure DNS for.



<img width="1512" alt="image" src="https://user-images.githubusercontent.com/66652532/221374559-8def2fbe-6870-470b-a3b9-1621a35e607d.png">
<img width="1512" alt="image" src="https://user-images.githubusercontent.com/66652532/221374567-7f776cc7-35bb-40e8-b169-a19136e16617.png">
<img width="1512" alt="image" src="https://user-images.githubusercontent.com/66652532/221374576-f2f045f8-7d96-460f-a51a-ea00ef11475d.png">
<img width="1512" alt="image" src="https://user-images.githubusercontent.com/66652532/221374585-fa8b43d8-57f1-4a3f-ab25-7d819b1e15d2.png">
<img width="1512" alt="image" src="https://user-images.githubusercontent.com/66652532/221374592-51ce657d-cec9-4ca6-a00e-ccaa83102914.png">
