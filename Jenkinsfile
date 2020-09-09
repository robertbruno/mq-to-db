node {
    def image
    def version
    def image_name = "christiangda/mq-to-db"

	try{

    	stage ('Checkout') {
    		sh "rm -rf *"
    		checkout scm
            version = sh(
                returnStdout: true,
                script: "git rev-parse --abbrev-ref HEAD"
            ).trim()
    	}

    	stage ('Test') {
			docker.withServer('unix:///var/run/docker.sock') {
                image= docker.image("golang")
                image.inside(){
                    sh "make go-test"
                }
			}
		}

		stage ('Build') {
            image= docker.image("golang")
            image.inside(){
                sh "make"
                sh "make container-build"
            }

		}

    	stage ('Push') {
            // push d docker image to registry
            sh "docker tag ${image_name}:${version} registry.sigis.co.ve/${image_name}:${version}"
            sh "docker tag ${image_name}:${version} registry.sigis.co.ve/${image_name}:${version}"
    	}

		currentBuild.result = 'SUCCESS'
	} catch (err) {
		currentBuild.result = 'FAILURE'
		echo err.toString()
	} finally {
		step([$class: 'Mailer',
			notifyEveryUnstableBuild: true,
			recipients: "${gitlabUserEmail}, ${DEFAULT_MAIL}",
			sendToIndividuals: true]
		)
	}
}
