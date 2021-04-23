# frozen_string_literal: true

require_relative 'renamespace'

RSpec.describe Renamespace do
  let(:renamespace) do
    described_class.new(
      source_file_path: paths[0],
      destination_file_path: paths[1],
    )
  end

  describe '#renamespace_file_content' do
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
        expect(renamespace.send(:renamespace_file_content, source_content)).to eq(expected_result_content)
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
        expect(renamespace.send(:renamespace_file_content, source_content)).to eq(expected_result_content)
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
        expect(renamespace.send(:renamespace_file_content, source_content)).to eq(expected_result_content)
      end
    end

    context 'with inheritance' do
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
              class X < Super
              end
            end
          end
        RUBY
      end

      let(:expected_result_content) do
        <<~RUBY
          module App
            module B
              class X < A::Super
              end
            end
          end
        RUBY
      end

      it 'expands the namespacing of the superclass only as necessary' do
        expect(renamespace.send(:renamespace_file_content, source_content)).to eq(expected_result_content)
      end
    end
  end
end
