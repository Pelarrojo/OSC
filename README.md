# 📦 Terraform - EKS Cluster para Proyecto Ecommerce

Este proyecto utiliza **Terraform** para aprovisionar un clúster de **Amazon EKS** en la región `us-east-1`, dentro de una VPC personalizada con subnets públicas y privadas, listas para producción. Ideal para desplegar una aplicación de comercio electrónico escalable y segura.

---

## 🚀 Características principales

- Despliegue automático de un clúster de EKS v1.30.
- VPC dedicada con:
  - Subnets públicas (para balanceadores de carga).
  - Subnets privadas (para nodos de EKS).
  - NAT Gateway para salida a Internet desde subnets privadas.
- Grupos de nodos administrados (Managed Node Groups) configurados con escalabilidad.
- Roles IAM reutilizados (no se crean nuevos).
- Acceso público habilitado al endpoint del clúster.

---

## 📁 Estructura del Proyecto
.
├── main.tf       # Configuración principal del clúster EKS
├── vpc.tf        # Recursos de red: VPC, subnets, NAT Gateway, etc.
├── service.yaml  # Levanta el Servicio y mapea los puertos para la app
└── deployment.yaml    #Levanta el pod con el contenedor

## 📦 Requisitos
Terraform >= 1.3
AWS CLI
Credenciales AWS configuradas (LabRole IAM ya existente)

## ⚙️ Uso
Inicializa el entorno de Terraform


terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --name ecommerce-cluster --region us-east-1
kubectl apply -f deployment.yaml -f service.yaml

Cuando el pod no puede acceder a la imagen es porque no estaba subida a un repositorio, en nuestro caso un ECR

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 997733898678.dkr.ecr.us-east-1.amazonaws.com
docker tag frontend-ecommerce 997733898678.dkr.ecr.us-east-1.amazonaws.com/frontend-ecommerce:latest
docker push 997733898678.dkr.ecr.us-east-1.amazonaws.com/frontend-ecommerce:latest
kubectl apply -f deployment.yaml
kubectl get pods -o wide

Se cambia el contexto para que se levante en la nube y no local con kind utilizando el comando:
kubectl config use-context arn:aws:eks:us-east-1:997733898678:cluster/ecommerce-cluster

Para ingresar a la app se accede mediante el dns del load balancer:
http://a911e3b82fd7a4d6bb90aa8ae20238b3-1081746352.us-east-1.elb.amazonaws.com

## 🌐 Red (VPC)
CIDR principal: 10.0.0.0/16

Subnets públicas: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24

Subnets privadas: 10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24

NAT Gateway: habilitado para salida a Internet desde las subnets privadas

Internet Gateway: asociado a las subnets públicas

## 🧩 Módulo EKS
Este proyecto utiliza el módulo oficial:

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19"
  ...
}

## 🛑 Notas importantes
Asegúrate de tener creado el rol LabRole en IAM antes de aplicar.

No se crean roles adicionales ni perfiles de instancia; se reutilizan los existentes.

Acceso público al API Server de EKS está habilitado. Asegúrate de configurar los security groups adecuadamente si lo necesitas restringir.
