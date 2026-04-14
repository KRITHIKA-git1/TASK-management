# TaskFlow – Containerized Task Management Web Application

## Project Overview

TaskFlow is a cloud-native web application designed to manage tasks efficiently. The application demonstrates a full-stack architecture consisting of a frontend, backend, and database, and showcases modern DevOps practices such as containerization and container orchestration.

The project is built using Docker containers and deployed through Kubernetes, with container images stored in Amazon Elastic Container Registry (ECR).

---

## Features

* Add new tasks
* View existing tasks
* Delete completed tasks
* Responsive user interface
* Containerized deployment using Docker
* Cloud-ready deployment using Kubernetes

---

## Technology Stack

### Frontend

* React / HTML / CSS / JavaScript

### Backend

* Node.js
* Express.js

### Database

* MongoDB

### DevOps & Cloud

* Docker
* Amazon Elastic Container Registry (ECR)
* Kubernetes

---

## Project Architecture

User → Frontend → Backend API → Database → Docker Containers → Amazon ECR → Kubernetes Cluster → Public Application URL

---

## Project Structure

taskflow-app/

frontend/ – Contains the user interface code

backend/ – Contains API and server logic

database/ – Database configuration

docker/ – Docker configuration files

kubernetes/ – Deployment YAML files

README.md

---

## Dockerization

Both frontend and backend services are containerized using Docker to ensure consistent deployment across environments.

Example commands:

docker build -t taskflow-frontend ./frontend

docker build -t taskflow-backend ./backend

---

## Container Registry

Docker images are pushed to Amazon Elastic Container Registry (ECR) for cloud storage and deployment.

Steps:

1. Create ECR repository
2. Authenticate Docker with AWS
3. Tag the image
4. Push image to ECR

---

## Kubernetes Deployment

The application is deployed using Kubernetes which manages container orchestration, scaling, and networking.

Kubernetes files include:

* frontend-deployment.yaml
* backend-deployment.yaml
* mongodb-deployment.yaml
* service.yaml

Deployment command:

kubectl apply -f deployment.yaml

---

## Learning Outcomes

* Full stack web application development
* Docker containerization
* Container image management with Amazon ECR
* Kubernetes deployment and orchestration
* Cloud-native application architecture

---

## Author

S. Krithika
B.Tech – Artificial Intelligence and Data Science
St. Joseph’s Institute of Technology
