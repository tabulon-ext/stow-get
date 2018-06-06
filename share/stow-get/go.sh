inst_type=tarball
get_latest () {
  local output_detail="${1:-0}"
  local url="https://golang.org/dl/"
  local html="$(get_page "$url")"
  version=$(grep linux-amd64.tar.gz a|grep downloadBox|cut -d "/" -f 5|cut -d "." -f1,2,3|sed 's/go//')
  if [ "$output_detail" -eq 1 ];then
    printf "%15s %8s \n" $package $version
  fi
}

urlprefix="https://dl.google.com/go"
if [[ "$OSTYPE" =~ linux ]] || [[ "$OSTYPE" =~ cygwin ]];then
  tarball=${package}${version}.linux-amd64.tar.gz
elif [[ "$OSTYPE" =~ darwin ]];then
  #tarball=${package}${version}.darwin-amd64.pkg
  echo Cant install go for OSX by stow-get
  exit 1
fi
make_cmd () {
  execute mkdir -p "$stow_dir" && execute cp -r . "$stow_dir/$target"
}