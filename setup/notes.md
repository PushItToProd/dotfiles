setup notes
===========

Config
------

* `apt_repos`
* `apt_packages`
* `vscode_extensions`
* `appdir_name`
* `homedir_dirs`
* `hledger_shell_path`
* `pomodoro_path`
* `homedir_repos`
* `USER`
* `TMP`

Vars
----

* `USER_HOME`
* `APPDIR`

Utils
-----

* `as_me` - run commands as myself
* `install-deb.sh`, `install_deb`

Overall flow
------------

### Pre-apt install

* initialize base config and util functions, validate running as root
* set up homedir
    * create APPDIR
    * validate .ssh exists
    * update git submodules for the setup repo
    * create `homedir_dirs`
    * clone `homedir_repos`
    * create tempdir for setup files
        * ~not really a true temporary directory since persistence here makes things faster
    * cd to the tempdir for future setup steps
* basic OS config
    * dconf settings - map caps to escape and map gnome-terminal bindings
* VS Code repo setup
    * download GPG key
    * install key
    * create apt repo
* Spotify flatpak install
* Docker repo install
    * ^stop using discouraged approach for installing apt keys

### Apt install

* apt package install
    * apt repos
    * apt update
    * apt fix broken
    * apt install

### Post-apt install

* VS code extensions
* hledger
    * install hledger
        * ^get latest hledger-install script
    * install hledger-shell
* discord
    * install_deb
* rofimoji
    * check if installed
    * download wheel
    * pip install wheel
* Syncplay
    * check if installed
    * wget
    * chmod
* TeamSpeak
    * `install-teamspeak.sh`
* Synology Drive
    * install_deb
* Bitwig
    * install_deb
* Powerline Shell
    * pip3 install
* Zsh
    * chsh
* i3ipc
    * pip3 install
* Selenium - geckodriver
    * check if installed
    * wget, tar, mv
* Anki
    * check if installed
    * wget, tar, make install
* Docker Compose
    * check if installed
    * curl
    * chmod
* Trilium
    * check if dir exists
    * wget, tar, mv
* Go
    * check if dir exists
    * wget, tar

Install bits
------------

* apt 
    * repos
    * keys
    * packages
* install script
* pip packages
* deb packages
* downloads
* check if installed

Scratch
-------

* move EUID check to top of file
* make homedir_repos into submodules?
* use the same apt setup steps for everything
    * -> https://lists.gnupg.org/pipermail/gnupg-users/2017-June/058502.html
    * don't use `apt-key add`, drop into /etc/apt/trusted.gpg.d/
    * only use `add-apt-repository` for official repos
* test setup steps in Vagrant?
* manage PATH and other .zshrc config
* use just curl or wget, not both