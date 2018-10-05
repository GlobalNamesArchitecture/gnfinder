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
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].value).to eq 'Pardosa moesta'
      expect(names[0].verbatim).to eq 'Pardosa moesta'
    end

    it 'supports with_bayes option' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].odds).to eq 0.0

      opts = { with_bayes: true }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to be > 10.0
    end

    it 'supports language option' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].odds).to eq 0.0

      opts = { language: 'eng' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to be > 10.0

      opts = { language: 'deu' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to be > 10.0
    end

    it 'silently ignores unknown language' do
      names = subject.find_names('Pardosa moesta is a spider')
      expect(names[0].odds).to eq 0.0

      opts = { language: 'whatisit' }
      names = subject.find_names('Pardosa moesta is a spider', opts)
      expect(names[0].odds).to eq 0.0
    end
  end
end
