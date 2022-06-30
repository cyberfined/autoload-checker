# frozen_string_literal: true

require 'fileutils'
require 'spec_helper'
require 'stringio'
require 'tmpdir'

describe AutoloadChecker do
  describe '#call' do
    subject(:check) { autoload_checker.call }

    let(:autoload_checker) do
      described_class.new(root_dirs: [path], correct: correct, output: output)
    end
    let(:fixes) { autoload_checker.fixes }
    let(:output) { StringIO.new }

    shared_examples 'returns success' do
      it 'returns success' do
        check
        expect(fixes).to be_empty
        expect(output.string).to be_empty
      end
    end

    shared_examples 'returns error' do
      it 'returns error' do
        check
        expect(output.string.split("\n")).to match_array(expected_fixes.map(&:pretty_error))
      end
    end

    shared_context 'corrects files' do
      let(:tmp_dir) { Pathname.new(Dir::mktmpdir) }
      let(:path) { tmp_dir.join(original_path.basename) }

      before do
        FileUtils.cp_r(original_path, path)
        check
      end

      it 'corrects files' do
        expect(output.string).to be_empty
        expect(dirs_eq(fixes_dir, path)).to eq(true)
      end
    end

    context 'without fixes' do
      let(:correct) { false }

      context 'with single class' do
        let(:path) { fixtures_root.join('successful', 'single_class') }

        include_examples 'returns success'
      end

      context 'with single module' do
        let(:path) { fixtures_root.join('successful', 'single_module') }

        include_examples 'returns success'
      end

      context 'class with inner definitions' do
        let(:path) { fixtures_root.join('successful', 'class_with_inner_definitions') }

        include_examples 'returns success'
      end

      context 'with class in file with different name' do
        let(:path) { fixtures_root.join('successful', 'class_in_file_with_different_name') }

        include_examples 'returns success'
      end

      context 'with many modules and classes' do
        let(:path) { fixtures_root.join('successful', 'many_classes_and_modules') }

        include_examples 'returns success'
      end
    end

    context 'with fixes' do
      context 'without correct' do
        let(:correct) { false }

        context 'with class without class definition' do
          let(:path) do
            fixtures_root.join('failed', 'originals', 'with_class_without_class_definition')
          end
          let(:expected_fixes) do
            [
              Namespace::Fix.new(
                file: path.join('bar', 'baz.rb'), const_name: 'Bar', from: :class, to: :module
              )
            ]
          end

          include_context 'returns error'
        end

        context 'with conflicted definitions' do
          let(:path) { fixtures_root.join('failed', 'originals', 'with_conflicted_definitions') }
          let(:expected_fixes) do
            [
              Namespace::Fix.new(
                file: path.join('fooz', 'bar', 'baz.rb'),
                const_name: 'Bar',
                from: :module,
                to: :class
              ),
              Namespace::Fix.new(
                file: path.join('fooz', 'baz', 'bar.rb'),
                const_name: 'Baz',
                from: :module,
                to: :class
              )
            ]
          end

          include_context 'returns error'
        end
      end

      context 'with correct' do
        let(:correct) { true }

        context 'with class without class definition' do
          let(:original_path) do
            fixtures_root.join('failed', 'originals', 'with_class_without_class_definition')
          end
          let(:fixes_dir) do
            fixtures_root.join('failed', 'fixes', 'with_class_without_class_definition')
          end

          include_context 'corrects files'
        end

        context 'with conflicted definitions' do
          let(:original_path) do
            fixtures_root.join('failed', 'originals', 'with_conflicted_definitions')
          end
          let(:fixes_dir) { fixtures_root.join('failed', 'fixes', 'with_conflicted_definitions') }

          include_context 'corrects files'
        end
      end
    end
  end

  private

  def dirs_eq(first, second)
    Dir.new(first).each do |file|
      next if ['.', '..'].include?(file)

      first_path = first.join(file)
      second_path = second.join(file)

      if !second_path.exist?
        return false
      elsif first_path.directory?
        return false if !second_path.directory? || !dirs_eq(first_path, second_path)
      elsif second_path.directory?
        return false
      elsif File.read(first_path) != File.read(second_path)
        return false
      end
    end

    true
  end
end
