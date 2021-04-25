# frozen_string_literal: true

require 'fileutils'

require 'facets/string/camelcase'
require 'rainbow'

require_relative 'renamespace/directories'
require_relative 'renamespace/expand_relative_requires_within_all_files'
require_relative 'renamespace/move_and_renamespace_source_file'
require_relative 'renamespace/move_spec_file'
require_relative 'renamespace/rename_within_all_files'
require_relative 'renamespace/paths'
require_relative 'renamespace/version'

class Renamespace
  def initialize(source_file_path:, destination_file_path:, can_omit_prefixes_count:)
    @paths = Renamespace::Paths.new(
      source: source_file_path,
      destination: destination_file_path,
    )
    @can_omit_prefixes_count = can_omit_prefixes_count
  end

  def call
    move_and_renamespace_source_file
    move_spec_file
    expand_relative_requires_within_all_files
    rename_within_all_files
    remove_empty_dirs
  end

  private

  attr_reader :paths, :can_omit_prefixes_count

  def move_and_renamespace_source_file
    Renamespace::MoveAndRenamespaceSourceFile.new(paths: paths).call
  end

  def move_spec_file
    Renamespace::MoveSpecFile.new(paths: paths).call
  end

  def expand_relative_requires_within_all_files
    Renamespace::ExpandRelativeRequiresWithinAllFiles.new.call
  end

  def rename_within_all_files
    Renamespace::RenameWithinAllFiles.new(paths: paths, can_omit_prefixes_count: can_omit_prefixes_count).call
  end

  def remove_empty_dirs
    Renamespace::Directories.remove_empty_dirs
  end
end
