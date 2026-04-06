SHELL := /usr/bin/env bash

.PHONY: install uninstall test lint

install:
	./install.sh

uninstall:
	./uninstall.sh

test:
	./tests/run.sh

lint:
	shellcheck install.sh uninstall.sh bin/speak bin/piper-server bin/speak-selection bin/speak-selection-debug scripts/*.sh tests/*.sh
