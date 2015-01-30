#!/bin/bash
. ./env.sh
pgdump	--data-only \
		--table='article' \
		--disable-triggers \
		--format=directory \
		--file=$(data_dir) \
		--jobs=5
