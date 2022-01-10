# frozen_string_literal: true

# Gnfinder is a namespace module for gndinfer gem.
describe Gnfinder::Client do
  let(:subject) { Gnfinder::Client.new }
  # let(:subject) { Gnfinder::Client.new(host = '0.0.0.0', port = 8080) }

  describe '#ping' do
    it 'connects to the server' do
      expect(subject.ping).to eq 'pong'
    end
  end

  describe '#version' do
    it 'returns version of Go gnfinder' do
      expect(subject.gnfinder_version.version).to match(/^v\d+\.\d+\.\d+/)
    end
  end

  describe '#find_file' do
    dir = File.absolute_path(__dir__)
    path = File.join(dir, '..', 'files', 'test.txt')

    it 'returns list of name_strings' do
      names = subject.find_file(path).names
      expect(names[0].name).to eq 'Monochamus galloprovincialis'
      expect(names[0].cardinality).to eq 2
    end

    it 'works with images' do
      img = File.join(dir, '..', 'files', 'image.jpg')
      names = subject.find_file(img).names
      expect(names[0].name).to eq 'Baccha'
      expect(names[0].cardinality).to eq 1
    end

    it 'works with images' do
      pdf = File.join(dir, '..', 'files', 'file.pdf')
      names = subject.find_file(pdf).names
      expect(names[0].name).to eq 'Passiflora'
      expect(names[0].cardinality).to eq 1
    end

    it 'supports no_bayes option' do
      names1 = subject.find_file(path).names
      opts = { no_bayes: true }
      names2 = subject.find_file(path, opts).names
      expect(names1.size).to be > names2.size
    end

    it 'supports language option' do
      res = subject.find_file(path)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false

      opts = { language: 'deu' }
      res = subject.find_file(path, opts)
      expect(res.language).to eq 'deu'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false
    end

    it 'silently ignores unknown language' do
      res = subject.find_file(path)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false

      opts = { language: 'whatisit' }
      res = subject.find_file(path, opts)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false
    end

    it 'can detect language' do
      opts = { language: 'detect' }
      res = subject.find_file(path, opts)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq 'eng'
      expect(res.detect_language).to be true
    end

    it 'supports tokens around option' do
      opts = { words_around: 2 }
      names = subject.find_file(path, opts).names
      expect(names[2].words_before).to eq %w[of beetle]
      expect(names[2].words_after).to eq %w[image Monochamus]
    end

    it 'supports verification option' do
      opts = { verification: true }
      names = subject.find_file(path, opts).names
      expect(names[0].verification.best_result.match_type).to eq 'Exact'
      expect(names[0].verification.best_result.matched_cardinality).to eq 2
    end

    it 'supports verification with sources' do
      opts = { sources: [1] }
      names = subject.find_file(path, opts).names
      expect(names[0].verification.results[0].data_source_title_short)
        .to eq 'Catalogue of Life'
      expect(names[0].verification.best_result.data_source_title_short)
        .to eq 'Catalogue of Life'
    end

    it 'returns the position of a name in a text' do
      names = subject.find_file(path).names
      expect(names[0].start).to eq 15
      expect(names[0].end).to eq 43
    end

    it 'breaks on wrong paths' do
      expect { subject.find_file('wrong/path') }.to raise_error(/No such file/)
    end
  end

  describe '#find_url' do
    it 'gets metadata about results' do
      res = subject.find_url('https://example.com')
      expect(res.words_around).to eq 0
      opts = { words_around: 2 }
      res = subject.find_url('https://example.com', opts)
      expect(res.words_around).to eq 2
    end

    it 'returns list of name_strings' do
      names = subject.find_url('https://en.wikipedia.org/wiki/Monochamus_galloprovincialis').names
      expect(names[0].name).to eq 'Monochamus galloprovincialis'
      expect(names[0].cardinality).to eq 2
    end
  end

  describe '#find_names' do
    it 'gets metadata about results' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.words_around).to eq 0
      opts = { words_around: 2 }
      res = subject.find_names(
        'It is very interesting that Pardosa moesta is a spider', opts
      )
      expect(res.words_around).to eq 2
    end

    it 'returns list of name_strings' do
      names = subject.find_names('Pardosa moesta is a spider').names
      expect(names[0].name).to eq 'Pardosa moesta'
      expect(names[0].verbatim).to eq 'Pardosa moesta'
      expect(names[0].cardinality).to eq 2
    end

    it 'finds nomenclatural annotation for a name' do
      names = subject.find_names('Pardosa moesta sp. n. is a spider').names
      expect(names[0].name).to eq 'Pardosa moesta'
      expect(names[0].annotation_nomen).to eq 'sp. n.'
      expect(names[0].annotation_nomen_type).to eq 'SP_NOV'
    end

    it 'supports no_bayes option' do
      names = subject.find_names('Pardosa moesta is a spider').names
      expect(names[0].odds_log10).to be > 2.0
      names = subject.find_names(
        'Falsificus erundiculus var. pridumalus is a spider'
      ).names
      expect(names.size).to eq 1

      opts = { no_bayes: true }
      names = subject.find_names('Pardosa moesta is a spider', opts).names
      expect(names[0].odds_log10).to eq nil
      names = subject.find_names(
        'Falsificus erundiculus var. pridumalus is a spider', opts
      ).names
      expect(names.size).to eq 0
    end

    it 'supports language option' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false

      opts = { language: 'deu' }
      res = subject.find_names('Pardosa moesta is a spider', opts)
      expect(res.language).to eq 'deu'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false
    end

    it 'silently ignores unknown language' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false

      opts = { language: 'whatisit' }
      res = subject.find_names('Pardosa moesta is a spider', opts)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false
    end

    it 'supports detect_language option' do
      res = subject.find_names('Pardosa moesta is a spider')
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to be false

      opts = { language: 'detect' }
      res = subject.find_names(
        'Pardosa moesta это латинское название одного паука', opts
      )
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq 'rus'
      expect(res.detect_language).to be true

      opts = { language: 'detect' }
      res = subject.find_names(
        'Pardosa moesta ist ein lateinischer Name für eine kleine Spinne', opts
      )
      expect(res.language).to eq 'deu'
      expect(res.language_detected).to eq 'deu'
      expect(res.detect_language).to be true

      opts = { language: 'detect' }
      res = subject.find_names(
        'Pardosa moesta это латинское название одного паука', opts
      )
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq 'rus'
      expect(res.detect_language).to be true
    end

    it 'supports tokens around option' do
      opts = { words_around: 2 }
      names = subject.find_names(
        'It is very interesting that Pardosa moesta is a spider', opts
      ).names
      expect(names[0].words_before).to eq %w[interesting that]
      expect(names[0].words_after).to eq %w[is a]
    end

    it 'supports verification option' do
      opts = { verification: true }
      names = subject.find_names('Pardosa moesta is a spider', opts).names
      expect(names[0].verification.best_result.match_type).to eq 'Exact'
      expect(names[0].verification.best_result.matched_cardinality).to eq 2
    end

    it 'supports verification with sources' do
      opts = { verification: true, sources: [1] }
      res = subject.find_names('Pardosa moesta is a spider', opts)
      names = res.names
      expect(names[0].verification.results[0].data_source_title_short)
        .to eq 'Catalogue of Life'
      expect(names[0].verification.best_result.data_source_title_short)
        .to eq 'Catalogue of Life'
    end

    it 'returns the position of a name in a text' do
      names = subject.find_names('Pardosa moesta is a spider').names
      expect(names[0].start).to eq 0
      expect(names[0].end).to eq 14
    end

    it 'works with utf8 text' do
      names = subject.find_names('Pedicia apusenica (Ujvárosi and Starý 2003)')
                     .names
      expect(names[0].name).to eq 'Pedicia apusenica'
    end

    it 'works with empty text' do
      names = subject.find_names('').names
      expect(names.size).to eq 0
    end

    it 'gets metadata' do
      res = subject.find_names('Pardosa moesta is a very interesting spider')
      expect(res.date).to match(/\d{4}/)
      expect(res.language).to eq 'eng'
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to eq false
      expect(res.total_words).to be 7
      expect(res.total_candidates).to be 1
      expect(res.total_names).to be 1
    end

    it 'gets metadata with language option' do
      opts = { language: 'deu' }
      res = subject
            .find_names('Pardosa moesta is a very interesting spider', opts)
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to eq false
      expect(res.language).to eq 'deu'
    end

    it 'ignores language option if language string is unknown' do
      opts = { language: 'German' }
      res = subject
            .find_names('Pardosa moesta is a very interesting spider', opts)
      expect(res.gnfinder_version).to match(/^v\d+\.\d+\.\d+/)
      expect(res.language_detected).to eq nil
      expect(res.detect_language).to eq false
      expect(res.language).to eq 'eng'
    end
  end
end
