# frozen_string_literal: true

class Renamespace
  Paths = Struct.new(:source, :destination, keyword_init: true) do
    def self.namespace_for_path(path)
      namespace_elements_for_path(path).join('::')
    end

    def self.require_for_path(path)
      path_elements_for_require(path).join('/')
    end

    def self.namespace_elements_for_path(path)
      path_elements_for_require(path)
        .map(&method(:namespace_element_from_path_element))
    end

    def self.path_elements_for_require(path)
      path.sub(%r{^lib/}, '').chomp('.rb').split('/')
    end

    def self.namespace_element_from_path_element(path_element)
      custom_camelcasings.fetch(path_element) { path_element.upper_camelcase }
    end

    def self.custom_camelcasings
      {
        'greensync' => 'GreenSync',
      }
    end

    def self.all_ruby_file_paths
      (Dir.glob('**/*.rb') - %w[invert_namespaces.rb renamespace.rb])
    end

    def source_namespace
      self.class.namespace_for_path(source)
    end

    def destination_namespace
      self.class.namespace_for_path(destination)
    end

    def source_namespace_elements
      self.class.namespace_elements_for_path(source)
    end

    def destination_namespace_elements
      self.class.namespace_elements_for_path(destination)
    end

    def source_require_path
      self.class.require_for_path(source)
    end

    def destination_require_path
      self.class.require_for_path(destination)
    end

    def same?
      source == destination
    end
  end
end
