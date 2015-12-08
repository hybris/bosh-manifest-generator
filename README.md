# Introduction
The manifest generator scripts are used to download manifests and merge them with passwords stored in vault.

# Installation
Clone the repo and run ```bundle install```.

# Usage (bosh-deployments)
Store credentials in vault:

```bash
bundle exec put_credentials <deployment_name> <environment> <passwords_file>
```

The script will store all values in the password file (yaml) in vault. It will return the keys used.

Generate credentials file:
```bash
bundle exec pull_credentials <deployment_name> <environment> <passwords_template> <out_file>
```

The command will read a yaml erb template and fill in passwords stored in vault. To get a password out of vault call the ´´´p´´´ function.

# Usage (bosh-init, deprecated)
Generate manifest file for existing deployment:

```bash
bundle exec generate_manifest <working_dir> <password_erb_template>
spiff merge <manifest_template> <working_dir>/metadata.yml <working_dir>/passwords.yml > <working_dir>/manifest.yml
```

The script is expecting a metadata.yml file including the AWS account id inside the ```working_dir```.

Generate and upload passwords to vault:

```bash
bundle exec store_passwords <aws_account_id> <aws_secret_key> <aws_key_id> <password_erb_template>
```

Upload ssh key to vault:

```bash
bundle exec store_key <aws_account_id> <key_file>
```
