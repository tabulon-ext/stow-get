version=4.1.3
type=tarball
url_prefix=https://www.mercurial-scm.org/repo/hg/archive
tarball=${version}.tar.gz
configure=""
function make_cmd {
  which python
  echo $LD_LIBRARY_PATH
  make build
  python setup.py install --prefix="$STOW_DIR/$target" --force
}