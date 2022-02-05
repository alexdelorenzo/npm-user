# Install `npm` packages locally as a user
When you run `npm install -g <package>`, the package will be installed at the system level, which requires `root` privileges. 

After running this script, `npm` will install packages as your local user. The script will setup `npm` user directories for you, and then automatically add them to your `$PATH`. You won't need `root` privileges, and packages won't be installed at the system level.

## Usage
Run the following:
```bash
$ curl -s "https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh" | bash
```
### Options
The script takes 4 optional positional arguments:
  1. `root`: The root directory for `npm`. Default is `$HOME`.
  2. `rc`: Shell configuration file. Default is `$HOME/.bashrc`.
  3. `bin`: `npm`'s executables directory. Default is `$root/.npm-packages/bin`.
  4. `man`: Manpage directory for `npm`. Default is `$root/.npm-packages/share/man`.

### Passing options
```bash
$ curl -s "https://raw.githubusercontent.com/alexdelorenzo/npm-user/main/npm-user.sh" \
    | bash -s "~/.local" "~/.zshrc"
```
