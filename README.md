# Jupyter Project Template

A Docker-based project setup for Python projects centred around
Jupyter notebooks. Ideal for data science projects.

## Features

* Run a local JupyterLab server.
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
Windows and also
[install `make`](https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058)
into Git bash, then you should be able to run this project on Windows.

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
5. Work in Python notebooks inside `notebooks/`, with the ability to
   import code from your own custom Python modules and their
   dependencies, e.g.: `from mypymodule import greeting`.

## Deployment

If you want to package up the JupyterLab server on a host that
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

**Note:** The JupyterLab server is intended for use by a single
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

To add Python module dependencies:

1. Start a shell inside the Docker container: `make run-bash`
2. Move into your module's directory: `cd mypymodule`
3. Use poetry to add the dependency: `poetry add <your-dependency>`

When `make run` is run it will alway ensure all dependencies are
installed, and you can also manually install dependencies by running:
`make deps`.

If you have poetry installed on your host, your `poetry config
cache-dir` will be mounted into the Docker container in order to avoid
re-downloading dependencies across projects.

### Linting

You can run [flake8](http://flake8.pycqa.org/en/latest/) linting on
your modules with: `make lint`.

### Testing

You can run [pytest](https://docs.pytest.org/en/latest/) unit tests
linting contained in your modules with: `make test`.

An HTML code-coverage reported will be generated for each module at:
`<module-dir>/test/coverage/index.html`.

### Type-Checking

You can run [mypy](https://mypy.readthedocs.io/en/stable/)
type-checking on your modules with: `make mypy`.

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

There are two primary ways you can work with Jupyter from Emacs:

### Driving a JupyterLab Console from Emacs

With [`jupyter-emacs`](https://github.com/nnicandro/emacs-jupyter),
you can use Emacs to run (Python or other) code in a browser-based
JupyterLab Console session that supports rich output (e.g. DataFrame
tables, plots, maps, etc.).

#### Installing

```
M-x package-refresh-contents <Enter>
M-x package-install <Enter>
jupyter
```

You may also like to add the following configuration to your
`init.el`:

```elisp
(require 'jupyter)

;; Don't display these buffers when output is added to them, since we
;; will be viewing rich output in the browser console session
(setq custom-jupyter-quiet-buffers '("*jupyter-display*" "*jupyter-output*" "*jupyter-traceback*"))
(when (not (boundp 'orig-jupyter-display-current-buffer-reuse-window))
 (setq orig-jupyter-display-current-buffer-reuse-window (symbol-function 'jupyter-display-current-buffer-reuse-window)))
(defun jupyter-display-current-buffer-reuse-window (&optional msg-type alist &rest actions)
  (when (not (member (buffer-name) custom-jupyter-quiet-buffers))
    (apply orig-jupyter-display-current-buffer-reuse-window msg-type alist actions)))

;; Add custom-jupyter-eval-sentence for evaluating contiguous blocks of code
(defun custom-jupyter-eval-sentence ()
  (interactive)
  (when-let* ((bounds (bounds-of-thing-at-point 'sentence)))
    (cl-destructuring-bind (beg . end) bounds
      (jupyter-eval-region beg end))))
(define-key jupyter-repl-interaction-mode-map (kbd "C-c C-c") #'custom-jupyter-eval-sentence)
```

#### Workflow

1. Ensure `make run` is running
2. Open your notebook in JupyterLab
3. Right-click on the notebook's tab, and select `New Console for
   Notebook`
4. Right-click anywhere in the newly opened console, and ensure that
   `Show All Kernel Activity` is checked
5. In Emacs, run: `M-x jupyter-server-list-kernels` (URL:
   http://localhost:8888; use the token provided in the output of
   `make run`)
6. In the `*jupyter-kernels*` buffer, select your running kernel
7. Open a file or buffer with code you want to execute in the console,
   and run `M-x jupyter-repl-associate-buffer`
8. Execute lines of code with:
   * `C-c C-b`: Execute the entire buffer
   * `C-x C-e`: Execute the current line or selected region
   * `C-c C-c`: Execute the current "sentence" (contiguous lines of code)
9. If you want to save some output in the notebook (e.g. a table or
   plot), add a notebook cell from JupyterLab to render that output.
10. You can even use JupyterLab's debugger to add breakpoints to
    previously run blocks of code, which will be triggered when
    re-running the same block.

### Running a Notebook

If you don't need rich outputs in your notebooks, you may prefer to
use [EIN](http://millejoh.github.io/emacs-ipython-notebook/) to
interact with notebooks solely from Emacs.

#### Installing EIN

```
M-x package-refresh-contents <Enter>
M-x package-install <Enter>
ein
```

#### Connecting EIN to your Jupyter server

1. Ensure `make run` is running.
2. `M-x ein:login` (URL: http://127.0.0.1:8888, Password: token from `make run`)
3. `M-x ein:notebooklist-open`

#### Common EIN Commands

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
