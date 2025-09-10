# 🚀 Challenge DevOps: Desplegar FastAPI en Cloud Run con Jenkins

Este challenge práctico consiste en **construir y desplegar** una aplicación **FastAPI** en **Cloud Run (GCP)** utilizando **Jenkins** como orquestador de CI/CD.

---

## 🎯 Objetivos de aprendizaje
- Construir una **imagen Docker** de una API FastAPI.
- Publicar la imagen en **Artifact Registry**.
- Desplegar la app en **Cloud Run** usando Jenkins.
- Validar el despliegue con un **smoke test**.

---

## 📦 Pre-requisitos

1. Proyecto en **Google Cloud Platform (GCP)** ya creado.
2. **Jenkins** instalado en una VM de GCP (o local con acceso a internet).
3. **Docker** y **gcloud CLI** instalados en el servidor Jenkins.
4. Servicio de **Artifact Registry** habilitado en GCP.
5. **Cuenta de servicio** con permisos:
   - `roles/run.admin`
   - `roles/artifactregistry.writer`
   - `roles/iam.serviceAccountUser`
6. Clave JSON de la cuenta de servicio guardada como credencial en Jenkins:
   - Tipo: *Secret file*
   - ID: `gcp-sa-key`

---

## 📂 Estructura del repositorio

fastapi-cloudrun/
├─ app/
│ └─ main.py
├─ requirements.txt
├─ Dockerfile
├─ .dockerignore
└─ Jenkinsfile

⚙️ Jenkinsfile

El pipeline deberia realizarrealiza estos pasos:

Autenticación con GCP.

Build & push de la imagen a Artifact Registry.

Deploy a Cloud Run.




