
##### old env scripts

```
function parse_run_qualifier()
{
	[[ -z "$1" ]] && { return 1; }
	script_name_regex='/[[:punct:]]+/{s/([[:punct:]]+(sh\b)?\n?)+/\n/g}'
	script_name_parts=($(sed -zr $script_name_regex <<< $1))
	echo "${script_name_parts[@]:(-1)}"
}
```