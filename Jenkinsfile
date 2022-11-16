pipeline {
  agent {
    label "sdk"
  }
  environment {
      NPM_REPO_NAME = "purescript-presto-dom"
  }

  stages {
    stage('Checkout') {
        steps {
            scmSkip(deleteBuild: false, skipPattern:'.*\\[skip ci\\].*')
            script {
              if (sh(script: "git log -1 --pretty=%B | grep -F -ie '[skip ci]' -e '[ci skip]'", returnStatus: true) == 0) {
                currentBuild.result = 'ABORTED'
                error 'Aborting because commit message contains [skip ci]'
              }
            }
        }
    }

    stage("npm/bower install") {
      steps {
        script {
          sh ("npm config set package-lock=false; npm i")
          sh ("bower i")
        }
      }
    }

    stage("PS compilation") {
      steps {
        script {
          // build packages to ensure compilation / tests work fine before updating version
          sh ("npm run compile")
        }
      }
    }

    stage("npm release") {
      steps {
        script {
          sh ("npx semantic-release --debug")
        }
      }
    }
  }
}
