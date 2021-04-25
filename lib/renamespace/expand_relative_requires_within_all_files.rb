# frozen_string_literal: true

require_relative 'expand_relative_requires_in_file_content'

class Renamespace
  class ExpandRelativeRequiresWithinAllFiles
    def call
      all_suitable_ruby_file_paths.each do |path|
        content_orig = File.read(path)
        content_new = expand_in_file(content_orig, path)
        File.write(path, content_new) unless content_orig == content_new
      end
    end

    private

    def expand_in_file(content_orig, path)
      Renamespace::ExpandRelativeRequiresInFileContent.new(content: content_orig, path: path).call
    end

    def all_suitable_ruby_file_paths
      Renamespace::Paths.all_ruby_file_paths - exclusions
    end

    def exclusions
      %w[
        spec/spec_helper.rb
        renamespace_spec.rb
        lib/bootstrap.rb
      ]
    end
  end
end
