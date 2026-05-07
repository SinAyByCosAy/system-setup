# 🧰 OmniSetup: System Bootstrapper

OmniSetup is a lightweight, cross-platform (macOS and Linux) utility designed to bootstrap fresh machines and automatically track your installed tools in version-controlled text files. 

## 🎯 Who is it for?
This tool is built for developers who want a reproducible environment without the overhead of heavy infrastructure tools like Ansible or Nix. It replaces manual installation steps with a streamlined, self-documenting workflow.

## 🧠 What This Does

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

## 🛠️ Commands & Flags Guide

OmniSetup abstracts away the underlying OS package managers by using standard wrapper commands combined with tracking flags. 

### 1. Core Commands (The Actions)
These commands determine *how* a package is installed or removed on your current system - required post first-time setup.

| Command | Action |
| :--- | :--- |
| `brew-add <tool>` | Installs a CLI tool via Homebrew (macOS). |
| `cask-add <tool>` | Installs a GUI application via Homebrew Cask (macOS). |
| `apt-add <tool>` | Installs a package via `apt` (Linux). |
| `npm-add <tool>` | Installs a Node.js package globally via `npm` (Cross-OS). |
| `add-tool <tool>` | Tracks a tool that is **already installed** on your system (skips installation). |
| `tool-rm <tool>`<br>*(or `remove-tool`)* | Uninstalls the package from the system and removes it from all tracked lists. |

### 2. Tracking Flags (The Intent)
Flags tell OmniSetup *where* to record the tool in your Git repository so it can be reproduced later.

| Flag | Description | File Modified |
| :--- | :--- | :--- |
| `--common` | Tracks the tool for **both** macOS and Linux. | `common/common-cli.txt`<br>*(or `common-gui.txt`)* |
| `--local` | Tracks the tool **only** for the current OS. | `mac/mac-cli.txt` <br>*(or `linux/linux-cli.txt`)* |
| `--gui` | Classifies the tool as a GUI app (often implicit with `cask-add`). | Changes target to `-gui.txt` files. |
| `--npm` | Tracks as an NPM package. | `npm-global.txt` |
| `--linux-name <name>` | Maps a different package name for Linux `apt` installs. | Appended inline (e.g., `docker|docker.io`) |
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
cask-add google-chrome --common