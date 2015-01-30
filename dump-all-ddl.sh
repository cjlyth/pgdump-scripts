#!/bin/bash
. ./env.sh
pgdump	--create --schema-only \
		--clean --if-exists \
		--no-owner --no-acl \
		--no-tablespaces \
		--format=plain \
		--file=$(data_file)

