#!/bin/bash

. ./env.sh

function try_src_exec()
{
	. ${1?}
	[[ "0" -eq "$?" ]] || {
		dump_fail $? "${1} source execution failed"
	}
	return $?
}
function try_direct_exec()
{
	[[ -x "${1?}" ]] || return;
	${1} || {
		dump_fail $? "${1} execution failed"
	}
	return $?
}

function try_dump()
{
	[[ -z "$1" ]] && {
		dump_fail 10 "try_dump requires an argument"
		return $?
	}
	script_name="./${1}.sh"

	[[ -s "${script_name}" ]] || {
		dump_fail 11 "Dump script not found: ${script_name}"
		return $?
	}

	[[ -x "${script_name}" ]] && {
		try_direct_exec ${script_name} 
		return $?
	}
	try_src_exec ${script_name}
	return $?
}

try_dump
try_dump "dump-all-ddl"
try_dump "dump-article-data"
try_dump "dump-main-data"
try_dump "dump-outletlist-data"
