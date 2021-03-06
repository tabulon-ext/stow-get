# stow-get

[![Build Status](https://travis-ci.org/rcmdnk/stow-get.svg?branch=master)](https://travis-ci.org/rcmdnk/stow-get)

Package manager with stow.

## Preparation

Set your `PATH`and `LD_LIBRARY_PATH` (and `PYTHONPATH`, if necessary) for the stow directory.

Default installation directory is:

    $HOME/usr/local/

Therefore, set like:

    export STOW_TOP=$HOME/usr/local
    export PATH=$STOW_TOP/bin:$PATH
    export LD_LIBRARY_PATH=$STOW_TOP/lib64:$STOW_TOP/lib:$LD_LIBRARY_PATH
    export PYTHONPATH=$STOW_TOP/lib64:$STOW_TOP/lib:$PYTHONPATH

## Installation

stow-get can be installed by using curl:
You can also use an install script on the web like:

    $ curl -fsSL https://raw.github.com/rcmdnk/stow-get/install/install.sh| bash

This will install stow-get in `$HOME/usr/local`

If you want to install other directory, do like:

    $ curl -fsSL https://raw.github.com/rcmdnk/stow-get/install/install.sh|  prefix=/usr/local bash

Or, simply download (or git clone) the script and set where you like.

## Usage

To install package, do like:

    $ stow-get install vim

Available packages can be found by:

    $ stow-get packages

For [GNU Project](https://www.gnu.org/gnu/thegnuproject.html) packages,
you can install them even if there is no configuration file (i.e. not found in `stow-get packages`).
To install these packages, do like:

    $ stow-get install -t gnu wdiff

To uninstall, do like:

    $ stow-get uninstall vim

## Personal configuration file

Personal settings can be set by **$HOME/.stow-get**.

If you use **install.sh**, you will have **.stow-get** like:

    set_inst_dir /home/USER/usr/local

`set_inst_dir` sets installed directory (**inst_dir**).
Substances of packages for stow are placed in **$inst_dir/stow** (**stow_dir**).

Default directory for package configuration files is **/PATH/TO/stow-get/../share/stow-get**.

If you have own package configuration files, set the directory like:

    conf_dir=(/PATH/TO/YOUR/CONFIGURATION/DIRECTORY ${conf_dir[@]})

`conf_dir` is an array of package configuration directories.

If you set **packages** variable in your configuration file like:

    packages=(git screen vim)

you can easily install them by:

    $ stow-get install

## Package configuration file

All configuration file must have a name of `<package>.sh`.

Following parameters can be set as shell script.

|Parameter|Description|Default|
|:-:|:-|:-|
|inst_type| Type of installation. Available types are: `gnu`, `tarball`, `github` or `github_direct`. This parameter is mandatory.|`gnu`|
|version|Version of th package.|`""`|
|target_postfix|By default, a package is installed in `$stow_dir/<package>-STOW-<version>`(=`$stow_dir/$target`).<br>If `target_postfix` is defined, a directory name is changed to `<package>-STOW-<target_postfix>`.|`""`|
|tarball|tarball name.|`<package>-<version>.tar.gz`|
|url_prefix| URL where tarball file is placed.|For gnu: `http://ftp.gnu.org/gnu/<package>`. <br>For github: `https://github.com/<package>/<package>/archive`|
|configure_file|Configure command. Most of packages have `configure` file to be executed first.|`./configure`|
|config_options|Options for `configure` command.<br>Note: `--prefix="$stow_dir/$target/"` (where the package substance is installed) option is automatically added if `configure` is executed.|`""`|
|bin_dep|Array of depending executable packages.<br>If the package and executable are the same name, just put the name. Otherwise put `<exe>_package_<package>`.<br>e.g. `lib_dep=(my-exe exe-name_package_package-name)`|`()`|
|lib_dep|Array of depending library packages.<br>If the library file has such `lib<package>.so`, just put the package name. Otherwise put `<lib>_package_<package>`.<br>e.g. `lib_dep=(my-lib lib-name_package_package-name)`|`()`|

Followings are function which can be re-assigned in each package configuration file:

|Parameter|Description|Default|
|:-:|:-|:-|
|stow_install|A function to define how to install the package.<br>If `stow_isntall` is defined, other installation functions (including `before_configure` and `make_cmd`) for each inst_type are ignored.|undefined|
|before_configure|A function which has command list to be executed before `configure`. (Use for such `./autogen.sh`)|function before_configure {<br>  :<br>}|
|configure_cmd|A function for configure command. <br>If `configure` doesn't have `--prefix` but it set prefix in other way, then change this function to give proper arguments.|function configure_cmd {<br>  if [ -x "$configure_file" ];then<br>    execute $configure_flags $configure_file --prefix="$stow_dir/$target" $configure_options<br>  fi<br>}}|
|make_cmd|Make commands.|function make_cmd {<br>  execute make all && execute make install<br>}|
|get_latest|A function to get the latest version of the package. It is used if `version` is not specified, or `latest` command is executed. |Only `gnu` type has default method.|

For these functions, give commands to `execute` function,
to enable dry run mode.

```sh
function execute {
  if [ $dryrun -eq 1 ];then
    echo  "$@"
  else
    echo  "$" "$@"
    eval "$@"
  fi
  ret=$?
}
```

### `inst_type`

Available `inst_type` are `gnu`, `tarball`, `github` and `github_direct`:

* gnu

For GNU Project packages, if it can be obtained from [ftp repository](http://ftp.gnu.org/gnu/)
and it has tar.gz file with `<package>-<version>.tar.gz` naming convention,
you need only one line:

    inst_type=gnu

If you want to specify a version, add

    version=1.2.3

* tarball

Set `inst_type`:

    inst_type=tarball

`version` must be specified for `tarball` case.

In addition, `url_prefix`, which is URL where tarball file is placed,  is needed, like:

    url_prefix=http://www.lua.org/ftp/

The default tarball name is `<package>-<version>.tar.gz`. If the naming convention is different,
specify tarball name with `tarball`, like:

    tarball=expat-${version}.tar.bz2

`tar.gz`, `tar.xz`, `tar.bz2` and `zip` files are available as tarball.

* github

If the package is distributed by GitHub and it has *releases*,
use `inst_type=github`.

Most of cases, GitHub releases have version with naming convention of `v<version>`.

For this case, set `version` without `v`, like:

    version=2.13.0

GitHub's releases' url is normally like:

    https://github.com/<user>/<repository>/archive/v<version>.tar.gz

If the repository and GitHub user name is same as package (like [git](https://github.com/git/git/),
you need to set only `version`.

If `user` or `repository` is different from package name, specify them in the configuration file.

    user=package_owner
    repository=package_repository

If archive file naming convention is different from `v<version>`,
it may be better to use `tarball` instead of `github`.

* github_direct

Like github, but useful if the repository has simple structure with such **bin** or **lib** directories.

The repository is directory copied into stow directory.

See more examples in [stow-get/share/stow-get](https://github.com/rcmdnk/stow-get/tree/master/share/stow-get).

## Help

    Usage: stow-get <sub command> [-fDVvh] [-c <conf file>] [-d <conf dir>] [-i <inst dir> ] [-t <inst type>] [package [package [...]]]

    Sub commands:
       install [package [package...]]
                      Install packages (all packages in the configuration file if no package is given).
       reinstall [package [package...]]
                      Reinstall packages (same as 'install -f')
       uninstall [package [package...]]
                      Remove packages.
       rm/remove      Aliases of uninstall.
       unlink [package [Package...]]
                      Like uninstall, but remain files. (install will be done w/o download codes.)
       upgrade/update [package [package...]]
                      Upgrade packages (all packages in the list if no package is given).
       list           List up installed packages.
       packages       List up available packages which have configuration files.
       clean/cleanup  Clean up old packages
       info <package> Show configuration file of package.
       latest <package>
                      Show the latest version of package.
       version        Show version.
       license        Show license.
       help           Show this help.

    Arguments:
       -c <conf file> Configuration file (default: $HOME/.stow-get).
       -d <conf dir>  Additional directory of package configuration files (default: $HOME/usr/local/share/stow-get).
                      Multi directories can be specified by separating with ",".
       -i <inst dir>  Directory to install packages (default: $HOME/usr/local).
       -t <inst type> Set install type (default: gnu).
       -f             Force to reinstall.
       -D             Dry run mode.
       -V             Verbose mode.
       -v             Show version.
       -l             Show license.
       -h             Show this help.

    See more details at: https://github.com/rcmdnk/stow-get

