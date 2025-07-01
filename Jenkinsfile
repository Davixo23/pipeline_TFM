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
          // Intentar obtener IP pública existente
          def existingIp = ''
          try {
            existingIp = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
          } catch (err) {
            echo "No se encontró IP pública existente."
          }
          // Guardar en variable de entorno para usar en stages posteriores
          env.INSTANCE_PUBLIC_IP = existingIp
          echo "IP pública detectada: ${env.INSTANCE_PUBLIC_IP}"
        }
      }
    }
    stage('Terraform') {
      when {
        expression { params.ACTION == 'destroy' || env.INSTANCE_PUBLIC_IP == '' }
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
        script {
          // Aquí puedes agregar comandos SSH o scripts para desplegar las imágenes en la VM
          // Por ejemplo:
          sh """
            ssh -o StrictHostKeyChecking=no ubuntu@${env.INSTANCE_PUBLIC_IP} 'docker pull ${env.DOCKERHUB_USER}/backend-app:${env.TAG} && docker run -d --name backend ${env.DOCKERHUB_USER}/backend-app:${env.TAG}'
            ssh -o StrictHostKeyChecking=no ubuntu@${env.INSTANCE_PUBLIC_IP} 'docker pull ${env.DOCKERHUB_USER}/frontend-app:${env.TAG} && docker run -d --name frontend -p 80:80 ${env.DOCKERHUB_USER}/frontend-app:${env.TAG}'
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
