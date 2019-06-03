/**
 * Jenkinsfile which executes when the trigger job is built.
 * @author Andrew Jarombek
 * @since 6/2/2019
 */

node("master") {
    stage('saints-xctf-infrastructure') {
        build job: 'saints-xctf-infrastructure/saints-xctf-infrastructure-dev', parameters: [
            [$class: 'StringParameterValue', name: 'branchName', value: 'master']
        ]
        build job: 'saints-xctf-infrastructure/saints-xctf-infrastructure-prod', parameters: [
            [$class: 'StringParameterValue', name: 'branchName', value: 'master']
        ]
    }
}