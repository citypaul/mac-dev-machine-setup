# API Keys Documentation

The `vars/api_keys.yml` file contains encrypted API keys used in this project. The file is encrypted using Ansible Vault for security reasons.

## Stored API Keys

The following API keys are stored in the encrypted file:

1. `anthropic_api_key`: Used for Anthropic AI services
2. `youtube_api_key`: Used for YouTube API interactions

## Usage

These API keys are used in various tasks throughout the Ansible playbook, particularly in the AI tools setup (`ansible/tasks/ai-tools.yaml`).

## Security

- Never commit the decrypted `api_keys.yml` file to version control.
- Always use Ansible Vault to view or edit the contents of this file.
- Ensure that only authorized team members have access to the Vault password.

## Updating API Keys

To update or view the API keys:

1. Use the Ansible Vault command:

```sh
ansible-vault edit vars/api_keys.yml
```

2. Enter the Vault password when prompted.
3. Update the keys as needed and save the file.

For more information on using Ansible Vault, refer to the official Ansible documentation.
