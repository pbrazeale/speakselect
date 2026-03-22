SHELL := /usr/bin/env bash

.PHONY: install uninstall test lint

install:
	./install.sh

uninstall:
	./uninstall.sh

test:
	./scripts/test-voice.sh

lint:
	shellcheck install.sh uninstall.sh bin/speak bin/speak-selection scripts/*.sh
