# 🏠 Install `npm` packages as a user
After running this script, `npm` will install packages as your non-root user. The script will set up `npm` user directories for you, and then add them to your `$PATH`.

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
The script takes 5 optional positional arguments, or you can set [environment variables](https://en.wikipedia.org/wiki/Environment_variable):
  1. `$ROOT`: The root directory for `npm`. Default is `$HOME`.
  2. `$SHELL_NAME`: Name of the shell to configure. Default is your running shell.
  3. `$SHELL_RC`: Shell configuration file. The script will automatically detect yours, or will default to `$HOME/.profile`.
  4. `$BIN`: `npm`'s executable directory. Default is `$ROOT/.npm-packages/bin`.
  5. `$MAN`: Manpage directory for `npm`. Default is `$ROOT/.npm-packages/share/man`.

### Passing options
If you want to set your `npm` path to `~/.local/.npm-packages`, instead of `~/.npm-packages`, and configure `zsh` to work with it, you can run:
```bash
$ curl -s "https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh" \
    | bash -s "~/.local" "zsh"
```

You can also use environment variables:
```bash
$ export ROOT="~/.local" SHELL_NAME="zsh"
$ curl -s "https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh" | bash
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

The script will default to `$HOME/.profile` if it doesn't recognize any of the shells from above. Both `sh` and `ksh` use `$HOME/.profile`, but the script wasn't tested on them.

#### Operating systems
This script will work on any POSIX compatible system or compatibility layer.

 - Linux
 - \*BSD
 - macOS
 - WSL 1 & 2 on Windows
 - Cygwin or MSYS2 on Windows
