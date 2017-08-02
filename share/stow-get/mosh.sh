inst_type=github
user=mobile-shell
bin_dep=(automake autoconf)
lib_dep=(protobuf ncurses)
function before_configure {
  ./autogen.sh
}
function get_latest {
  local output_detail="${1:-0}"
  get_github_latest 0
  version="${version#mosh-}"
  if [ "$output_detail" -eq 1 ] && [ "$version" != "" ];then
    printf "%15s %8s\n" "$package" "$version"
  fi
}
ncurses_check=$(check_lib libncurses 2)
if [ -n "ncurses_check" ];then
  configure_flags="CPPFLAGS=\"-I$(dirname $ncurses)/include\" LDFLAGS=\"-L$ncurses_check\""
fi
