# Renamespace

A command-line tool to help Ruby developers refactor class/module namespacing.

## Contents

<!-- MarkdownTOC autolink=true -->

- [Intro](#intro)
- [Installation](#installation)
- [Usage](#usage)
- [Example](#example)
- [More usage info](#more-usage-info)

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

The executable is distributed as a gem.

```bash
$ gem install --clear-sources --source "https://$GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN@rubygems.pkg.github.com/greensync" renamespace
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
