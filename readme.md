# Spring PetClinic with Docker

This is a fork of the [Spring PetClinic Application](https://github.com/spring-projects/spring-petclinic). The scope is to use a Jenkins pipeline to build, test and package the PetClinic code as a Docker container.

## Changes 

### Jenkins

Jenkins will be used to execute the pipeline to build and package the PetClinic application as Docker container. Jenkins can be installed locally or run as a Docker container, the latter is the approach used for this project due to its better flexibility and portability.

To build a Docker image of the PetClinic application using a Jenkins pipeline, Docker must be available in the Jenkins container. This is also known as Docker-in-Docker, where Jenkins runs as a Docker container and the container itself is running Docker to perform additional tasks (build image).

#### Build and Run

The official release of Jenkins available  on DockerHub ([jenkins/jenkins](https://hub.docker.com/r/jenkins/jenkins)) doesn't include Docker. The `Dockerfile` available in the `.jenkins` folder leverages the official `jenkins/jenkins` image, with the addition of the latest Docker CE version.
The following commands build the `custom-jenkins-docker` image and run it with a volume to persist the Jenkins data:
```
cd .jenkins
docker image build -t custom-jenkins-docker .
docker run -d -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home custom-jenkins-docker
```
The Jenkins server is now available at http://localhost:8080/

#### First Run

When Jenkins runs for the first time, it displays on the output console the admin credentials that can be used to login on Jenkins. After login, the server offers a page to create the admin user (username, password, full name, email) and one to select the plugins to install. The admin credentials (username and password) chosen as part of the initial setup will be used for any future login on the server.

The [Docker Pipeline](https://plugins.jenkins.io/docker-workflow/) plugin allows building, testing, and using Docker images from Jenkins Pipeline projects. It can be enabled on Manage Jenkins -> Manage Plugins -> Available Plugins -> search for Docker Pipeline and click install.

#### Pipeline

The Jenkins pipeline for the PetClinic application is defined as code and it is available in `.jenkins/Jenkinsfile`. The pipeline consists of the following steps:

* Get the source code of the project from GitHub
* Compile and run the tests
* Create the Docker image

The following steps explains how to create a pipeline in Jenkins based on the `Jenkinsfile`:
1. From the Jenkins Dashboard, click on `New Item`
2. Insert a name for the item and select the type `Pipeline`, click `OK`
3. [optional] Add a description of the pipeline
4. [optional] Select the `GitHub project` option and enter the URL of the GitHub repository. This is useful to associate the pipeline with the corresponding GIT repo.
5. In the pipeline section, select the option `Pipeline script from SCM` and configure as follows:
    * SCM: GIT
    * Insert the repository URL
    * Branch Specifier: main
    * Script Path: .jenkins/Jenkinsfile
6. Click Save

### Docker

The `Dockerfile` available in the root of the project describes the multi-stage build for the PetClinic application (build, package). 

The first stage uses the [openjdk](https://hub.docker.com/_/openjdk) image as starting point, then it adds the source code of the application and the relative Maven resources. The Maven dependencies are cached to avoid re-downloads in case of subsequent builds. The outcome of this stage is the application compiled as a `.jar` file stored in the `target` folder.

The second stage copies the application `.jar` file in the container and it exposes it on the port 8080.

## How to Run the Project

A prerequisite to run the project is to configure and run Jenkins (Docker-in-Docker) as explained in the [Jenkins](#jenkins) section. Please use the following steps to complete the process:

1. Login on Jenkins (http://localhost:8080/)
2. Open the pipeline previously created ([Jenkins](#jenkins))
3. Click on `Build Now`
4. Click on the new build number from the `Build History` in the bottom left corner of the page
5. Click on `Console Output` to show the actions executed by the pipeline and wait for its completion (Finished: SUCCESS)
6. Execute the following commands to verify the new `petclinic` image is available on Docker and to run it:
```
docker images
docker run -d -p 8081:8080 petclinic 
```

The PetClinic application will be available at http://localhost:8081/

### Docker Image

The Docker image of the PetClinic application can be saved, loaded on a different host, executed with the following commands:

```
docker save petclinic > petclinic.tar
docker load < petclinic.tar
docker run -d -p 8081:8080 petclinic 
```

The PetClinic Docker image is available on [DockerHub](https://hub.docker.com/r/carmineacanfora/petclinic) and it can be pulled and executed as follows:

```
docker pull carmineacanfora/petclinic
docker run -d -p 8081:8080 carmineacanfora/petclinic 
```