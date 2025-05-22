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
        sh 'rm -f terraform.tfstate terraform.tfstate.backup'
        sh 'terraform init -reconfigure'
      }
    }

    stage('Terraform Destroy') {
            steps {
                // Запитати підтвердження (опціонально)
                input message: 'Are you sure you want to destroy the infrastructure?', ok: 'Destroy'

                // Виконати знищення інфраструктури
                sh 'terraform destroy -auto-approve'
    }
  }
}
}
