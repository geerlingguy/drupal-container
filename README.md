# Drupal Container (Built with Ansible)

[![Build Status](https://travis-ci.org/geerlingguy/php-apache-container.svg?branch=master)](https://travis-ci.org/geerlingguy/php-apache-container) [![](https://images.microbadger.com/badges/image/geerlingguy/php-apache.svg)](https://microbadger.com/images/geerlingguy/php-apache "Get your own image badge on microbadger.com")

This project is in it's early stages. _There will be bugs!_ You may be better served using the [official Drupal Docker image](https://hub.docker.com/_/drupal/) if it meets your requirements.

This project is composed of three main parts:

  - **Ansible project**: This project is maintained on GitHub: [geerlingguy/drupal-container](https://github.com/geerlingguy/drupal-container). Please file issues, support requests, etc. against this GitHub repository.
  - **Docker Hub Image**: If you just want to use [the `geerlingguy/drupal` Docker image](https://hub.docker.com/r/geerlingguy/drupal/) in your project, you can pull it from Docker Hub.
  - **Ansible Role**: If you need a flexible Ansible role that's compatible with both traditional servers and containerized builds, check out [`geerlingguy.docker`](https://galaxy.ansible.com/geerlingguy/docker/) on Ansible Galaxy. (This is the Ansible role that does the bulk of the work in managing the Docker container.)

## Versions

Currently maintained versions include:

  - `latest`

## Standalone Usage

If you want to use the `geerlingguy/drupal` image from Docker Hub, you don't need to install or use this project at all. You can quickly build a Drupal container locally with:

    docker run -d --name=drupal -p 80:80 geerlingguy/drupal:latest /usr/sbin/apache2ctl -D FOREGROUND

You can also wrap up that configuration in a `Dockerfile` and/or a `docker-compose.yml` file if you want to keep things simple. For example:

    version: "3"
    
    services:
      php-apache:
        image: geerlingguy/drupal:latest
        container_name: drupal
        ports:
          - "80:80"
        restart: always
        # See 'Custom Drupal codebase' for instructions for volumes.
        volumes:
          - ./web:/var/www/html:rw,delegated
        command: ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

Then run:

    docker-compose up -d

Now you should be able to access the Drupal site at `http://localhost/`.

## Management with Ansible

### Prerequisites

Before using this project to build and maintain PHP images for Docker, you need to have the following installed:

  - [Docker Community Edition](https://docs.docker.com/engine/installation/) (for Mac, Windows, or Linux)
  - [Ansible](http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Build the image

Make sure Docker is running, and run the playbook to build the container image:

    ansible-playbook main.yml

Once the image is built, you can run `docker images` to see the `drupal` image that was generated.

> Note: If you get an error like `Failed to import docker-py`, run `pip install docker-py`.

### Push the image to Docker Hub

Currently, the process for updating this image on Docker Hub is manual. Eventually this will be automated via Travis CI.

  1. Log into Docker Hub on the command line:

         docker login --username=geerlingguy

  1. Tag the latest version (only if this is the latest/default version):

         docker tag [image id] geerlingguy/drupal:latest

  1. Push to Docker Hub:

         docker push geerlingguy/drupal:latest

## License

MIT / BSD

## Author Information

This container build was created in 2018 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).
