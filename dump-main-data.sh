#!/bin/bash
. ./env.sh
pgdump	--data-only \
		--exclude-table='article' \
		--exclude-table='outlet_list' \
		--disable-triggers \
		--format=directory \
		--file=$(data_dir) \
		--jobs=5
