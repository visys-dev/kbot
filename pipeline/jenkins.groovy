pipeline {
    agent any

    parameters {
        choice(
            name: 'OS',
            choices: ['linux', 'darwin', 'windows'],
            description: 'Target operating system'
        )

        choice(
            name: 'ARCH',
            choices: ['amd64', 'arm64'],
            description: 'Target architecture'
        )

        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip running tests'
        )

        booleanParam(
            name: 'SKIP_LINT',
            defaultValue: false,
            description: 'Skip running linter'
        )
    }

    stages {
        stage('Info') {
            steps {
                sh '''
                    echo "Target OS:   ${OS}"
                    echo "Target ARCH: ${ARCH}"
                    echo "Git commit:  $(git rev-parse --short HEAD)"
                    go version
                '''
            }
        }

        stage('Lint') {
            when {
                expression {
                    return !params.SKIP_LINT
                }
            }
            steps {
                sh 'make lint'
            }
        }

        stage('Test') {
            when {
                expression {
                    return !params.SKIP_TESTS
                }
            }
            steps {
                sh 'make test'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    make build GOOS=${OS} GOARCH=${ARCH}
                '''
            }
        }

        stage('Artifact') {
            steps {
                archiveArtifacts(
                    artifacts: 'kbot-*',
                    fingerprint: true
                )
            }
        }
    }

    post {
        success {
            echo "Build completed successfully: ${params.OS}/${params.ARCH}"
        }

        failure {
            echo "Build failed: ${params.OS}/${params.ARCH}"
        }

        always {
            sh 'git status --short || true'
        }
    }
}