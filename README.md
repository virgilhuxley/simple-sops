# Simple-sops for managing arbitrary files in a repo

Examples use `age` keys for simplicity. Other options are available but are not
covered here.

## Assumptions

- Packages installed: `age`, `sops`, `direnv`.
- An `age` key is setup in at least one of the following locations.
  - OPTION 1: `.envrc` or the environment has an entry for:
    - `export SOPS_AGE_KEY="PRIV_KEY_STRING_GOES_HERE"`
  - OPTION 2: `age` key is present in `~/.config/sops/age/keys.txt`.
  - OPTION 3: `age` key is available in another dir and the following entry is
    present in `.envrc` or the environment.
    - `export SOPS_AGE_KEY_FILE="PRIV_KEY_PATH_GOES_HERE"`
- `.sops.yaml` is populated with all of the public-keys who's private-key-pairs
  are expected to be able to decrypt the files. These public-keys are also used
  to re-encrypt.
- A list of files which `sops` will be managing. This is represented in a line
  delimited list in one of the following options.
  - OPTION 1: Default behavior is to read the file: `.simple-sops-managed-files`
  - OPTION 2: File with a different name (e.g. `files.list`) provided as `-f files.list`
    argument to `sops-marshal.sh`. Example:
    - `sops/sops-marshal.sh -f files.list encrypt`
    - `sops/sops-marshal.sh -f files.list decrypt`

## Typical workflow of existing encrypted repo

- git clone / git pull / git fetch ... etc
- Check to ensure the files listed in `.simple-sops-managed-files` (or equivalent option)
  contains a line-delimited list of all files you want `sops` to act on (encrypt|decrypt).
- Check `.sops.yaml` to ensure your public key is present so you can decrypt/encrypt
  as with the appropriate keys.
- Decrypt:
  - `sops/sops-marshal.sh decrypt`
  - `sops/sops-marshal.sh -f myfiles.list decrypt`
- Work on your files (they're just plain text at this point)
- Encrypt:
  - `sops/sops-marshal.sh encrypt`
  - `sops/sops-marshal.sh -f myfiles.list encrypt`
- Commit / Push

## Typical workflow of new repo

- `git clone ...` this template repo.
- remove the git config: `rm -rf .git`
- `git init`
- Populate this repo's directory with your project.
- Update `.simple-sops-managed-files` with the names of the files you want sops to
  encrypt/decrypt.
- Update `.sops.yaml`
  - Remove example entries.
  - Populate public keys appropriately.
  - Update the `regex` of `creation_rules` if needed.
  - Add additional `creation_rules` if needed.
- Encrypt:
  - `sops/sops-marshal.sh encrypt`
  - `sops/sops-marshal.sh -f myfiles.list encrypt`
- Commit / Push


# Appendix

## Age Key Creation
```sh
age-keygen
```

STDOUT will display a private and a pub key. For example

```txt
# created: 2000-01-00T00:00:00-00:00
# public key: age1nd9hj056h4q3zcdklf2mnh5yasfumzpx638ysx60dvw2lgh90gas4de2zq
AGE-SECRET-KEY-1EACHPZ9T4P8XCPNNMDQW3LGC2LU5ZMMFUAP95QR6WGHVZKZKSQ4QMW9S6G
```

This Priv/Pub key will be used in subsequent examples.  
DO NOT USE THIS KEY IN YOUR ACTUAL REPO.

## Age Key Handling

### Private-Key

#### Option 1 `.envrc`

```envrc
export SOPS_AGE_KEY="AGE-SECRET-KEY-1EACHPZ9T4P8XCPNNMDQW3LGC2LU5ZMMFUAP95QR6WGHVZKZKSQ4QMW9S6G" # INSECURE KEY

# OR

export SOPS_AGE_KEY_FILE="~/.config/sops/age/key.txt" # this is the default path
```

#### Option 2 User-level-key

`age` private-key is stored in `~/.config/sops/age/keys.txt`

### Public-Key

Public key is placed in `.sops.yaml`. For example:

```yaml
creation_rules:
  - path_regex: "\.(ya?ml|json|toml|nix)"
    age:
      - 'age1nd9hj056h4q3zcdklf2mnh5yasfumzpx638ysx60dvw2lgh90gas4de2zq' # INSECURE KEY
```

Or

```yaml
keys:
  key_groups: &example_key_group
    - age:
      - 'age1nd9hj056h4q3zcdklf2mnh5yasfumzpx638ysx60dvw2lgh90gas4de2zq' # INSECURE KEY
      - ...
creation_rules:
  - path_regex: "\.(ya?ml|json|toml|nix)"
    key_groups: *example_key_group
```

## Troubleshoot

Main questions to address while troubleshooting

- Is `.sops.yaml` populated with the appropriate keys?
  - If you can encrypt/decrypt but your team cannot, check to ensure that your
    team's keys are properly identified in `sops.yaml`
- Is your private key in a usable location? For example
  - The default location the system will look for an `age`key is
    `~/.config/sops/age/keys.txt` and is formatted to look like this
    `AGE-SECRET-KEY-1EACHPZ9T4P8XCPNNMDQW3LGC2LU5ZMMFUAP95QR6WGHVZKZKSQ4QMW9S6G`
  - Alternatively it can be provided in two ways via environment variables
    - `export SOPS_AGE_KEY_FILE` which will contain the path of the private-key.
    - `export SOPS_AGE_KEY` which will contain the value of the private-key.
  - If using dir-env (`.envrc`), remember to run `direnv allow`
- Is your file containing the list-of-files properly populated?
  - Default location is `.simple-sops-managed-files`
  - Can be overwritten via `-f $different_file` argument when calling
    `sops/sops-marshal.sh`
  - File contents is a line-delimited list of file-names relative to where the
    script is called.

## Future Consideration

`age` supports mechanisms to use existing ssh keys with the `age` binary.
However this is not yet supported by upstream sops as of 2023-10-18.

Related issues:
- [getsops/sops - Adding support for ssh keys for encryption](https://github.com/getsops/sops/issues/692)
Related docs:
- [getsops/sops/README.rst#encrypting-using-age](https://github.com/getsops/sops/blob/9065f516a9787213b745bc3528dda62f5b5f402d/README.rst#encrypting-using-age)
Related projects:
- [Mic92/ssh-to-age](https://github.com/Mic92/ssh-to-age)
- [Mic92/ssh-to-pgp](https://github.com/Mic92/ssh-to-pgp)
- [FiloSottile/age](https://github.com/FiloSottile/age)
