# 🧰 OmniSetup: System Bootstrapper

OmniSetup is a lightweight, cross-platform (macOS and Linux) utility designed to bootstrap fresh machines and automatically track your installed tools in version-controlled text files. 

## 🎯 Who is it for?
This tool is built for developers who want a reproducible environment without the overhead of heavy infrastructure tools like Ansible or Nix. It replaces manual installation steps with a streamlined, self-documenting workflow.

## 🧠 What this does?

- Install tools/apps on a fresh machine(based on OS)
- Track your setup in version-controlled files
- Recreate the same environment on macOS or Linux

### 🚀 First-Time Setup
To set up a fresh machine, clone the repository and run the bootstrap script.
```bash
git clone https://github.com/SinAyByCosAy/OmniSetup.git ~/OmniSetup
cd ~/OmniSetup
chmod +x bootstrap.sh
./bootstrap.sh
source ~/.zshrc
```
### What bootstrap.sh does:  
<ul>
    <li> Installs Homebrew (macOS) or updates apt (Linux). </li>
    <li> Installs Node.js and manages npm globals via NVM. </li>
    <li> Installs all packages being tracked in your common, OS-specific, and npm lists. </li>
    <li> Creates global symlinks for the add-tool and remove-tool CLI commands. </li>
    <li> Injects shell wrapper functions into your .zshrc or .bashrc.</li>
</ul>

### Files being tracked:
<ul>
    <li>Common(MacOS and Linux): <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/npm-global.txt">npm-global.txt</a>, <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/common/common-cli.txt">common-cli.txt</a>, <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/common/common-gui.txt">common-gui.txt</a></li>
    <li>Mac Only: <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/mac/mac-applications.txt">mac-applications.txt</a>, <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/mac/mac-formulas.txt">mac-formulas.txt</a></li>
    <li>Linux Only: <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/linux/linux-packages.txt">linux-packages.txt</a></li>
</ul>

This is a <b>Declarative System Bootstrapper</b> where: you describe the desired environment state
and the tool figures out how to make the machine match it.
<br>
Instead of manually commanding: install this -> configure this -> add to PATH <br>
You declare: "These are the tools and configurations my environment should contain." and the bootstrapper reconstructs it. <br>
<b>Source of truth: Tracked files</b>

## ⚡ Daily Usage: Installing & Tracking

Because OmniSetup uses global symlinks and dynamic path resolution, **you can run these commands from anywhere on your system.** You do not need to be inside the `~/OmniSetup` directory to install or track packages.

OmniSetup operates on a philosophy of explicit intent. You use wrapper commands to install tools, and pass flags to declare how they should be tracked.

## 🛠️ Commands & Flags Guide

OmniSetup abstracts away the underlying OS package managers by using standard wrapper commands combined with tracking flags. 

### 1. Core Commands (The Actions)
These commands determine *how* a package is installed or removed on your current system - required post first-time setup.

| Command | Action |
| :--- | :--- |
| `brew-add <tool>` | Installs a package via Homebrew (macOS). Dynamically uses `--cask` if the `--gui` flag is passed. |
| `apt-add <tool>` | Installs a package via `apt` (Linux). |
| `npm-add <tool>` | Installs a Node.js package globally via `npm` (Cross-OS). |
| `add-tool <tool>` | Tracks a tool that is **already installed** on your system (skips installation). |
| `tool-rm <tool>`<br>*(or `remove-tool`)* | Uninstalls the package from the system and removes it from all tracked lists. |

### 2. Tracking Flags (The Intent)
Flags tell OmniSetup *where* to record the tool in your Git repository so it can be reproduced later.

| Flag | Description | File Modified |
| :--- | :--- | :--- |
| `--common` | Tracks the tool for **both** macOS and Linux. | `common/common-cli.txt` (or `-gui.txt`) |
| `--local` | Tracks the tool **only** for the current OS. | `mac/mac-cli.txt` (or `-gui.txt`) |
| `--gui` | Classifies the tool as a GUI app. On Mac, it forces a Cask install. | Targets `-gui.txt` files. |
| `--npm` | Tracks as an NPM package. | `npm-global.txt` |
| `--linux-name <name>` | Maps a different package name for Linux `apt` installs. | Appended inline (e.g., `docker & docker.io`) |
| `--no-push` | Skips pushing the Git commit to the remote repo. | *None* |

---

### 3. Usage Guide: Putting it Together (All Cases)

Here is how you combine commands and flags for any scenario.

