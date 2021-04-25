# frozen_string_literal: true

require_relative 'directories'
require_relative 'renamespace_file_content'

class Renamespace
  class MoveAndRenamespaceSourceFile
    def initialize(paths:)
      @paths = paths
    end

    def call
      log_source_and_destination_namespaces
      write_new_file
      delete_old_file
    end

    private

    attr_reader :paths

    def log_source_and_destination_namespaces
      puts '%s -> %s' % [paths.source_namespace, paths.destination_namespace]
    end

    def write_new_file
      Renamespace::Directories.create_directories_to_file(paths.destination)
      File.write(paths.destination, renamespaced_file_content)
    end

    def delete_old_file
      File.delete(paths.source) unless paths.same?
    end

    def renamespaced_file_content
      content = File.read(paths.source)
      Renamespace::RenamespaceFileContent.new(paths: paths).call(content)
    end
  end
end
