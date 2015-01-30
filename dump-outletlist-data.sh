#!/bin/bash
. ./env.sh
pgdump	--data-only \
		--table='outlet_list' \
		--disable-triggers \
		--format=directory \
		--file=$(data_dir) \
		--jobs=5
