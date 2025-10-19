properties([
  parameters([
    string(name: 'AWS_ACCESS_KEY_ID', defaultValue: ''),
    string(name: 'AWS_SECRET_ACCESS_KEY', defaultValue: ''),
    string(name: 'PUBLIC_KEY_PATH', defaultValue: '')
  ])
])

pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID     = "${params.AWS_ACCESS_KEY_ID}"
    AWS_SECRET_ACCESS_KEY = "${params.AWS_SECRET_ACCESS_KEY}"
    PUBLIC_KEY_PATH       = "${params.PUBLIC_KEY_PATH}"
  }

  stages {
    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }
    
    stage('Terraform Plan') {
      steps {
        sh 'terraform plan \
        -var="public_key_path=$PUBLIC_KEY_PATH"'
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve \
        -var="public_key_path=$PUBLIC_KEY_PATH"'
      }
    }/*
    stage('Terraform Destroy') {
            steps {
                // Запитати підтвердження (опціонально)
                echo 'Destroying infrastructure...'
                // Виконати знищення інфраструктури
                sh 'terraform destroy -auto-approve \
                -var="public_key_path=$PUBLIC_KEY_PATH"'
            }
        }*/
  }
}

