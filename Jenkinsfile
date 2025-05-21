properties([
  parameters([
    string(name: 'AWS_ACCESS_KEY_ID', defaultValue: ''),
    string(name: 'AWS_SECRET_ACCESS_KEY', defaultValue: '')
  ])
])

pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID     = "${params.AWS_ACCESS_KEY_ID}"
    AWS_SECRET_ACCESS_KEY = "${params.AWS_SECRET_ACCESS_KEY}"
  }

  stages {
    stage('Terraform Init') {
      steps {
        sh 'terraform init -input=false'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -input=false'
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve -input=false'
      }
    }
  }
}
