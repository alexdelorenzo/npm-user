# 🏠 Run `npm install -g` without `sudo`
After running this script, you will be able run `npm install -g` without `sudo`, because`npm` will install packages as your non-root user. The script will set up `npm` user directories for you, and then add them to your `$PATH`.

Packages can then be installed without root privileges:
```bash
$ npm install -g yarn
$ type yarn
yarn is /home/user/.npm-packages/bin/yarn
```

## Usage
Run the following:
```bash
$ curl -s "https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh" | bash
```

You can check out [the script's requirements here](#requirements).

### Options
The script takes 6 optional positional arguments, or you can set [environment variables](https://en.wikipedia.org/wiki/Environment_variable):

| Position | Variable name | Description | Default value |
| --|------|-------------|-------- |
| 1 | `$ROOT` | The root directory for `npm` | `$HOME` |
| 2 | `$SHELL_NAME` | Name of the shell to configure | Current shell |
| 3 | `$SHELL_RC` | Shell configuration file, automatically detected | `$HOME/.profile` |
| 4 | `$BIN` | `npm`'s executable directory | `$ROOT/.npm-packages/bin` |
| 5 | `$MAN` | [Manpage](https://en.wikipedia.org/wiki/Man_page) directory for `npm` | `$ROOT/.npm-packages/share/man` |
| 6 | `$REINSTALL` | Set to any non-null value to reinstall old `npm` packages in your new `$ROOT` | Unset |


### Passing options
If you want to set your `npm` path to `~/.local/.npm-packages`, instead of `~/.npm-packages`, and configure `zsh` to work with it, you can run:
```bash
$ export URL="https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh"
$ curl -s "$URL" | bash -s "~/.local" "zsh"
```

You can also use environment variables:
```bash
$ export ROOT="~/.local" SHELL_NAME="zsh"
$ curl -s "$URL" | bash
```

### Confirming it works
Install a package with the global flag `-g` and then see where `npm` puts the files:
```bash
$ npm install -g yarn
$ type yarn
yarn is /home/user/.npm-packages/bin/yarn
```

## Requirements
### Dependencies
- Bash, GNU Coreutils and `grep`
- `curl`
- NPM

### Supported systems
#### Shells
This script works with configuration files for the following shells:
 - `bash`
 - `zsh`
 - `fish`
 - `sh`

The script will default to `$HOME/.profile` if it doesn't recognize any of the shells from above. `ksh` uses `$HOME/.profile`, but the script wasn't tested on it.

#### Operating systems
This script will work on any POSIX compatible system or compatibility layer.

 - Linux
 - \*BSD
 - macOS
 - WSL 1 & 2 on Windows
 - Cygwin or MSYS2 on Windows
