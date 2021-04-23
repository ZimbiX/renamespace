# Renamespace

A command-line tool to help Ruby developers refactor class/module namespacing.

Renamespaces a Ruby source file:

- Moves the file
- Updates, to match the new location, the name of the class/module within the file, including its namespacing
- Updates usages of the class/module
- Updates the path to the file in all requires
- Moves the associated spec file

Class/module namespaces are derived from the paths provided.

## Contents

<!-- MarkdownTOC autolink=true -->

- [Installation](#installation)
- [Usage](#usage)

<!-- /MarkdownTOC -->

## Installation

The executable is distributed as a gem.

```bash
$ gem install --clear-sources --source "https://$GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN@rubygems.pkg.github.com/greensync" renamespace
```

## Usage

```bash
$ renamespace
```

e.g.:

```bash
$ renamespace lib/dex_registration/repositories/cursors.rb lib/dex_registration/cursors/repository.rb
```

For more info, see:

```bash
$ renamespace --help
```
