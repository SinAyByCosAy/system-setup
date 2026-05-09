# 🧰 OmniSetup: Declarative System Bootstrapper

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
    <li>Mac Only: <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/mac/mac-gui.txt">mac-gui.txt</a>, <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/mac/mac-cli.txt">mac-cli.txt</a></li>
    <li>Linux Only: <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/linux/linux-packages.txt">linux-packages.txt</a></li>
</ul>

<b>Source of truth: Tracked files</b>

## ⚡ Daily Usage: Installing & Tracking

OmniSetup operates on a philosophy of explicit intent. You use wrapper commands to install tools, and pass flags to declare how they should be tracked.

Because OmniSetup uses global symlinks and dynamic path resolution, **you can run these commands from anywhere on your system.** You do not need to be inside the `~/OmniSetup` directory to install or track packages.

## 🛠️ Commands & Flags Guide

OmniSetup abstracts away the underlying OS package managers by using standard wrapper commands combined with tracking flags. 

### 1. Core Commands (The Actions)
These commands determine *how* a package is installed or removed on your current system - required post first-time setup.

| Command | Action |
| :--- | :--- |
| `omni-add <tool>` | **The Universal Installer.** Automatically detects your OS. Uses `brew` (or `brew --cask` with `--gui`) on Mac, and `apt` on Linux. |
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
| `--linux-name <name>` | Acts as a cross-OS tracking flag for tools with divergent names. | `mac-cli.txt` (or `-gui.txt`)AND `linux-cli.txt` |
| `--no-push` | Skips pushing the Git commit to the remote repo. | *None* |

### 3. Flag Combinations & Clarifications
Tracking requires **explicit intent**. How you combine flags determines exactly how the tool is recorded:

* `--common` (alone) ➔ **Common CLI** tracking
* `--common --gui` ➔ **Common GUI** tracking
* `--local` (alone) ➔ **Local CLI** tracking
* `--local --gui` ➔ **Local GUI** tracking
* `--linux-name` ➔ **2 Names, 2 Files:** Acts as a special cross-OS flag. It tracks the primary name in the Mac list, and the provided Linux name in the Linux list.
* *(No flags)* ➔ **No tracking** (Installation only)

**🚫 Invalid Combinations (Will throw an error):**
* `--common`, `--local`, and `--linux-name` are mutually exclusive. A tool is either shared exactly, specific to one OS, or shared with divergent names. You cannot combine these flags.
* `--npm` + *(any OS-level flag)*: NPM is an independent, cross-platform runtime layer. It cannot mix with OS-level flags like `--gui` or `--local`.

**⚠️ Important Exceptions:**
1. **Mac GUI Installations:** To install a Mac GUI app without tracking it, you **must** still pass the `--gui` flag (e.g., `omni-add spotify --gui`). This tells the wrapper to use `brew install --cask` instead of regular `brew install`.
2. **NPM Tracking:** `npm-add` behaves exactly like OS wrappers. Running `npm-add express` will install it globally but *will not track it*. You must pass `--npm` to track it (e.g., `npm-add express --npm`).

---

### 4. Usage Guide: Putting it Together (All Cases)

Here is how you combine commands and flags for any scenario.

#### Case A: Installing and Tracking for Both Operating Systems
Use `--common` when you want this tool available on every machine you set up.
```bash
# Cross-OS CLI tool
omni-add jq --common

# Cross-OS GUI application
omni-add google-chrome --common --gui
```

#### Case B: Tracking an OS-Specific Tool
Use `--local` when a tool is only relevant to your Mac (like a Mac-specific utility) or your Linux box.
```bash
# Installed and tracked ONLY for macOS
omni-add rectangle --local --gui

# Installed and tracked ONLY for Linux
omni-add systemd-ui --local
```

#### Case C: Handling Different Package Names Across OSs
Sometimes a package is named differently in `brew` vs `apt`. The `--linux-name` flag acts as a standalone cross-OS tracker. It writes the primary name to your Mac list and the divergent name to your Linux list simultaneously.
```bash
# On macOS: Installs 'docker' via brew, records 'docker' for MacOS and 'docker.io' for Linux tracking.
# On Linux: Reads the flag and installs 'docker.io' via apt.
omni-add docker --linux-name docker.io
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
omni-add nmap

# Installs a GUI tool temporarily (requires --gui for macOS cask logic)
omni-add spotify --gui

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
The removal tool automatically handles the uninstallation and purges the tool from your tracked state. You can use it universally, or scope it with flags to specify which list it should be removed from.

**Universal Removal (Recommended):** If you pass no flags, it will hunt down the tool, remove it from *all* text files, and uninstall it from your system.
```bash
tool-rm express
tool-rm vlc
```

**Scoped Removal:** If you want to be surgical, you must specify the tracking scope (`--common`, `--local`, or `--npm`). If you are on a Mac and it's a GUI app, you must also pass `--gui` so Homebrew knows to use `--cask`.
```bash
# Removes the tool ONLY from the NPM list
tool-rm typescript --npm

