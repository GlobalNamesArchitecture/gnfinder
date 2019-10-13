# frozen_string_literal: true

# Gnfinder is a namespace module for gndinfer gem.
describe Gnfinder::Client do
  let(:subject) { Gnfinder::Client.new }

  describe '#ping' do
    it 'connects to the server' do
      expect(subject.ping).to eq 'pong'
    end
  end

  describe '#version' do
    it 'returns version of Go gnfindera' do
      expect(subject.gnfinder_version.version).to match(/^v\d\.\d\.\d/)
    end
  end

  describe '#find_names' do
    it 'returns list of name_strings' do
      names = subject.find_names('Pardosa moesta is a spider').names
      expect(names[0].name).to eq 'Pardosa moesta'
      expect(names[0].verbatim).to eq 'Pardosa moesta'
    end

    it 'supports no_bayes option' do
      names = subject.find_names('Pardosa moesta is a spider').names
      expect(names[0].odds).to be > 10.0

      opts = { no_bayes: true }
      names = subject.find_names('Pardosa moesta is a spider', opts).names
      expect(names[0].odds).to eq 0.0
    end

    it 'supports language option' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to be false

      opts = { language: 'deu' }
      res = subject.find_names('Pardosa moesta is a spider', opts)
      expect(res.language).to eq 'deu'
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to be false
    end

    it 'silently ignores unknown language' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to be false

      opts = { language: 'whatisit' }
      res = subject.find_names('Pardosa moesta is a spider', opts)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to be false
    end

    it 'supports detect_language option' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to be false

      opts = { detect_language: true }
      res = subject.find_names(
        'Pardosa moesta это латинское название одного паука', opts
      )
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq 'rus'
      expect(res.detect_language).to be true

      opts = { detect_language: true }
      res = subject.find_names(
        'Pardosa moesta ist ein lateinischer Name für eine kleine Spinne', opts
      )
      expect(res.language).to eq 'deu'
      expect(res.language_detected).to eq 'deu'
      expect(res.detect_language).to be true
      opts = { detect_language: true }
      res = subject.find_names(
        'Pardosa moesta это латинское название одного паука', opts
      )
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq 'rus'
      expect(res.detect_language).to be true
    end

    it 'supports verification option' do
      opts = { verification: true }
      names = subject.find_names('Pardosa moesta is a spider', opts).names
      expect(names[0].verification.best_result.match_type).to eq :EXACT
    end

    it 'supports verification with sources' do
      opts = { verification: true, sources: [1, 4] }
      names = subject.find_names('Pardosa moesta is a spider', opts).names
      expect(names[0].verification.preferred_results[0].data_source_title)
        .to eq 'Catalogue of Life'
      expect(names[0].verification.preferred_results[1].data_source_title)
        .to eq 'NCBI'
      expect(names[0].verification.best_result.data_source_title)
        .to eq 'Catalogue of Life'
    end

    it 'returns the position of a name in a text' do
      names = subject.find_names('Pardosa moesta is a spider').names
      expect(names[0].offset_start).to eq 0
      expect(names[0].offset_end).to eq 14
    end

    it 'works with utf8 text' do
      names = subject.find_names('Pedicia apusenica (Ujvárosi and Starý 2003)')
                     .names
      expect(names[0].name).to eq 'Pedicia apusenica'
    end

    it 'gets metadata' do
      res = subject.find_names('Pardosa moesta is a very interesting spider')
      expect(res.date).to match(/[\d]{4}/)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to eq false
      expect(res.total_tokens).to be 7
      expect(res.total_candidates).to be 1
      expect(res.total_names).to be 1
    end

    it 'gets metadata with language option' do
      opts = { language: 'deu' }
      res = subject
            .find_names('Pardosa moesta is a very interesting spider', opts)
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to eq false
      expect(res.language).to eq 'deu'
    end

    it 'ignores language option if language string is unknown' do
      opts = { language: 'German' }
      res = subject
            .find_names('Pardosa moesta is a very interesting spider', opts)
      expect(res.finder_version).to match(/^v\d\.\d\.\d/)
      expect(res.language_detected).to eq ''
      expect(res.detect_language).to eq false
      expect(res.language).to eq 'eng'
    end
  end
end
