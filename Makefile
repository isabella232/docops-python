# =============================================================================
# Make
# =============================================================================

.EXPORT_ALL_VARIABLES:

# ANSI formatting
BOLD = [1m
RESET = [0m

.DEFAULT_GOAL = help

# $(call print-target)
define print-target
@ printf "\e$(BOLD)make %s\e$(RESET)\n" "$$(echo $@ | sed 's,.stamp,,')"
endef

# $(call print-target-list)
define print-target-list
@ grep -E '^.PHONY:' $(MAKEFILE_LIST) | grep "#" | \
	sed -E "s,[^:]+: ([a-z-]+) # (.*),  \x1b$(BOLD)\1\x1b$(RESET)#\2," | \
	column -t -s '#'
endef

# Primary targets
# =============================================================================

# help
# -----------------------------------------------------------------------------

.PHONY: help # Print this help message and exit
help:
	@ printf '%s\n\n' "Usage: make [target]"
	@ printf '%s\n\n' 'Available targets:'
	$(call print-target-list)

# check
# -----------------------------------------------------------------------------

.PHONY: bootstrap # Bootstrap the project
bootstrap:

# check
# -----------------------------------------------------------------------------

.PHONY: check # Run all integration checks
check:

# check-lint
# -----------------------------------------------------------------------------

check: check-lint
.PHONY: check-lint # Lint project files
check-lint: bootstrap

# check-test
# -----------------------------------------------------------------------------

check: check-test
.PHONY: check-test # Test the Python package
check-test: bootstrap
	# TODO

# Bootstrap targets
# =============================================================================

# install
# -----------------------------------------------------------------------------

bootstrap: poetry-install
.PHONY: poetry-install
poetry-install:
	$(call print-target)
	poetry install

# Lint targets
# =============================================================================

# docops-general
# -----------------------------------------------------------------------------

DOCOPS_GENERAL_TARGETS = \
	docops-run-ec \
	docops-run-lintspaces \
	docops-run-prettier \
	docops-run-yamllint \
	docops-run-shellcheck \
	docops-run-shfmt \
	docops-run-fdupes

check-lint: docops-general
.PHONY: docops-general
docops-general:
	$(call print-target)
	@ $(MAKE) --no-print-directory $(DOCOPS_GENERAL_TARGETS)

# docops-assets
# -----------------------------------------------------------------------------

DOCOPS_ASSETS_TARGETS = \
	docops-run-good-filenames \
	docops-run-rm-unused-assets \
	docops-run-optipng

check-lint: docops-assets
.PHONY: docops-assets
docops-assets:
	$(call print-target)
	@ $(MAKE) --no-print-directory $(DOCOPS_ASSETS_TARGETS)

# docops-markup
# -----------------------------------------------------------------------------

DOCOPS_MARKUP_TARGETS = \
	docops-run-rm-unused-docs \
	docops-run-markdownlint \
	docops-run-html-entities \
	docops-run-inline-html \
	docops-run-markdown-link-check \
	docops-run-brok

check-lint: docops-markup
.PHONY: docops-markup
docops-markup:
	$(call print-target)
	@ $(MAKE) --no-print-directory $(DOCOPS_MARKUP_TARGETS)

# docops-style
# -----------------------------------------------------------------------------

DOCOPS_STYLE_TARGETS = \
	docops-run-update-vocab \
	docops-run-cspell \
	docops-run-misspell \
	docops-run-textlint \
	docops-run-vale

check-lint: docops-style
.PHONY: docops-style
docops-style:
	$(call print-target)
	@ $(MAKE) --no-print-directory $(DOCOPS_STYLE_TARGETS)

# black
# -----------------------------------------------------------------------------

check-lint: black
.PHONY: black
black:
	$(call print-target)
	poetry run black --quiet --check .

# black
# -----------------------------------------------------------------------------

check-lint: isort
.PHONY: isort
isort:
	$(call print-target)
	poetry run isort --profile black --check src

# pydocstyle
# -----------------------------------------------------------------------------

check-lint: pydocstyle
.PHONY: pydocstyle
pydocstyle:
	$(call print-target)
	poetry run pydocstyle

# flake8
# -----------------------------------------------------------------------------

check-lint: flake8
.PHONY: flake8
flake8:
	$(call print-target)
	poetry run flake8 src/**/*

# pylint
# -----------------------------------------------------------------------------

check-lint: pylint
.PHONY: pylint
pylint:
	$(call print-target)
	poetry run pylint --output-format=colorized --score=n src

# vulture
# -----------------------------------------------------------------------------

check-lint: vulture
.PHONY: vulture
vulture:
	$(call print-target)
	poetry run vulture src

# bandit
# -----------------------------------------------------------------------------

check-lint: bandit
.PHONY: bandit
bandit:
	$(call print-target)
	poetry run bandit --quiet --recursive src

# dodgy
# -----------------------------------------------------------------------------

check-lint: dodgy
.PHONY: dodgy
dodgy:
	$(call print-target)
	chronic poetry run dodgy

# pyroma
# -----------------------------------------------------------------------------

check-lint: pyroma
.PHONY: pyroma
pyroma:
	$(call print-target)
	poetry run pyroma .

# TODO: code similarity checks

# Pattern targets
# =============================================================================

docops-run-%:
	poetry run docops run $(*)
