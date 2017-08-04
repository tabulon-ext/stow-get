inst_type=github
lib_dep=(openssl)
get_version
directory=${package}-${version#release-}
openssl_path=$(which openssl 2>/dev/null)
if [ -n "$openssl_path" ];then
  openssl_dir="${openssl_path%/bin/openssl}"
elif [ -d /usr/local/opt/openssl ];then
  openssl_dir="/usr/local/opt/openssl"
elif [ -d /usr/local/openssl ];then
  openssl_dir="/usr/local/openssl"
elif [ -d /usr/opt/openssl ];then
  openssl_dir="/usr/opt/openssl"
elif [ -d /opt/openssl ];then
  openssl_dir="/opt/openssl"
fi
if [ -n "$openssl_dir" ];then
  configure_flags="LDFLAGS='-L${openssl_dir}/lib' CPPFLAGS='-I${openssl_dir}/include'"
fi
