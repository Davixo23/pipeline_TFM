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
    stage('Check Existing Infrastructure') {
      steps {
        script {
          env.INSTANCE_PUBLIC_IP = ''
          try {
            sh 'terraform refresh' // sincroniza estado
            def existingIp = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
            if (existingIp && existingIp != '') {
              env.INSTANCE_PUBLIC_IP = existingIp
            } else {
              echo "Output instance_public_ip está vacío."
            }
          } catch (err) {
            echo "No se encontró IP pública existente."
          }
          echo "IP pública detectada: '${env.INSTANCE_PUBLIC_IP}'"
        }
      }
    }

    stage('Terraform') {
      when {
        expression {
          params.ACTION == 'destroy' || !env.INSTANCE_PUBLIC_IP?.trim()
        }
      }
      steps {
        withCredentials([file(credentialsId: 'oci-private-key', variable: 'OCI_PRIVATE_KEY')]) {
          sh '''
            chmod +x scripts/run_terraform.sh
            ./scripts/run_terraform.sh "$OCI_PRIVATE_KEY" "${ACTION}"
          '''
        }
      }
      post {
        success {
          script {
            if (params.ACTION == 'apply') {
              // Leer IP pública actualizada
              def publicIp = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
              env.INSTANCE_PUBLIC_IP = publicIp
              echo "IP pública actualizada: ${publicIp}"

              // Archivar archivo solo si existe
              def ipFile = 'instance_public_ip.txt'
              if (fileExists(ipFile)) {
                archiveArtifacts artifacts: ipFile, fingerprint: true
                echo "Archivo ${ipFile} archivado correctamente."
              } else {
                echo "Archivo ${ipFile} no encontrado para archivar."
              }
            } else if (params.ACTION == 'destroy') {
              env.INSTANCE_PUBLIC_IP = ''

              // Eliminar archivo instance_public_ip.txt si existe
              def ipFile = 'instance_public_ip.txt'
              if (fileExists(ipFile)) {
                sh "rm -f ${ipFile}"
                echo "Archivo ${ipFile} eliminado tras destroy."
              } else {
                echo "Archivo ${ipFile} no encontrado para eliminar."
              }
            }
          }
        }
      }
    }


    stage('Create Docker Hub Repositories') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials_id', usernameVariable: 'DOCKERHUB_CRED_USER', passwordVariable: 'DOCKERHUB_CRED_PASS')]) {
            sh 'chmod +x scripts/create_dockerhub_repos.sh'
            sh '''
              export DOCKERHUB_CRED_PASS="${DOCKERHUB_CRED_PASS}"
              export DOCKERHUB_CRED_USER="${DOCKERHUB_CRED_USER}"
              ./scripts/create_dockerhub_repos.sh
            '''
          }
        }
      }
    }

    stage('Build Docker Images') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          parallel(
            backend: {
              env.BACKEND_IMAGE = docker.build("${env.DOCKERHUB_USER}/backend-app:${env.TAG}", "app/backend").imageName()
            },
            frontend: {
              env.FRONTEND_IMAGE = docker.build("${env.DOCKERHUB_USER}/frontend-app:${env.TAG}", "app/frontend").imageName()
            }
          )
        }
      }
    }

    stage('Push Docker Images') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials_id', usernameVariable: 'DOCKERHUB_CRED_USER', passwordVariable: 'DOCKERHUB_CRED_PASS')]) {
            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_credentials_id') {
              parallel(
                backend: {
                  def backendImage = docker.image(env.BACKEND_IMAGE)
                  backendImage.tag('latest')
                  backendImage.push()
                  backendImage.push('latest')
                },
                frontend: {
                  def frontendImage = docker.image(env.FRONTEND_IMAGE)
                  frontendImage.tag('latest')
                  frontendImage.push()
                  frontendImage.push('latest')
                }
              )
            }
          }
        }
      }
    }

    stage('Deploy to VM') {
      when {
        expression { params.ACTION == 'apply' && env.INSTANCE_PUBLIC_IP != '' }
      }
      steps {
        sshagent(['oci-ssh-private-key']) {
          sh """
            echo "Copiando script de despliegue a la VM..."
            scp -o StrictHostKeyChecking=no scripts/deploy_docker.sh ubuntu@${env.INSTANCE_PUBLIC_IP}:/home/ubuntu/

            echo "Dando permisos y ejecutando script de despliegue..."
            ssh -o StrictHostKeyChecking=no ubuntu@${env.INSTANCE_PUBLIC_IP} 'chmod +x /home/ubuntu/deploy_docker.sh && /home/ubuntu/deploy_docker.sh'
          """
        }
      }
    }

    stage('Cleanup Docker Images') {
      steps {
        sh 'chmod +x scripts/cleanup_docker_images.sh'
        sh './scripts/cleanup_docker_images.sh'
      }
    }
  }
  post {
    failure {
      echo 'Pipeline falló. Revisa los logs.'
    }
  }
}
