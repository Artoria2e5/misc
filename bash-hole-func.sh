# foreach funcname [array-args]
#!/bin/bash
foreach(){
  [ "$1" ] || return 2
  local _fe_fun="$1" _mem
  shift
  for _mem; do "$_fe_fun" "$_mem"; done;
}
# filter funcname simple-array-name
filter(){
  [ "$2" ] || return 2
  # todo typeof check or key array saving
  declare -n _filter_arr="$2"
  declare -a _filter_tmparr=()
  local _fe_funname="_fe_$1"
  eval "${_fe_funname}(){ $(argprint "$1") \"\$1\" && _filter_tmparr+=(\"\$1\"); }"
  foreach "$_fe_funname" "${_filter_arr[@]}"
  _filter_arr=( "${_filter_tmparr[@]}" )
  unset _filter_tmparr $_fe_funname
}
g=(p q r qe)
_lamb_fl_1(){ ((${#1}==1)); }
filter _lamb_fl_1 g
unset _lamb_fl_1
declare -p g
_lamb_fe_l(){ echo "$1" | rev; }
foreach _lamb_fe_l lorem ipsum
unset _lamb_fe_l
