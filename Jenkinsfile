pipeline {
  agent { label 'terraform-agent' }
  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: '¿Qué acción ejecutar?')
  }
  environment {
    TF_VAR_tenancy_ocid = credentials('oci-tenancy-ocid')
    TF_VAR_user_ocid = credentials('oci-user-ocid')
    TF_VAR_fingerprint = credentials('oci-fingerprint')
    TF_VAR_region = 'us-ashburn-1'
    TF_VAR_compartment_ocid = credentials('oci-compartment-ocid')
    TF_VAR_ssh_public_key = credentials('oci-ssh-public-key')

    DOCKERHUB_USER = 'davixo'
    TAG = "${env.BUILD_ID}"
  }
  stages {
    /*stage('Terraform') {
      steps {
        withCredentials([file(credentialsId: 'oci-private-key', variable: 'OCI_PRIVATE_KEY')]) {
          sh '''
            export TF_VAR_private_key_path=$OCI_PRIVATE_KEY
            terraform init
            terraform plan -out=tfplan
            if [ "${ACTION}" = "apply" ]; then
              terraform apply -auto-approve tfplan
            elif [ "${ACTION}" = "destroy" ]; then
              terraform destroy -auto-approve
            else
              echo "Acción no soportada: ${ACTION}"
              exit 1
            fi
          '''
        }
      }
    }*/
stage('Create Docker Hub Repositories') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials_id', usernameVariable: 'DOCKERHUB_CRED_USER', passwordVariable: 'DOCKERHUB_CRED_PASS')]) {
            sh """
              curl -s -o /dev/null -w "%{http_code}" -X POST \
                -H "Content-Type: application/json" \
                -H "Authorization: JWT ${DOCKERHUB_CRED_PASS}" \
                -d '{"namespace": "${DOCKERHUB_CRED_USER}", "name": "backend-app", "is_private": false, "description": "Backend application image"}' \
                https://hub.docker.com/v2/repositories/
              # Verificación omitida para brevedad
            """
            sh """
              curl -s -o /dev/null -w "%{http_code}" -X POST \
                -H "Content-Type: application/json" \
                -H "Authorization: JWT ${DOCKERHUB_CRED_PASS}" \
                -d '{"namespace": "${DOCKERHUB_CRED_USER}", "name": "frontend-app", "is_private": false, "description": "Frontend application image"}' \
                https://hub.docker.com/v2/repositories/
              # Verificación omitida para brevedad
            """
          }
        }
      }
    }
    stage('Build and Push Docker Images') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials_id', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW')]) {
            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_credentials_id') {
              def backendImage = docker.build("${env.DOCKERHUB_USER}/backend-app:${env.TAG}", "app/backend")
              backendImage.push()
              backendImage.push('latest')

              def frontendImage = docker.build("${env.DOCKERHUB_USER}/frontend-app:${env.TAG}", "app/frontend")
              frontendImage.push()
              frontendImage.push('latest')
            }
          }
        }
      }
    }
  }
  post {
    failure {
      echo 'Pipeline falló. Revisa los logs.'
    }
  }
}
