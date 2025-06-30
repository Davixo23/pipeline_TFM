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
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Terraform Init') {
      steps {
        withCredentials([file(credentialsId: 'oci-private-key', variable: 'OCI_PRIVATE_KEY')]) {
          sh '''
            export TF_VAR_private_key_path=$OCI_PRIVATE_KEY
            terraform init
          '''
        }
      }
    }
    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }
    stage('Terraform Apply or Destroy') {
      steps {
        script {
          if (params.ACTION == 'apply') {
            sh 'terraform apply -auto-approve tfplan'
          } else if (params.ACTION == 'destroy') {
            sh 'terraform destroy -auto-approve'
          } else {
            error "Acción no soportada: ${params.ACTION}"
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
