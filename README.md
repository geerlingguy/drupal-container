# Drupal Container (Built with Ansible)

[![Build Status](https://travis-ci.org/geerlingguy/drupal-container.svg?branch=master)](https://travis-ci.org/geerlingguy/drupal-container) [![](https://images.microbadger.com/badges/image/geerlingguy/drupal.svg)](https://microbadger.com/images/geerlingguy/drupal "Get your own image badge on microbadger.com")

This project is composed of three main parts:

  - **Ansible project**: This project is maintained on GitHub: [geerlingguy/drupal-container](https://github.com/geerlingguy/drupal-container). Please file issues, support requests, etc. against this GitHub repository.
  - **Docker Hub Image**: If you just want to use [the `geerlingguy/drupal` Docker image](https://hub.docker.com/r/geerlingguy/drupal/) in your project, you can pull it from Docker Hub.
  - **Ansible Role**: If you need a flexible Ansible role that's compatible with both traditional servers and containerized builds, check out [`geerlingguy.docker`](https://galaxy.ansible.com/geerlingguy/docker/) on Ansible Galaxy. (This is the Ansible role that does the bulk of the work in managing the Docker container.)

## Versions

Currently maintained versions include:

  - `latest`

## Standalone Usage

The easiest way to use this Docker image is to place the `docker-compose.yml` file included with this project in your Drupal site's root directory, then customize it to your liking, and run:

    docker-compose up -d

You should be able to access the Drupal site at `http://localhost/`.

The following environment variables affect what's written to the database connection settings file, and the defaults follow the variable name:

  - `DRUPAL_DATABASE_NAME=drupal`
  - `DRUPAL_DATABASE_USERNAME=drupal`
  - `DRUPAL_DATABASE_PASSWORD=drupal`
  - `DRUPAL_DATABASE_HOST=mysql`
  - `DRUPAL_DATABASE_PORT=3306`

To get your Drupal codebase into the container, you can either `COPY` it in using a Dockerfile, or mount a volume (e.g. when using the image for development). The included `docker-compose.yml` file assumes you have a Drupal codebase at the path `./web`, but you can customize the volume mount to point to wherever your Drupal docroot exists.

### Include the Database connection settings

Since it's best practice to _not_ include secrets like database credentials in your codebase, this Docker container places connection details into special settings files, which you can include in your Drupal site's `settings.php` file.

To set up the database connection, include the following lines at the end of your Drupal site's `settings.php` file:

    if (file_exists('/var/www/settings/database.php')) {
      require '/var/www/settings/database.php';
    }

## Management with Ansible

### Prerequisites

Before using this project to build and maintain Drupal images for Docker, you need to have the following installed:

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
