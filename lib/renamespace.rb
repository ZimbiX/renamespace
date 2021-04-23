# frozen_string_literal: true

# require 'bundler/inline'

# gemfile do
#   source 'https://rubygems.org'
#   gem 'clamp'
#   gem 'facets'
#   gem 'rainbow'
# end

require 'fileutils'
require 'pathname'

require 'clamp'
require 'facets/string/camelcase'
require 'rainbow'

class Renamespace # rubocop:disable Metrics/ClassLength
  def initialize(source_file_path:, destination_file_path:)
    @source_file_path = source_file_path
    @destination_file_path = destination_file_path
  end

  def call
    renamespace_file
    move_spec_file
    expand_relative_requires_within_all_files
    rename_within_all_files
    remove_empty_dirs
  end

  private

  attr_reader :source_file_path, :destination_file_path

  def renamespace_file
    puts '%s -> %s' % [namespace_for_path(source_file_path), namespace_for_path(destination_file_path)]
    content_new = renamespace_file_content(File.read(source_file_path))
    create_directories_to_file(destination_file_path)
    File.write(destination_file_path, content_new)
    File.delete(source_file_path)
  end

  def move_spec_file
    unless File.exist?(spec_path(source_file_path))
      puts Rainbow("Warning: spec file missing for #{spec_path(destination_file_path)}").orange
      return
    end
    create_directories_to_file(spec_path(destination_file_path))
    FileUtils.mv(
      spec_path(source_file_path),
      spec_path(destination_file_path),
    )
  end

  def expand_relative_requires_within_all_files
    (all_ruby_file_paths - relative_requires_expansion_exclusions).each do |path|
      content_orig = File.read(path)
      content_new =
        content_orig
          .gsub(/require_relative '([^']+)'/) do
            joined_path = File.join(require_for_path(dir_for_file_path(path)), Regexp.last_match(1))
            "require '%s'" % Pathname.new(joined_path).cleanpath
          end
      File.write(path, content_new) unless content_orig == content_new
    end
  end

  def rename_within_all_files
    all_ruby_file_paths.each do |path|
      content_orig = File.read(path)
      content_new =
        content_orig
          .gsub(namespace_for_path(source_file_path), namespace_for_path(destination_file_path))
          .gsub(require_for_path(source_file_path), require_for_path(destination_file_path))
      File.write(path, content_new) unless content_orig == content_new
    end
  end

  def renamespace_file_content(content) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    content = content.dup
    source, dest = source_and_dest_namespace_elements_without_common_prefix
    namespace_element_replacements = dest.reverse.zip(source.reverse)
    namespace_element_replacements.each_with_index do |(namespace_element_new, namespace_element_old), i|
      old_parent_namespace = namespace_element_replacements.last(i + 1).map(&:last).reverse.join('::')
      old_parent_namespace += '::' unless old_parent_namespace.empty?
      if namespace_element_old
        # Replace existing namespace
        content.sub!(/(class|module) #{namespace_element_old}\b( < (\S+))?/) do
          "#{Regexp.last_match(1)} RENAMESPACED_#{namespace_element_new}" +
            (Regexp.last_match(3) ? " < #{old_parent_namespace}#{Regexp.last_match(3)}" : '')
        end
      else
        # Adding new namespace
        previous_new_namespace_element = namespace_element_replacements[i - 1].first
        content.sub!(/((class|module) RENAMESPACED_#{previous_new_namespace_element})/, "module RENAMESPACED_#{namespace_element_new}; \\1")
        content.sub!(/^(end)/, '\1; end')
      end
    end
    content.gsub!('RENAMESPACED_', '')
    content
  end

  def relative_requires_expansion_exclusions
    %w[
      spec/spec_helper.rb
      renamespace_spec.rb
    ]
  end

  def source_and_dest_namespace_elements_without_common_prefix
    source = namespace_elements_for_path(source_file_path)
    dest = namespace_elements_for_path(destination_file_path)
    source.each do
      break if source.first != dest.first

      source.shift
      dest.shift
    end
    [source, dest]
  end

  def namespace_for_path(path)
    namespace_elements_for_path(path).join('::')
  end

  def require_for_path(path)
    path_elements_for_require(path).join('/')
  end

  def namespace_elements_for_path(path)
    path_elements_for_require(path)
      .map(&method(:namespace_element_from_path_element))
  end

  def path_elements_for_require(path)
    path.sub(%r{^lib/}, '').chomp('.rb').split('/')
  end

  def namespace_element_from_path_element(path_element)
    custom_camelcasings.fetch(path_element) { path_element.upper_camelcase }
  end

  def custom_camelcasings
    {
      'greensync' => 'GreenSync',
    }
  end

  def all_ruby_file_paths
    (Dir.glob('**/*.rb') - %w[invert_namespaces.rb renamespace.rb])
  end

  def spec_path(path)
    possible_spec_paths = [
      path.sub('.rb', '_spec.rb').sub(/^lib/, 'spec'),
      path.sub('.rb', '_spec.rb').sub(/^lib/, 'spec/lib'),
    ]
    if File.exist?(possible_spec_paths[1])
      possible_spec_paths[1]
    else
      possible_spec_paths[0]
    end
  end

  def create_directories_to_file(file_path)
    FileUtils.mkdir_p(dir_for_file_path(file_path))
  end

  def dir_for_file_path(file_path)
    file_path.sub(%r{/[^/]+$}, '')
  end

  def remove_empty_dirs
    Dir['**/'].reverse_each { |d| Dir.rmdir(d) if Dir.empty?(d) }
  end
end

if __FILE__ == $PROGRAM_NAME
  Clamp do
    self.description = <<~TEXT
      Renamespaces a Ruby source file:

      - Moves the file
      - Updates, to match the new location, the name of the class/module within the file, including its namespacing
      - Updates usages of the class/module
      - Updates the path to the file in all requires
      - Moves the associated spec file

      Class/module namespaces are derived from the paths provided.
    TEXT

    parameter 'SOURCE_FILE_PATH', 'The current path of the Ruby source code file to renamespace'
    parameter 'DESTINATION_FILE_PATH', 'The desired desination path of the file'

    def execute
      Renamespace.new(
        source_file_path: source_file_path,
        destination_file_path: destination_file_path,
      ).call
    end
  end
end
