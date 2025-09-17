# Work Machine VPN Fix for Ansible Galaxy Dependencies

## Problem
When running on a work machine behind a corporate VPN, Ansible Galaxy dependencies may fail to download, causing errors like:
```
ERROR! the role 'elliotweiser.osx-command-line-tools' was not found
```

## Solution

### Option 1: Pre-download Dependencies (Recommended)
1. **On a non-VPN connection**, run the dependency installation:
   ```bash
   make deps
   ```
   or manually:
   ```bash
   ansible-galaxy install -r requirements.yaml --force
   ```

2. **Verify the roles are installed**:
   ```bash
   ls -la roles/
   ```
   You should see `elliotweiser.osx-command-line-tools` directory.

3. **Commit the roles directory** to your fork/branch:
   ```bash
   git add roles/
   git commit -m "Add pre-downloaded Ansible Galaxy roles for VPN environments"
   git push
   ```

### Option 2: Manual Role Installation
If you can't download from Ansible Galaxy, manually copy the role:

1. **Download the role archive** from another machine or use the existing copy from this repo
2. **Extract to the roles directory**:
   ```bash
   mkdir -p roles/
   # Copy the elliotweiser.osx-command-line-tools directory to roles/
   ```

### Option 3: Remove Xcode Tools Role (If Already Installed)
If Xcode Command Line Tools are already installed on your work machine:

1. **Comment out the role in `local.yaml`**:
   ```yaml
   # roles:
   #   - role: elliotweiser.osx-command-line-tools
   ```

2. **Verify Xcode tools are installed**:
   ```bash
   xcode-select -p
   ```

### Option 4: Use Proxy Settings
If your corporate VPN allows proxy access:

```bash
export HTTPS_PROXY=http://your-proxy:port
export HTTP_PROXY=http://your-proxy:port
ansible-galaxy install -r requirements.yaml --force
```

## Testing
After applying any fix, test with:
```bash
make cli dotfiles
```

## Notes
- The `roles/` directory is already in `.gitignore` by default, but for work environments, you may want to track it
- This issue only affects the initial setup; once roles are installed, they persist
- The main blocker is usually `elliotweiser.osx-command-line-tools` which installs Xcode Command Line Tools