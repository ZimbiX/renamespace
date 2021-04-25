# frozen_string_literal: true

require 'pathname'

require_relative 'directories'
require_relative 'paths'

class Renamespace
  class ExpandRelativeRequiresInFileContent
    def initialize(content:, path:)
      @content = content
      @path = path
    end

    def call
      content
        .gsub(/require_relative '([^']+)'/) do
          "require '%s'" % expanded_require_path($1)
        end
    end

    private

    attr_reader :content, :path

    def expanded_require_path(relative_require_path)
      joined_path = File.join(require_dir, relative_require_path)
      Pathname.new(joined_path).cleanpath
    end

    def require_dir
      dir = Renamespace::Directories.dir_for_file_path(path)
      Renamespace::Paths.require_for_path(dir)
    end
  end
end
