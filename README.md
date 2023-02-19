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




<img width="1278" alt="image" src="https://user-images.githubusercontent.com/66652532/219960113-aaf32301-2996-444e-8274-38b80e85b207.png">
<img width="1278" alt="image" src="https://user-images.githubusercontent.com/66652532/219960343-35f4eb6f-881a-4244-b31c-2c2e8a68fcf6.png">
<img width="1487" alt="image" src="https://user-images.githubusercontent.com/66652532/219960468-94894f81-d73c-4e59-a41c-2a7a8d501057.png">

