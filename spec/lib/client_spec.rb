# frozen_string_literal: true

# Gnfinder is a namespace module for gndinfer gem.
describe Gnfinder::Client do
  let(:subject) { Gnfinder::Client.new }

  describe '#ping' do
    it 'connects to the server' do
      expect(subject.ping).to eq 'pong'
    end
  end

  describe '#find_names' do
    it 'returns list of name_strings' do
      names = subject.find_names
      expect(names[0].value).to eq 'Pardosa moesta'
    end
  end
end
