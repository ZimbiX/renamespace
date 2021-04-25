# frozen_string_literal: true

class Renamespace
  class ReplacementsLogger
    def initialize
      @logged_replacements = []
    end

    def log(search_str, replace_str)
      return if logged_replacements.include?([search_str, replace_str])

      logged_replacements << [search_str, replace_str]
      puts Rainbow('%s -> %s' % [search_str, replace_str]).blue
    end

    private

    attr_accessor :logged_replacements
  end
end
