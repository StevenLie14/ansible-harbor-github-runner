# DevOps — Configure Harbor and GitHub Actions Runner with Ansible

This repository provides an **Ansible control container** (built from the included `Dockerfile`) and playbooks/roles to:

* Configure and register a **GitHub Actions self-hosted runner** on a remote host.
* Deploy and configure **Harbor**, a private container registry.

---

## Overview

* The control container is built with `Dockerfile` (Ubuntu + Python + `ansible-core` + collections).
* Since **Windows cannot run Ansible natively**, this repository uses **Docker Compose** to start a container that has Ansible pre-installed.
* `playbook.yml` is the main entry point and supports two flows via tags:

  * **`runner`** → Configure GitHub Actions self-hosted runner.
  * **`harbor`** → Configure Harbor container registry.

---

## Prerequisites

* Docker and Docker Compose installed on the host machine (Linux, macOS, or Windows).
* On **Windows**, PowerShell or Command Prompt to run the provided `.bat` scripts.
* A [**GitHub PAT (Personal Access Token)**](https://github.com/settings/personal-access-tokens) with permissions to register self-hosted runners.

---

## Environment Variables

All configuration is managed through a `.env` file (copy from `.env.example`).

### Required variables

| Variable                        | Description                                                        |
| ------------------------------- | ------------------------------------------------------------------ |
| `GITHUB_PAT`                    | GitHub personal access token for runner registration.              |
| `ANSIBLE_HOST`                  | Target host IP or hostname.                                        |
| `ANSIBLE_USER` / `ANSIBLE_PASS` | SSH credentials for connecting to target host.                     |
| `RUNNER_USER`                   | Linux account name to create for GitHub runner.                    |
| `HARBOR_ADMIN_PASSWORD`         | Initial Harbor admin password.                                     |
| `HARBOR_HTTP_PORT`              | Port to expose Harbor over HTTP (default 80 or custom).            |
| `HARBOR_HTTPS_PORT`             | Port to expose Harbor over HTTPS (default 443 or custom).          |
| `ANSIBLE_HOST_KEY_CHECKING`     | (Optional) Set to `False` to disable SSH host key checking.        |
| `GITHUB_REPO_URL`               | Repository URL where the GitHub Actions runner will be registered. |
| `REGISTRY_URL`                  | Harbor (or other container registry) URL.  (Without https://)                        |
| `REGISTRY_USERNAME`             | Username for authenticating with the registry.                     |
| `REGISTRY_PASSWORD`             | Password for authenticating with the registry.                     |
| `VAULT_URL`                     | HashiCorp Vault server URL.                                        |
| `VAULT_USERNAME`                | Username for authenticating with Vault.                            |
| `VAULT_PASSWORD`                | Password for authenticating with Vault.                            |
| `VAULT_PATH`                    | Path in Vault where secrets are stored.                            |


### Adding Custom Secrets

This setup also supports injecting **repository-level GitHub secrets**.

1. Add your secret variable(s) in `.env`. Example:

   ```env
   MY_SECRET_KEY=my_secret_value
   ```

2. Map the secret in `inventory/host_vars/github-actions-secret.yml` under the `secrets` list:

   ```yaml
   secrets:
     - name: "MY_SECRET_KEY"
       value: "{{ lookup('env', 'MY_SECRET_KEY') }}"
   ```

⚠️ **Important**: If you change values in `.env`, you must re-run:

```bash
docker-compose up -d --build
```

This ensures the updated environment variables are applied to the Ansible control container.



---


## Setup and Run

1. Copy `.env.example` to `.env` and update with your values:

   ```bash
   cp .env.example .env
   ```

2. Build and start the Ansible control container:

   ```bash
   docker-compose up -d --build
   ```

   > This starts a container with Ansible pre-installed. The repository is mounted at `/workdir` inside the container.

3. Run playbooks:

   **Windows (via scripts):**

   * Configure GitHub Actions runner:

     ```bash
     run_action.bat
     ```
   * Configure Harbor:

     ```bash
     run_harbor.bat
     ```

   * Configure Github Actions Secret (Repository Level):

     ```bash
     run_secret.bat
     ```

   **Manually (inside the container):**

   ```bash
   # Configure runner
   ansible-playbook -i inventory/hosts/hosts.yml playbook.yml --tags runner

   # Configure Harbor
   ansible-playbook -i inventory/hosts/hosts.yml playbook.yml --tags harbor

   # Configure Secret
   ansible-playbook -i inventory/hosts/hosts.yml playbook.yml --tags secret
   ```

---



## Notes on Harbor Admin Account

* The value of **`HARBOR_ADMIN_PASSWORD`** is **only valid for the very first login**.
* After logging in for the first time:

  1. Create a new user immediately.
  2. Assign this new user as an **administrator**.
  3. Do not rely on the `admin` account, as it will become disabled after initial use.

⚠️ If you skip this step and lose access to the admin account, you cannot reset it from the UI.

### Recovery steps (on target server)

If the `admin` user becomes unusable:

1. SSH into the server where Harbor is running.

2. Access the Harbor database:

   ```bash
   cd /home/harbor
   docker exec -it harbor-db psql -U postgres
   \c registry
   update harbor_user set salt='', password='' where user_id = 1;
   ```

   This resets the `admin` password to empty (`""`).

3. Restart Harbor to apply changes:

   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

You can now log in again with the `admin` account with default password.

---

## Inventory and Variables

* **Inventory file**: `inventory/hosts/hosts.yml`
  Uses environment lookups for sensitive values (e.g., GitHub token, SSH password).

* **Host-specific variables**:

  * `inventory/host_vars/github-action-runner.yml`: contains runner-specific variables such as `repo_url`.
  * Additional host-specific variables can be defined under `inventory/host_vars/` for flexibility.

---
