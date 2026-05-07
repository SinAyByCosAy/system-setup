# 🧰 OmniSetup: System Bootstrapper

OmniSetup is a lightweight, cross-platform (macOS and Linux) utility designed to bootstrap fresh machines and automatically track your installed tools in version-controlled text files. 

## 🎯 Who is it for?
This tool is built for developers who want a reproducible environment without the overhead of heavy infrastructure tools like Ansible or Nix. It replaces manual installation steps with a streamlined, self-documenting workflow.

## 🚀 First-Time Setup
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
    <li>Common(MacOS and Linux): <a href="https://github.com/SinAyByCosAy/OmniSetup/blob/master/npm-global.txt">npm-global.txt</a>, [common-cli.txt](./common/common-cli.txt)!, [common-gui.txt](./common/common-gui.txt)!</li>
    <li>Mac Only: [mac-applications.txt](./mac/brew.sh)!, [mac-formulas.txt](./mac/mac-formulas.txt)!</li>
    <li>Linux Only: [linux-packages.txt](./linux/linux-packages.txt)!</li>
</ul>

This is a <b>Declarative System Bootstrapper</b> where: you describe the desired environment state
and the tool figures out how to make the machine match it.
<br>
Instead of manually commanding: install this -> configure this -> add to PATH <br>
You declare: "These are the tools and configurations my environment should contain." and the bootstrapper reconstructs it.