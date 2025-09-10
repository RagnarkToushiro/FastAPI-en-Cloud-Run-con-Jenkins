pipeline {
  agent any

  environment {
    //PROJECT_ID   = credentials('gcp-project-id')  // opcional si lo guardas como secret text
    REGION       = 'us-central1'
    REPO_NAME    = 'apps'
    SERVICE_NAME = 'fastapi-demo'
    // Si no usas cred 'gcp-project-id', escribe el ID literal:
    PROJECT_ID = 'devops-dcrm'
    REGISTRY_HOST = "${REGION}-docker.pkg.dev"
  }

  options {
    timestamps()
    //ansiColor('xterm')
  }

  stages {
    stage('Checkout') {
      
      steps {
        ansiColor('xterm'){
           checkout scm
        }
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
        ansiColor('xterm') {
          script {
            // Obtenemos la URL pública del servicio recién desplegado
            def URL = sh(
              returnStdout: true,
              script: "gcloud run services describe \"$SERVICE_NAME\" --region \"$REGION\" --format='value(status.url)'"
            ).trim()
            echo "Service URL: ${URL}"
 
            // Probaremos varios paths y aceptaremos 2xx/3xx
            def paths = ['/healthz', '/healthz/', '/ping', '/']
            def ok = false
 
            for (p in paths) {
              // -s: silencioso ; -o /dev/null: no imprime body ; -w '%{http_code}': muestra solo el código ; -L: sigue redirects
              // "|| true" evita que un 404 reviente el loop completo
              def code = sh(returnStdout: true, script: "curl -s -o /dev/null -w '%{http_code}' -L \"${URL}${p}\" || true").trim()
              echo "Probing ${URL}${p} -> HTTP ${code}"
              if (code.startsWith('2') || code.startsWith('3')) {
                ok = true
                echo "✅ Smoke test OK en ${URL}${p} (HTTP ${code})"
                break
              }
            }
 
            if (!ok) {
              // Diagnóstico: imprime cabeceras + primeras líneas del body de /healthz y /
              sh """
                set -e
                echo '--- Diagnóstico /healthz ---'
                curl -i -L "${URL}/healthz" || true
                echo '--- Diagnóstico / ---'
                curl -i -L "${URL}/" || true
              """
              error("Smoke Test: ninguna ruta respondió 2xx/3xx")
            }
          }
        }
      }
    }
  }
 
  post {
    success {
      ansiColor('xterm') {
        script {
          def url = sh(
            returnStdout: true,
            script: "gcloud run services describe \"$SERVICE_NAME\" --region \"$REGION\" --format='value(status.url)'"
          ).trim()
          echo "✅ Despliegue exitoso: ${url}"
        }
      }
    }
    failure {
      ansiColor('xterm') {
        echo "❌ Pipeline falló. Revisa logs."
      }
    }
  }
}

