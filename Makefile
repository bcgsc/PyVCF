.PHONY:
	buildout
	clean
	clean-build
	clean-pyc
	clean-test
	dist
	help
	install
	install_dev
	lint
	release
	venv

.DEFAULT_GOAL := help

name=vcf
linelen=100
gsc_pypi=https://pypi.bcgsc.ca/gsc/packages
gsc_pypi_dev=https://devpi.bcgsc.ca/gsc/packages

venv: ## setup a Python virtual environment
	/gsc/software/linux-x86_64-centos7/python-3.9.2/bin/python3 -m venv venv
	venv/bin/pip install -U pip
	venv/bin/pip install -U zc.buildout setuptools wheel

install: clean venv ## install the package to the active Python's site-packages
	venv/bin/pip install -U -e . --index-url $(gsc_pypi)
	venv/bin/buildout

install-dev: clean venv ## install with dev tools and updates
	venv/bin/pip install -U pip
	venv/bin/pip install -U zc.buildout setuptools twine wheel
	venv/bin/pip install -U -e .[dev] --index-url $(gsc_pypi)
	venv/bin/buildout

release: dist ## package and upload a release
	venv/bin/twine upload dist/* --repository-url $(gsc_pypi)
	venv/bin/pip install -e . -U --index-url $(gsc_pypi)
	venv/bin/buildout

dist: venv clean ## builds source and wheel package
	venv/bin/pip install -U zc.buildout setuptools twine wheel
	venv/bin/python setup.py sdist
	venv/bin/python setup.py bdist_wheel
	# test on devpi
	venv/bin/twine upload dist/* --repository-url $(gsc_pypi_dev)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -rf bin/
	rm -fr parts/
	rm -rf eggs/
	rm -rf develop-eggs/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -fr {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

help:  ## show this message and exit
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[32m%-13s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
