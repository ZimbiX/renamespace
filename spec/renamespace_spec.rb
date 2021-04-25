# frozen_string_literal: true

require 'spec_helper'

require 'fileutils'

RSpec.describe Renamespace do
  let(:renamespace) do
    described_class.new(
      source_file_path: paths[0],
      destination_file_path: paths[1],
      can_omit_prefixes_count: 0,
    )
  end
end
