# 🏠 Install `npm` packages as a user
After running this script, `npm` will install packages as your local user. The script will set up `npm` user directories for you, and then automatically add them to your `$PATH`.

You won't need `root` privileges because packages won't be installed at the system level:
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
The script takes 5 optional positional arguments:
  1. `root`: The root directory for `npm`. Default is `$HOME`.
  2. `rc`: Shell configuration file. The script with automatically detect yours, or default to `$HOME/.profile`.
  3. `bin`: `npm`'s executables directory. Default is `$root/.npm-packages/bin`.
  4. `man`: Manpage directory for `npm`. Default is `$root/.npm-packages/share/man`.
  5. `shell`: Name of the shell to configure. Default is your running shell.

### Passing options
```bash
$ curl -s "https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh" \
    | bash -s "~/.local" "~/.zshrc"
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
This script works with any shell that supports `~/.profile`, like Bourne or Korn shells. It also works with configuration files for the following:

 - `bash`
 - `zsh`
 - `sh`

#### Operating systems
This script will work on any POSIX compatible system or compatibility layer.

 - Linux
 - \*BSD
 - macOS
 - WSL 1 & 2 on Windows
 - Cygwin or MSYS2 on Windows
