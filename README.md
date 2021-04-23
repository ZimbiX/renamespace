# Renamespace

A command-line tool to help Ruby developers refactor class/module namespacing.

## Contents

<!-- MarkdownTOC autolink=true -->

- [Intro](#intro)
- [Installation](#installation)
- [Usage](#usage)
- [Example](#example)
- [More usage info](#more-usage-info)
- [Development](#development)
  - [Release](#release)

<!-- /MarkdownTOC -->

## Intro

Renamespaces a Ruby source file:

- Moves the file
- Updates, to match the new location, the name of the class/module within the file, including its namespacing
- Updates usages of the class/module
- Updates the path to the file in all requires
- Moves the associated spec file

Class/module namespaces are derived from the paths provided.

If you change the number of namespaces, expect to have to run RuboCop autocorrect afterwards to clean up formatting.

## Installation

The executable is distributed as a gem. You can install it from GitHub Packages directly like so:

```bash
$ gem install --clear-sources --source "https://$GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN@rubygems.pkg.github.com/greensync" renamespace
```

And then if you're using rbenv:

```bash
$ rbenv rehash
```

## Usage

```bash
$ renamespace SOURCE_FILE_PATH DESTINATION_FILE_PATH
```

## Example

With:

```ruby
# lib/my_app/models/site.rb

module MyApp
  module Models
    class Site < BaseModel
    end
  end
end
```

Run:

```bash
$ renamespace lib/my_app/models/site.rb lib/my_app/sites/model.rb
```

Result:

```ruby
# lib/my_app/sites/model.rb

module MyApp
  module Sites
    class Model < Models::BaseModel
    end
  end
end
```

## More usage info

See:

```bash
$ renamespace --help
```

## Development

### Release

First, [make sure your credentials are set up for GitHub Package Registry according to the Handbook](https://handbook.greensync.org/product/intro/getting-started/#github-package-registry-and-ruby-gems).

To release a new version:

```bash
$ auto/release/update-version && auto/release/tag && auto/release/publish
```

This takes care of the whole process:

- Incrementing the version number (the patch number by default)
- Tagging & pushing commits
- Publishing the gem to GitHub Packages
- Creating a draft GitHub release

To increment the minor or major versions instead of the patch number, run `auto/release/update-version` with `--minor` or `--major`.