#### Case A: Installing and Tracking for Both Operating Systems
Use `--common` when you want this tool available on every machine you set up.
```bash
# Cross-OS CLI tool
brew-add jq --common

# Cross-OS GUI application
brew-add google-chrome --common --gui
```

#### Case B: Tracking an OS-Specific Tool
Use `--local` when a tool is only relevant to your Mac (like a Mac-specific utility) or your Linux box.
```bash
# Installed and tracked ONLY for macOS
brew-add rectangle --local --gui

# Installed and tracked ONLY for Linux
apt-add systemd-ui --local
```

#### Case C: Handling Different Package Names Across OSs
Sometimes a package is named differently in `brew` vs `apt`. You can install it on Mac while simultaneously defining what the Linux machine should look for.
```bash
# Installs 'docker' via brew, but tells Linux to use 'docker.io'
brew-add docker --common --linux-name docker.io
```

#### Case D: Global Node/NPM Packages
NPM packages require the explicit `--npm` flag to be saved to state.
```bash
# Installs 'typescript' globally and adds to npm-global.txt
npm-add typescript --npm
```

#### Case E: Temporary Install (No Tracking)
If you omit tracking flags, the wrapper will simply install the tool using the underlying package manager, but it will **not** write it to any text file or trigger a git commit.
```bash
# Installs a CLI tool temporarily
brew-add nmap

# Installs a GUI tool temporarily (requires --gui for macOS cask logic)
brew-add spotify --gui

# Installs an NPM package temporarily
npm-add express
```

#### Case F: Retroactive Tracking
If you installed something manually (e.g., `brew install tree`) and later decide you want OmniSetup to track it, use `add-tool`.
```bash
# Does not attempt to install, just adds to the common tracking list
add-tool tree --common
```

#### Case G: Uninstalling and Untracking
The removal tool automatically handles the uninstallation and purges the tool from whichever list it was being tracked in.
```bash
# Removes 'typescript' from the system and npm-global.txt
tool-rm typescript
```

**⚠️ Important Exceptions:**
1. **Mac GUI Installations:** To install a Mac GUI app without tracking it, you **must** still pass the `--gui` flag (e.g., `brew-add spotify --gui`). This tells the wrapper to use `brew install --cask` instead of regular `brew install`.
2. **NPM Tracking:** `npm-add` behaves exactly like OS wrappers. Running `npm-add express` will install it globally but *will not track it*. You must pass `--npm` to track it (e.g., `npm-add express --npm`).

---

## ⚙️ Configuration & Git Behavior

OmniSetup automatically commits file changes to your local Git repository when you track or untrack a tool. 

**Auto-Creation & Defaults** <br>
You do not need to manually create any configuration files. The tool manages its own state at `~/.setup-config`.

> **⚠️ Note: Auto-Push is ENABLED by default.** <br>
> Out of the box, OmniSetup will automatically run `git push` to sync your changes to your remote repository (`AUTO_PUSH=true`). 

**Disabling Auto-Push Before First Use** <br>
If you want to disable automatic pushing *before* you run your very first installation command, you must initialize the config file first. Run these two commands:

```bash
setup-config    # Initializes the default config file
setup-push-off  # Disables the auto-push behavior
```

### Configuration Commands

| Command | Action |
| :--- | :--- |
| `setup-config` | Displays your current configuration variables (and initializes `~/.setup-config` if it doesn't exist yet). |
| `setup-push-off` | Disables automatic Git pushing to the remote repository (`AUTO_PUSH=false`). |
| `setup-push-on` | Re-enables automatic Git pushing (`AUTO_PUSH=true`). |

*(Tip: You can always override your global auto-push setting for a single command by passing the `--no-push` flag, e.g., `brew-add nmap --common --no-push`).*

## 🔧 Troubleshooting & Edge Cases
- Repo Moved: If you move the cloned repository to a new directory, your global symlinks will break. 
<br>Update them manually by running:<br>
`sudo ln -sf "<new-path>/common/add-tool.sh" /usr/local/bin/add-tool`<br>
`sudo ln -sf "<new-path>/common/remove-tool.sh" /usr/local/bin/remove-tool`
- Git Commit Errors: Ensure your git user is configured `(git config --global user.name "...")`. The tool will gracefully skip commits if git is not authenticated.
- Command Not Found: If wrappers like `brew-add` aren't recognized, run source `~/.zshrc` (or `.bashrc`) to reload your injected shell functions.