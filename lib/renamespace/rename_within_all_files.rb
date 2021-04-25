# frozen_string_literal: true

require_relative 'paths'
require_relative 'rename_within_file_content'
require_relative 'replacements_logger'

class Renamespace
  class RenameWithinAllFiles
    def initialize(paths:, can_omit_prefixes_count:)
      @paths = paths
      @can_omit_prefixes_count = can_omit_prefixes_count
    end

    def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      logged_replacements = []
      Renamespace::Paths.all_ruby_file_paths.each do |path|
        content_orig = File.read(path)
        content_new = rename_within_file_content(content_orig)
        File.write(path, content_new) unless content_orig == content_new
      end
    end

    attr_reader :can_omit_prefixes_count

    private

    def rename_within_file_content(content)
      Renamespace::RenameWithinFileContent.new(
        paths: paths,
        content: content,
        replacements_logger: replacements_logger,
        can_omit_prefixes_count: can_omit_prefixes_count,
      ).call
    end

    def replacements_logger
      @replacements_logger ||= Renamespace::ReplacementsLogger.new
    end

    attr_reader :paths
  end
end
