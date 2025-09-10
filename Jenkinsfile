pipeline {
  agent any

  environment {
    PROJECT_ID   = credentials('gcp-project-id')  // opcional si lo guardas como secret text
    REGION       = 'southamerica-west1'
    REPO_NAME    = 'apps'
    SERVICE_NAME = 'fastapi-demo'
    # Si no usas cred 'gcp-project-id', escribe el ID literal:
    // PROJECT_ID = 'TU_PROYECTO'
    REGISTRY_HOST = "${REGION}-docker.pkg.dev"
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('GCloud Auth') {
      steps {
        withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh '''
            gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
            gcloud config set project ${PROJECT_ID}
            gcloud auth configure-docker ${REGISTRY_HOST} -q
          '''
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        script {
          def COMMIT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
          env.IMAGE = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:${COMMIT}"
          env.IMAGE_LATEST = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:latest"
        }
        sh '''
          docker build -t "${IMAGE}" -t "${IMAGE_LATEST}" .
          docker push "${IMAGE}"
          docker push "${IMAGE_LATEST}"
        '''
      }
    }

    stage('Deploy to Cloud Run') {
      steps {
        sh '''
          gcloud run deploy ${SERVICE_NAME} \
            --image ${IMAGE} \
            --platform managed \
            --region ${REGION} \
            --allow-unauthenticated \
            --port 8000
        '''
      }
    }

    stage('Smoke Test') {
      steps {
        script {
          def URL = sh(returnStdout: true, script: "gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format='value(status.url)'").trim()
          echo "Service URL: ${URL}"
          sh """
            # Espera breve para que quede ready
            sleep 5
            curl -fsS ${URL}/healthz
          """
        }
      }
    }
  }

  post {
    success {
      script {
        def url = sh(returnStdout: true, script: "gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format='value(status.url)'").trim()
        echo "✅ Despliegue OK: ${url}"
      }
    }
    failure {
      echo "❌ Falló el pipeline. Revisa los logs (auth, permisos, build, deploy)."
    }
  }
}

