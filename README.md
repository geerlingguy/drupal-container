# Drupal Container (Built with Ansible)

[![CI](https://github.com/geerlingguy/drupal-container/workflows/Build/badge.svg?branch=master&event=push)](https://github.com/geerlingguy/drupal-container/actions?query=workflow%3ABuild) [![Docker pulls](https://img.shields.io/docker/pulls/geerlingguy/drupal)](https://hub.docker.com/r/geerlingguy/drupal/)

This project is composed of three main parts:

  - **Ansible project**: This project is maintained on GitHub: [geerlingguy/drupal-container](https://github.com/geerlingguy/drupal-container). Please file issues, support requests, etc. against this GitHub repository.
  - **Docker Hub Image**: If you just want to use [the `geerlingguy/drupal` Docker image](https://hub.docker.com/r/geerlingguy/drupal/) in your project, you can pull it from Docker Hub.
  - **Ansible Role**: If you need a flexible Ansible role that's compatible with both traditional servers and containerized builds, check out [`geerlingguy.docker`](https://galaxy.ansible.com/geerlingguy/docker/) on Ansible Galaxy. (This is the Ansible role that does the bulk of the work in managing the Docker container.)

## Versions

Currently maintained versions include:

  - `latest`
  - `latest-arm64`
  - `latest-arm32v7`

## Standalone Usage

The easiest way to use this Docker image is to place the `docker-compose.yml` file included with this project in your Drupal site's root directory, then customize it to your liking, and run:

    docker-compose up -d

You should be able to access the Drupal site at `http://localhost/`, and if you're installing the first time, the Drupal installer UI should appear. Follow the directions and you'll end up with a brand new Drupal site!

### Automatic Drupal codebase generation

The image downloads Drupal into `/var/www/html` if you don't have a Drupal codebase mounted into that path by default.

You can override this behavior (if, for example, you are sharing your codebase into `/var/www/html/web` or elsewhere) by setting the environment variable `DRUPAL_DOWNLOAD_IF_NOT_PRESENT=false`.

There are three methods you can use to generate a Drupal codebase if you don't have one mounted into this container (or `COPY`ed into the container via `Dockerfile`):

  - `DRUPAL_DOWNLOAD_METHOD=tarball` (default): Downloads the latest tarball version of Drupal core.
  - `DRUPAL_DOWNLOAD_METHOD=git`: Clones Drupal from the git source, with options:
    - `DRUPAL_CLONE_URL`: The URL from which Drupal is cloned.
    - `DRUPAL_CLONE_BRANCH`: The branch that is checked out.
  - `DRUPAL_DOWNLOAD_METHOD=composer`: Creates a new Drupal project using `composer create-project`. If using this method, you should also override the following variables:
    - `DRUPAL_PROJECT_ROOT=/var/www/html`
    - `APACHE_DOCUMENT_ROOT=/var/www/html/web`

### Drupal codebase

To get your Drupal codebase into the container, you can either `COPY` it in using a Dockerfile, or mount a volume (e.g. when using the image for development). The included `docker-compose.yml` file assumes you have a Drupal codebase at the path `./web`, but you can customize the volume mount to point to wherever your Drupal docroot exists.

If you don't supply a Drupal codebase in the container in `/var/www/html`, this container's `docker-entrypoint.sh` script will download Drupal for you (using the `DRUPAL_DOWNLOAD_VERSION`). By default the image uses the latest development release of Drupal, but you can override it and install a specific version by setting `DRUPAL_DOWNLOAD_VERSION` to that version number (e.g. `8.5.3`).

### Settings in `settings.php`

Since it's best practice to _not_ include secrets like database credentials in your codebase, this Docker container recommends putting connection details into runtime environment variables, which you can include in your Drupal site's `settings.php` file via `getenv()`.

For example, to set up the database connection, pass settings like `DRUPAL_DATABASE_NAME`:

    $databases['default']['default'] = [
      'driver' => 'mysql',
      'database' => getenv('DRUPAL_DATABASE_NAME'),
      'username' => getenv('DRUPAL_DATABASE_USERNAME'),
      'password' => getenv('DRUPAL_DATABASE_PASSWORD'),
      'host' => getenv('DRUPAL_DATABASE_HOST'),
      'port' => getenv('DRUPAL_DATABASE_PORT'),
    ];

You may also want to set a `DRUPAL_HASH_SALT` environment variable to drive the `$settings['hash_salt']` setting.

### Custom Apache document root

The default Apache document root is `/var/www/html`. If your codebase needs to use a different docroot (e.g. `/var/www/html/web` for Composer-built Drupal projects), you should set the environment variable `APACHE_DOCUMENT_ROOT` to the appropriate directory, and the container will change the docroot when it starts up.

## Management with Ansible

### Prerequisites

Before using this project to build and maintain Drupal images for Docker, you need to have the following installed:

  - [Docker Community Edition](https://docs.docker.com/engine/installation/) (for Mac, Windows, or Linux)
  - [Ansible](http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Build the image

Make sure Docker is running, and run the playbook to build the container image:

    ansible-playbook main.yml
    
    # Or just build one platform version (e.g. x86):
    ansible-playbook main.yml --extra-vars "{build_amd64: true, build_arm64: false, build_arm32: false}"

Once the image is built, you can run `docker images` to see the `drupal` image that was generated.

> Note: If you get an error like `Failed to import docker-py`, run `pip install docker-py`.

If you want to quickly run the image and test that the `docker-entrypoint.sh` script works to grab a copy of the Drupal codebase, run it with:

    docker run -d -p 80:80 -v $PWD/web:/var/www/html:rw,delegated geerlingguy/drupal

Then visit [http://localhost/](http://localhost/), and (after Drupal is downloaded and expanded) you should see the Drupal installer! You can drop the volume mount (`-v`) for a much faster startup, but then the codebase is downloaded and stored inside the container, and will vanish when you stop it.

### Push the image to Docker Hub

Currently, the process for updating this image on Docker Hub is manual. Eventually this will be automated via Travis CI.

  1. Log into Docker Hub on the command line:

         docker login --username=geerlingguy

  1. Push to Docker Hub:

         docker push geerlingguy/drupal:latest
         docker push geerlingguy/drupal:latest-arm64
         docker push geerlingguy/drupal:latest-arm32v7

## License

MIT / BSD

## Author Information

This container build was created in 2018 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).
