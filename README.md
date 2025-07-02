# 🚘 Luxury Car Showcase Web App Deployment using DevOps Practices

## 📌 Project Overview

This project demonstrates a complete DevOps pipeline to build, deploy, and monitor a static **Luxury Car Showcase Web Application** using modern DevOps tools and AWS services. It was developed during my internship at **SparkNet LLP**.

---

## 📁 Project Structure

```
car-web-app/
├── Dockerfile
├── server.js
├── package.json
├── public/
├── dist/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── cloudwatch-agent-daemonset.yaml
├── cwagentconfig.yaml
└── .github/workflows/deploy.yaml
```

---

## 🛠️ Technologies Used

- **Frontend Framework:** Vite + Tailwind CSS + Node.js
- **Containerization:** Docker
- **CI/CD Pipeline:** GitHub Actions
- **Infrastructure Provisioning:** Terraform
- **Container Orchestration:** AWS EKS (Elastic Kubernetes Service)
- **Monitoring:** AWS CloudWatch Agent (DaemonSet)
- **Image Hosting:** Docker Hub / ECR

---

## 🚀 Features

- Containerized Node.js static site
- Fully automated CI/CD pipeline
- Kubernetes deployment with LoadBalancer service
- Real-time metrics monitoring with CloudWatch
- Infra-as-Code via Terraform

---

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Krish4884/car-web-app.git
cd car-web-app
```

### 2. Docker Build & Push (Optional if using GitHub Actions)

```bash
docker build -t krish010/car-showcase-app:v2 .
docker push krish010/car-showcase-app:v2
```

### 3. Provision AWS Infrastructure with Terraform

```bash
cd terraform
terraform init
terraform apply
```

### 4. Deploy to Kubernetes (EKS)

```bash
cd ../k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 5. Set Up CloudWatch Monitoring

```bash
kubectl apply -f cwagentconfig.yaml
kubectl apply -f cloudwatch-agent-daemonset.yaml
```

---

## 🔄 CI/CD with GitHub Actions

- Triggered on every push to the `main` branch
- Steps:
  - Checkout Code
  - Configure AWS Credentials
  - Build Docker Image
  - Push to ECR
  - Deploy to EKS

Config located in: `.github/workflows/deploy.yaml`

---

## 📊 Monitoring

CloudWatch Agent collects:
- CPU Usage
- Memory Usage
- Disk Usage
- Swap Usage

> View metrics in **AWS CloudWatch → Metrics → CWAgent Namespace**

---

## ⚠️ Challenges Faced

- CloudWatch Agent crash loop due to JSON config errors
- Docker push permission denied
- EKS NodeGroup provisioning failures
- Broken IAM permissions after reboot

> ✅ All issues resolved via role attachment, config validation, and manual restarts

---

## 📸 Demo Screenshot

![Web App Screenshot](./screenshots/car-showcase-home.png)

---

## 🙌 Acknowledgements

Thanks to **SparkNet LLP** for the internship opportunity and project guidance.

---

## 👤 Author

**Krish Thadhani**  
[GitHub](https://github.com/Krish4884)
