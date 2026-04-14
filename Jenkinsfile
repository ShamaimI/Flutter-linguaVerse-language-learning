pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git branch: 'main',
                url: 'https://github.com/ShamaimI/Flutter-linguaVerse-language-learning.git'
            }
        }
        stage('Build Flutter Web') {
            steps {
                sh '''
                    export PATH="$PATH:/opt/flutter/bin"
                    flutter pub get
                    flutter build web --release
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker-compose -f docker-compose-jenkins.yml down || true'
                sh 'docker-compose -f docker-compose-jenkins.yml up -d'
            }
        }
    }
}
