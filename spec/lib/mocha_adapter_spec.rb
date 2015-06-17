require 'rails_helper'

describe MochaAdapter do
  let(:adapter) { described_class.new }
  let(:count) { 42 }
  let(:failed) { 25 }
  let(:stderr) { "#{count-failed} passing (20ms)\n\n#{failed} failing" }

  describe '#parse_output' do
    it 'returns the correct numbers' do
      expect(adapter.parse_output(stderr: stderr)).to eq(count: count, failed: failed)
    end
  end
end
