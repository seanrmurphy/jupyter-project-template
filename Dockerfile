# We will run the dev_image for local development.
FROM python:3.10 as dev_image
MAINTAINER ben@denham.nz


# Uncomment to install any dependencies (install these before
# performing steps with files that may change frequently so that
# layers may be cached). Best practice for installing apt dependencies
# without saving apt-cache:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run

# USER root
# RUN apt-get update && apt-get install -y \
#         curl \
#         && rm -rf /var/lib/apt/lists/*
# USER jovyan


# A section like the following can be useful when your base image runs
# as the root user. This will create a user with the same uid and gid
# as our host user, meaning files created in the image after this step
# and during container will be owned by our user on the host.

ARG GROUP_ID=1000
ARG USER_ID=1000
RUN groupadd --gid $GROUP_ID coder
RUN useradd --uid $USER_ID --gid coder --shell /bin/bash --create-home coder
USER coder

ENV PATH=$PATH:/home/coder/.local/bin
RUN pip install poetry

RUN mkdir /home/coder/src
WORKDIR /home/coder/src

ENV JUPYTERLAB_SETTINGS_DIR=/home/coder/src/jupyterlab/config
ENV JUPYTERLAB_WORKSPACES_DIR=/home/jovyan/work/jupyterlab/workspaces

CMD ["poetry", "run", "jupyter", "lab", "--ip", "0.0.0.0"]

# The prod_image build step is an optional section that allows you to
# package your entire app into a self-contained Docker image that can
# be run on another machine. The resulting image will contain all
# notebooks, source-code, and pip-packages, but not the directories in
# .dockerignore.
FROM dev_image as prod_image
COPY . /home/coder/src
