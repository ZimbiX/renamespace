# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Renamespace::RenamespaceFileContent do
  subject(:result_content) do
    described_class.new(
      paths: paths_obj,
      no_superclass_prefixing: false,
    ).call(source_content)
  end

  let(:paths_obj) do
    Renamespace::Paths.new(
      source: paths[0],
      destination: paths[1],
    )
  end

  context 'when the number of namespaces is the same' do
    let(:paths) do
      %w[
        lib/dex_registration/models/cursor.rb
        lib/dex_registration/cursors/model.rb
      ]
    end

    let(:source_content) do
      <<~RUBY
        module DexRegistration
          module Models
            class Cursor
            end
          end
        end
      RUBY
    end

    let(:expected_result_content) do
      <<~RUBY
        module DexRegistration
          module Cursors
            class Model
            end
          end
        end
      RUBY
    end

    it 'updates the namespacing' do
      expect(result_content).to eq(expected_result_content)
    end
  end

  context 'when the number of namespaces differs - one added' do
    let(:paths) do
      %w[
        lib/dex_registration/tasks/import_registrations_csv.rb
        lib/dex_registration/registrations/tasks/import_csv.rb
      ]
    end

    let(:source_content) do
      <<~RUBY
        module DexRegistration
          module Tasks
            class ImportRegistrationsCsv
            end
          end
        end
      RUBY
    end

    let(:expected_result_content) do
      <<~RUBY
        module DexRegistration
          module Registrations; module Tasks
            class ImportCsv
            end
          end
        end; end
      RUBY
    end

    it 'updates the namespacing, including adding the new namespace' do
      expect(result_content).to eq(expected_result_content)
    end
  end

  context 'when the number of namespaces differs - two added' do
    let(:paths) do
      %w[
        lib/a/b/c/q.rb
        lib/a/x/y/z/c/q.rb
      ]
    end

    let(:source_content) do
      <<~RUBY
        module A
          module B
            module C
              module Q
              end
            end
          end
        end
      RUBY
    end

    let(:expected_result_content) do
      <<~RUBY
        module A
          module X; module Y; module Z
            module C
              module Q
              end
            end
          end
        end; end; end
      RUBY
    end

    it 'updates the namespacing, including adding the new namespaces' do
      expect(result_content).to eq(expected_result_content)
    end
  end

  context 'with inheritance' do
    let(:paths) do
      %w[
        lib/my_app/models/site.rb
        lib/my_app/sites/model.rb
      ]
    end

    let(:source_content) do
      <<~RUBY
        module MyApp
          module Models
            class Site < BaseModel
            end
          end
        end
      RUBY
    end

    let(:expected_result_content) do
      <<~RUBY
        module MyApp
          module Sites
            class Model < Models::BaseModel
            end
          end
        end
      RUBY
    end

    it 'expands the namespacing of the superclass only as necessary' do
      expect(result_content).to eq(expected_result_content)
    end
  end

  context 'with inheritance from a root class' do
    let(:paths) do
      %w[
        lib/a/x.rb
        lib/b/x.rb
      ]
    end

    let(:source_content) do
      <<~RUBY
        module App
          module A
            class X < ::Ultra
            end
          end
        end
      RUBY
    end

    let(:expected_result_content) do
      <<~RUBY
        module App
          module B
            class X < ::Ultra
            end
          end
        end
      RUBY
    end

    it 'preserves the namespacing of the superclass' do
      expect(result_content).to eq(expected_result_content)
    end
  end

  context 'with namespaces having the same names' do
    let(:paths) do
      %w[
        lib/a/b/a.rb
        lib/x/y/z.rb
      ]
    end

    let(:source_content) do
      <<~RUBY
        module A
          module B
            class A
            end
          end
        end
      RUBY
    end

    let(:expected_result_content) do
      <<~RUBY
        module X
          module Y
            class Z
            end
          end
        end
      RUBY
    end

    it 'preserves the namespacing of the superclass' do
      pending
      expect(result_content).to eq(expected_result_content)
    end
  end
end
