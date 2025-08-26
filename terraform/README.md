Debemos instalar el SDK de Google
https://cloud.google.com/sdk/docs/install-sdk?hl=es-419

una vez hecho esto, seguimos los pasos para que terraform pueda hacer acciones sobre nuestra infraestructura.


Creamos SA:

gcloud iam service-accounts create terraform-sa \
  --display-name "Terraform Service Account"

Asignamos permisos necesarios:

gcloud projects add-iam-policy-binding TU-PROYECTO \
  --member="serviceAccount:terraform-sa@TU-PROYECTO.iam.gserviceaccount.com" \
  --role="roles/editor"

Creamos una clave json:

gcloud iam service-accounts keys create ~/terraform-sa.json \
  --iam-account terraform-sa@TU-PROYECTO.iam.gserviceaccount.com


la dejamos como variable de ambiente:

export GOOGLE_APPLICATION_CREDENTIALS="~/terraform-sa.json"

o tambien se puede referenciar en el codigo ejemplo:

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file("terraform-sa.json")   # <-- si quieres referenciar la key JSON aquí
}

no olvidemos instalar terraform:

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

luego hacemos

terraform init
terraform apply -auto-approve \
  -var="project_id=TU-PROYECTO" \
  -var="region=us-central1" \
  -var="zone=us-central1-a"
terraform output


para crear nuestra primera VM


