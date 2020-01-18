# Jupyter Project Template

A Docker-based project setup for Python projects centred around
Jupyter notebooks. Ideal for data science projects.

## Features

* Run a local JupyterHub notebook server.
* Reference custom Python modules from your notebooks for better code
  organisation.
* Includes a Makefile to organise commonly run commands.
* Runs all code inside Docker containers to minimise host
  dependencies.
* Basic setup for managing large data files.

## Dependencies

In order to run this project, you must have the following dependencies
installed on your host:

* [Docker Community Edition](https://docs.docker.com/get-docker/) (>= 17.09)
* [Docker Compose](https://docs.docker.com/compose/install/) (>= 1.17)
  (Included with Docker Desktop on Mac/Windows)
* [Make](https://www.gnu.org/software/make/) (technically optional if
  you don't mind running the commands in the Makefile directly)

**Note:** If you use [Git bash](https://git-scm.com/downloads) on
Windows and also [install `make`](https://superuser.com/a/701175) into
Git bash, then you should be able to run this project on Windows.

## Basic Usage

1. Ensure the dependencies listed above are installed.
2. Change the `BASE_IMAGE_NAME` at the top of the `Makefile`.
3. Run `make run` in this directory.
   * This will perform all Docker image build steps and dependency
     installations every time you run it, so that you can never forget
     to rebuild. The first time you run this, it make take some time
     for the base Docker image and other dependencies to be
     downloaded.
4. Browse to http://localhost:8888 and enter the token displayed in
   the terminal (or just follow the link in the terminal).
5. Work in Python notebooks, with the ability to import code from your
   own custom Python modules and their dependencies, e.g.: `from
   mypymodule import greeting`.

## Deployment

If you want to package up the Jupyter notebook server on a host that
cannot download and build Docker images (e.g. because it has no
Internet connection), you can build and export a self-contained Docker
image to move to that host:

1. Run `make export-image` on a machine that has the required Internet
   connection to download Docker images and dependencies.
2. Copy the `images/` directory to the same location within the
   project on the target host.
3. Run `make import-image` on the target host.
4. Run `make run-prod` on the target host to start the Jupyter
   notebook server in the background (it will also be configured to
   restart itself if the process dies or the machine restarts).
5. Run `make stop` to stop the background server process.

**Note:** The Jupyter notebook server is intended for use by a single
user (multiple users visiting the same notebook will cause issues). If
you wish to deploy your notebooks for use by multiple users, you may
wish to look into [JupyterHub](https://jupyter.org/hub) or
[Voilà](https://github.com/voila-dashboards/voila) (for non-editable
notebooks).

## Python Module Development

In order to better structure and share Python code between Jupyter
notebooks, you can add your code to custom Python packages/modules
contained in this directory. An example `mypymodule` is provided, but
you can add more directories - if you do, just make sure to update the
`PYTHON_MODULES` list in the `Makefile`, e.g.:
`PYTHON_MODULES=mypymodule1 mypymodule2`.

We recommend that you automatically reload your Python modules in
Jupyter notebooks so that any changes you make immediately take effect
without restarting the notebook kernel. To do so, include and run the
following cell at the top of each notebook:

```
%load_ext autoreload
%autoreload 2
```

### Dependencies

To add Python module dependencies, simply add them to the
`install_requires` list of your module's `setup.py`. They will be
installed the next time you run `make run`, or you can install them
without restarting your notebook server by running: `make deps`.

### Linting

You can run [flake8](http://flake8.pycqa.org/en/latest/) linting on
your modules with: `make lint`.

### Testing

You can run [pytest](https://docs.pytest.org/en/latest/) unit tests
linting contained in your modules with: `make test`.

An HTML code-coverage reported will be generated for each module at:
`<module-dir>/test/coverage/index.html`.

## Managing Data

It is recommended that you store your large data files in the `data/`
directory so that they are not committed to your Git repository and
not transmitted to the Docker daemon during image builds (see
[.dockerignore](#dockerignore)).

You may not want to commit the outputs of notebook cells to your Git
repository. If you have Python 3 installed, you can use
[nbstripout](https://github.com/kynan/nbstripout) to configure your
Git repository to exclude the outputs of notebook cells when running
`git add`:

1. `python3 -m pip install nbstripout nbconvert`
2. Run `nbstripout --install` in this directory (installs hooks into
   `.git`).

## Notes About Docker

### Opening a Shell

If you would like to open a bash shell inside the Docker container
running the Jupyter notebook server, use: `make bash` or `make
sudo-bash`. If `make run` is not currently running, you can instead
use `make run-bash` or `make run-sudo-bash`.

### System Dependencies and Other OS Configurations

To install system packages or otherwise alter the Docker image's
operating system, you can make changes in the Dockerfile. An example
section that will allow you to install `apt` packages is included.

### Changing the Jupyter Server Port

Change the `ports` entry in `docker-compose.yml` to:
`'YOURPORT:8888'`, then re-run `make run`.

### .dockerignore

Whenever the Docker image is rebuilt (after certain files are
changed), Docker will transmit the contents of this directory to the
Docker daemon.

To speed up build times, you should add an entry to the
`.dockerignore` file for any directories containing large files you do
not need to be included in the Docker image at build time.

### Managing Docker Image Storage

When Docker builds new versions of its images, it does not delete the
old versions. Over time, this can lead to a significant amount of disk
space being used for old versions of images that are no longer needed.

Because of this, you may wish to periodically run `docker image prune`
to delete any "dangling images" - images that aren't currently
associated with any image tags/names.

## Using Jupyter from Emacs

Did you know you can work with Jupyter notebooks from Emacs? All you
need to do is install
[EIN](http://millejoh.github.io/emacs-ipython-notebook/): `M-x
package-refresh-contents <Enter> M-x package-install <Enter> ein`

### Connecting EIN to your Jupyter server

1. Ensure `make run` is running.
2. `M-x ein:login` (URL: http://127.0.0.1:8888, Password: token from `make run`)
3. `M-x ein:notebooklist-open`

### Common EIN Commands

```
M-<enter> - Execute cell and move to next.
C-c C-c - Execute cell.
C-c C-z - Interrupt command
C-c C-x C-r - Restart session
C-<up/down> - Navigate cells.
M-<up/down> - Move cells.
C-c C-b - Insert cell below (C-a for above).
C-c C-l - Clear cell output.
C-c C-k - Delete cell.
C-c C-f - Open file.
C-c C-h - Help at cursor.
C-c C-S-l - Clear all output.
C-c C-t - Toggle cell type.
```
