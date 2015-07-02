#!/bin/bash
# typeof _varname_
typeof(){ local _p _t _s; declare -p "$1" | read _p _t _s; echo "${_t:1}"; }
# foreach funcname [array-args]
foreach(){
	[ "$1" ] || return 2
	if [[ "$1" == λ || "$1" == lambda ]]; then
		[ "$_lambda_func" ] || return 3
		shift
		set -- "_λ_$_lambda_func" "$@"
	fi
	local _fe_fun="$1" _mem
	shift
	for _mem; do "$_fe_fun" "$_mem"; done;
}
# filter funcname simple-array-name
filter(){
	[ "$2" ] || return 2
	if [[ "$1" == λ || "$1" == lambda ]]; then
		[ "$_lambda_func" ] || return 3
		shift
		set -- "_λ_$_lambda_func" "$@"
	fi
	# todo typeof check or key array saving
	declare -n _filter_arr="$2"
	declare -a _filter_tmparr=()
	local _fe_funname="_fe_$1"
	eval "${_fe_funname}(){ $(argprint "$1") \"\$1\" && _filter_tmparr+=(\"\$1\"); }"
	foreach "$_fe_funname" "${_filter_arr[@]}"
	_filter_arr=( "${_filter_tmparr[@]}" )
	unset _filter_tmparr $_fe_funname
}
# λ func-def <command>
# VARIABLES:
# _lambda_defs=(,[[:digits:]])*,	Defined lambda funcs
# _lambda_func=[[:digits:]]*    	Current lambda funname
# _lambda_head=_λ_
# EXAMPLE:
# λ '{ ((${#1}==1)); }; echo lambda loaded' filter λ g
: ${_lambda_defs=_}
λ(){
	local _lambda_func _lambda_exit
	# Assign lambda
	while _lambda_func=$RANDOM; do
		[[ "$_lambda_defs" != *,${_lambda_func},* ]] && break
	done
	_lambda_defs+="${_lambda_func},"
	# Create the function in an evil way
	eval "_λ_$_lambda_func()$1"
	shift
	# Execute the command
	"$@"
	_lambda_exit=$?
	_lambda_defs="${_lambda_defs/${},}"
	return $_lambda_exit
}
lambda(){ λ "$@"; }
# forall funcname [array-args] => (all? funcname? array-args)
# VARIABLES: _fo_index: The first occorance found to disobey funcname.
forall(){
	[ "$2" ] || return 2
	if [[ "$1" == λ || "$1" == lambda ]]; then
		[ "$_lambda_func" ] || return 3
		shift
		set -- "_λ_$_lambda_func" "$@"
	fi
	local _fa_funname="$1" _fa_needle
	_fa_index=0
	shift
	for _fa_needle; do
		"$_fa_funname" "$_fa_needle" || break
		((++_fa_index))
	done
	((_fa_index==$#))
}
# forone funcname [array-args] => (not (all? (not funcname?) array-args))
# VARIABLES: _fo_index: The first occorance found to match funcname.
# todo: forall=fe_catch forsome=fe_find map(mapfun,oldarr,newarr) reduce(fun . args[]) λ(evalfundef . command)
g=(p q r qe)
_lamb_fl_1(){ ((${#1}==1)); }
filter _lamb_fl_1 g
unset _lamb_fl_1
declare -p g
_lamb_fe_l(){ echo "$1" | rev; }
foreach _lamb_fe_l lorem ipsum
unset _lamb_fe_l
