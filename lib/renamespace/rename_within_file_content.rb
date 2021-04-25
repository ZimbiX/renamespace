# frozen_string_literal: true

require_relative 'paths'

class Renamespace
  class RenameWithinFileContent
    def initialize(paths:, content:, can_omit_prefixes_count:, replacements_logger:)
      @paths = paths
      @content_orig = content
      @can_omit_prefixes_count = can_omit_prefixes_count
      @replacements_logger = replacements_logger
    end

    def call
      content_orig
        .then(&method(:replace_require_paths))
        .then(&method(:replace_references))
    end

    def replace_require_paths(content)
      content.gsub(paths.source_require_path, paths.destination_require_path)
    end

    def replace_references(content)
      (1 + can_omit_prefixes_count).times do
        replacements_logger.log(search_str, replace_str)
        content = content.gsub(search_str, replace_str)
        namespace_elements_source.shift
        namespace_elements_dest.shift
      end
      content
    end

    def search_str
      namespace_elements_source.join('::')
    end

    def replace_str
      namespace_elements_dest.join('::')
    end

    def namespace_elements_source
      @namespace_elements_source ||= paths.source_namespace_elements
    end

    def namespace_elements_dest
      @namespace_elements_dest ||= paths.destination_namespace_elements
    end

    private

    attr_reader :paths, :content_orig, :can_omit_prefixes_count, :replacements_logger
  end
end
