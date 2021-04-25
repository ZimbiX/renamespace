# frozen_string_literal: true

class Renamespace
  class ReplacementsLogger
    def initialize
      @logged_replacements = []
    end

    def log(a, b)
      unless logged_replacements.include?([a, b])
        logged_replacements << [a, b]
        puts Rainbow('%s -> %s' % [a, b]).blue
      end
    end

    private

    attr_accessor :logged_replacements
  end
end
