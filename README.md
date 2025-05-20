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
