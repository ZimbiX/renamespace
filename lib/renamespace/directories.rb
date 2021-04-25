# frozen_string_literal: true

class Renamespace
  module Directories
    def self.create_directories_to_file(file_path)
      FileUtils.mkdir_p(dir_for_file_path(file_path))
    end

    def self.dir_for_file_path(file_path)
      file_path.sub(%r{/[^/]+$}, '')
    end

    def self.remove_empty_dirs
      Dir['**/'].reverse_each { |d| Dir.rmdir(d) if Dir.empty?(d) }
    end
  end
end
