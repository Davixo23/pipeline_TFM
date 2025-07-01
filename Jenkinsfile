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
stages {
    stage('Build and Push Docker Images') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials_id', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW')]) {
            // Opcional: hacer login explícito con docker CLI
            sh "docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}"
            
            docker.withRegistry('https://registry.hub.docker.com', '') {
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
