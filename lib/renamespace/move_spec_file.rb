# frozen_string_literal: true

require_relative 'directories'

class Renamespace
  class MoveSpecFile
    def initialize(paths:)
      @paths = paths
    end

    def call
      move unless missing? || paths.same?
    end

    private

    attr_reader :paths

    def move
      Renamespace::Directories.create_directories_to_file(destination_spec_path)
      FileUtils.mv(source_spec_path, destination_spec_path)
    end

    def warn_missing
      puts Rainbow("Warning: spec file missing for #{destination_spec_path}").orange
    end

    def missing?
      !(File.exist?(source_spec_path) || warn_missing)
    end

    def source_spec_path
      spec_path(paths.source)
    end

    def destination_spec_path
      spec_path(paths.destination)
    end

    def spec_path(path)
      path
        .sub('.rb', '_spec.rb')
        .sub(/^lib/, specs_dir)
    end

    def specs_dir
      Dir.exist?('spec/lib') ? 'spec/lib' : 'spec'
    end
  end
end
