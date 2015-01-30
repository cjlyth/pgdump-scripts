#!/bin/bash

# exec 4<&0
# exec < $1            # Will read from input file.

# exec 7>&1
# exec > $2            # Will write to output file.
#                      # Assumes output file writable (add check?).


# exec 3>&1 4>&2 1> >(tee >(logger -i -t 'my_script_tag') >&3) 2> >(tee >(logger -i -t 'my_script_tag') >&4)
# trap 'cleanup' INT QUIT TERM EXIT

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-

# Open STDOUT as $LOG_FILE file for read and write.
exec 1<>$LOG_FILE

# Redirect STDERR to STDOUT
exec 2>&1

echo "This line will appear in $LOG_FILE, not 'on screen'"


cleanup() {
	cat <<-EOF
	 *-----------------------------------------------------------------------
	 * Backup exiting
	 ************************************************************************
	EOF	
}


cat <<-EOF
 ************************************************************************
 * Backup starting 
 *-----------------------------------------------------------------------
EOF

function dump_fail()
{
	cat >&2 <<-EOWARN
		 * Backup FAILED: ${@}!!!
		 ************************************************************************
	EOWARN
	return $1
}
function pgdump_debug()
{
	printf ' *%25s => %-40s\n' "${@}"
}

function do_time()
{
	[[ -z "$1" ]] || {
		# TODO: mkdir -p $(dirname ${1})
		# 	or: mkdir -p ${1%/*}
		time_opts="--output=${1} ${time_opts}"
		time_opts="--append ${time_opts}"
		time_opts="--verbose ${time_opts}"
	}
	/usr/bin/time ${time_opts} ${@}
	return $?
}

# printf '%s%(%Y%m%d)T.XXXXXXXXXX' "${WORK_DIR}" -1

function tmp_file()
{
	tmp_opts="${@} ${tmp_opts}"
	tmp_opts="--dry-run ${tmp_opts}"
	[[ -z "$WORK_DIR" ]] || {
		tmp_opts="--tmpdir=${WORK_DIR} ${tmp_opts}"
	}
	mktemp ${tmp_opts}
	# "${RUN_DAY}-${PGDATABASE:-pg}-XXXXX"
}

function data_file()
{

	pgdump_debug "tempfile" " "
	# tmp_file
	# pgdump_debug "temp file" "$_" 
	mktemp	
}

function data_dir()
{
	tmp_file --directory
	pgdump_debug "temp dir" "$_" 
}


function pgdump()
{
	[[ -s "$RUN_DIR/$RUN_SCRIPT" ]] || {
		dump_fail 13 "Required file is missing or empty: $RUN_DIR/$RUN_SCRIPT"
		return $?
	}
	echo "${@}"
	# exec pg_dump "$@"
	return $?
}

NULL="<NULL>"
script_name_regex='/[[:punct:]]+/{s/([[:punct:]]+(sh\b)?\n?)+/\n/g}'

PGHOSTADDR="172.17.0.2"
PGPORT="5432"
PGUSER="postgres"
PGPASSWORD="postgres"
	
PGDATABASE="publicrelay"
pgdump_debug "PGDATABASE" "${PGDATABASE:-$NULL}"

RUN_DAY="$(date +%Y%m%d)"
pgdump_debug    "RUN_DAY" "${RUN_DAY:-$NULL}"

RUN_DIR="$(pwd)"
pgdump_debug    "RUN_DIR" "${RUN_DIR:-$NULL}"

RUN_SCRIPT="${BASH_SOURCE[1]##*/}"
pgdump_debug "RUN_SCRIPT" "${RUN_SCRIPT:-$NULL}"

name_parts=($(sed -zr $script_name_regex <<< ${RUN_SCRIPT?}))
pgdump_debug   "name_parts" "${name_parts[*]:-$NULL}"

DUMP_SCOPE="${name_parts[@]:(-2):1}"
pgdump_debug "DUMP_SCOPE" "${DUMP_SCOPE:-$NULL}"

DUMP_TYPE="${name_parts[@]:(-1)}"
pgdump_debug  "DUMP_TYPE" "${DUMP_TYPE:-$NULL}"

pgdump_debug   "WORK_DIR" "${WORK_DIR:-$NULL}"

