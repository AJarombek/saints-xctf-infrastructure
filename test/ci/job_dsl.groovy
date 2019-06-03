/**
 * Job DSL Script for the CI trigger job.
 * @author Andrew Jarombek
 * @since 6/2/2019
 */

pipelineJob('saints-xctf-infrastructure-trigger') {
    triggers {
        githubPush()
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        name('origin')
                        url('git@github.com:AJarombek/saints-xctf-infrastructure.git')
                        credentials('865da7f9-6fc8-49f3-aa56-8febd149e72b')
                    }
                    branch('master')
                }
                scriptPath('test/ci/Jenkinsfile.groovy')
            }
        }
    }
}