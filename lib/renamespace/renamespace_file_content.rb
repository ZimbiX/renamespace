# frozen_string_literal: true

class Renamespace
  class RenamespaceFileContent
    def initialize(paths:)
      @paths = paths
    end

    def call(content) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      content = content.dup
      source, dest = source_and_dest_namespace_elements_without_common_prefix
      namespace_element_replacements = dest.reverse.zip(source.reverse)
      namespace_element_replacements.each_with_index do |(namespace_element_new, namespace_element_old), i|
        old_parent_namespace = namespace_element_replacements.last(i + 1).map(&:last).reverse.join('::')
        old_parent_namespace += '::' unless old_parent_namespace.empty?
        if namespace_element_old
          # Replacing existing namespace
          content.sub!(/(class|module) #{namespace_element_old}\b( < (\S+))?/) do
            klass_line = "#{Regexp.last_match(1)} RENAMESPACED_#{namespace_element_new}"
            Regexp.last_match(3)&.tap do |superclass_orig|
              klass_line += ' < '
              klass_line += old_parent_namespace unless superclass_orig.start_with?('::')
              klass_line += superclass_orig
            end
            klass_line
          end
        else
          # Adding new namespace
          previous_new_namespace_element = namespace_element_replacements[i - 1].first
          content.sub!(
            /((class|module) RENAMESPACED_#{previous_new_namespace_element})/,
            "module RENAMESPACED_#{namespace_element_new}; \\1",
          )
          content.sub!(/^(end)/, '\1; end')
        end
      end
      content.gsub!('RENAMESPACED_', '')
      content
    end

    private

    attr_reader :paths

    def source_and_dest_namespace_elements_without_common_prefix
      source = paths.source_namespace_elements
      dest = paths.destination_namespace_elements
      source.each do
        break if source.first != dest.first

        source.shift
        dest.shift
      end
      [source, dest]
    end
  end
end