# Removes the GUI app ONLY from the local Mac list
tool-rm vlc --local --gui

# Removes the CLI tool ONLY from the common list
tool-rm jq --common
```

---

### 5. Configuration Commands
These commands manage OmniSetup's internal settings, specifically how it handles automatic version control.

| Command | Action |
| :--- | :--- |
| `setup-config` | Initializes `~/.setup-config` if it doesn't exist, and displays your current variables. |
| `setup-push-off` | Disables automatic Git pushing to the remote repository (`AUTO_PUSH=false`). |
| `setup-push-on` | Re-enables automatic Git pushing (`AUTO_PUSH=true`). |

### 🛡️ A Note on Idempotency
OmniSetup is designed to be fully **idempotent**. You can safely run `bootstrap.sh` or any wrapper command dozens of times—it will intelligently check current system state, skip existing installations, and will never duplicate entries in your tracked text files or shell profiles (`.zshrc` / `.bashrc`).

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

*(Tip: You can always override your global auto-push setting for a single command by passing the `--no-push` flag, e.g., `brew-add nmap --common --no-push`).*

---

## 🔧 Troubleshooting & Edge Cases
- Repo Moved: If you move the cloned repository to a new directory, your global symlinks will break. 
<br>Update them manually by running:<br>
`sudo ln -sf "<new-path>/common/add-tool.sh" /usr/local/bin/add-tool`<br>
`sudo ln -sf "<new-path>/common/remove-tool.sh" /usr/local/bin/remove-tool`
- Git Commit Errors: Ensure your git user is configured `(git config --global user.name "...")`. The tool will gracefully skip commits if git is not authenticated.
- Command Not Found: If wrappers like `brew-add` aren't recognized, run source `~/.zshrc` (or `.bashrc`) to reload your injected shell functions.

---

## 🚀 Future Roadmap

This project is stable and handles declarative package reproducibility perfectly. However, the next evolutionary step is transforming it from a package orchestrator into a full **provisioning framework**.

#### Planned Feature: Modular Installers (The `installers/` Directory)

Currently, OmniSetup abstracts OS-level package managers (`brew`, `apt`). But what happens when an application doesn't live in a standard repository? 

Applications like **Docker**, **VS Code**, and **Google Chrome** often require multi-step provisioning on Linux (e.g., adding GPG keys or modifying `apt` sources lists). To guarantee 100% environment reproducibility for these complex tools without polluting the core `omni-add` script, the next major update will introduce **Modular Installers**.

**How it will work:**
If a tool requires special provisioning, a dedicated script will be placed in an `installers/` directory. When you run `omni-add vscode`, the system will intercept the request:

1.  **Check Registry:** Does `installers/vscode.sh` exist?
2.  **Modular Execution:** If yes, execute the specific provisioning logic.
3.  **Fallback:** If no, fallback to the standard generic `apt` or `brew` install.

This architecture mirrors mature orchestration systems (like Terraform Providers or Ansible Modules), ensuring the core engine remains clean while supporting infinitely complex, heterogeneous software installations.

#### Planned Feature: First-Class Snap Support (The `--snap` Flag)

While `apt` is the traditional default for Linux packages, many modern proprietary applications (like Postman, Slack, and Spotify) are now distributed primarily through Canonical's `snap` store. 

To handle this smoothly across operating systems, OmniSetup will introduce `--snap` as a first-class tracking flag alongside `--gui` and `--npm`.

**How it will work:**
The `--snap` flag will act as a contextual router based on the host OS.
```bash
# Example: omni-add postman --common --gui --snap

# On macOS: 
# The engine reads `--gui`, ignores `--snap`, and runs: brew install --cask postman

# On Linux: 
# The engine reads `--snap`, ignores `apt`, and runs: sudo snap install postman --classic
```
---