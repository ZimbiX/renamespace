# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renamespace::MoveAndRenamespaceSourceFile do
  subject(:move_and_renamespace_source_file) do
    described_class.new(
      paths: paths_obj,
      no_superclass_prefixing: false,
    ).call
  end

  let(:paths_obj) do
    Renamespace::Paths.new(
      source: paths[0],
      destination: paths[1],
    )
  end

  before do
    FileUtils.rm_rf('spec/test-app')
    Dir.mkdir('spec/test-app')
    Dir.chdir('spec/test-app')
    FileUtils.mkdir_p('lib/dex_registration/models')
    File.write('lib/dex_registration/models/cursor.rb', 'some-content')
  end

  after do
    Dir.chdir('../..')
  end

  context 'when the number of namespaces is the same' do
    let(:paths) do
      %w[
        lib/dex_registration/models/cursor.rb
        lib/dex_registration/cursors/model.rb
      ]
    end

    it 'moves the file' do
      move_and_renamespace_source_file
      expect(File.exist?(paths[0])).to eq(false)
      expect(File.read(paths[1])).to eq('some-content')
    end
  end

  context 'when the paths are the same' do
    let(:paths) do
      %w[
        lib/dex_registration/models/cursor.rb
        lib/dex_registration/models/cursor.rb
      ]
    end

    it 'does not move the file' do
      move_and_renamespace_source_file
      expect(File.exist?(paths[0])).to eq(true)
      expect(File.read(paths[0])).to eq('some-content')
    end
  end
end
