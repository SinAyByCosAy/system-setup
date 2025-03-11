## For macOS

Need to install homebrew(package manager)

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

If the brew command is not found, put brew in the zshrc path.

```console
echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.zshrc
```

Clone the repo or download the files<br>
<ol>
  <li>
    mac-applications.txt → for GUI applications (casks)
  </li>
  <li>
    mac-formulas.txt → for CLI tools (formulas)
  </li>
</ol>
Go to the location of the files and run :

```console
xargs brew install --cask < mac-applications.txt
```

```console
xargs brew install < mac-formulas.txt
```

This will read all the list of applications from the file and pass them as arguments using the xargs utility.
