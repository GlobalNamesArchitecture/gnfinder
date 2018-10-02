describe Gnfinder do
  describe '.version' do
    it 'shows version' do
      expect(subject.version).to match(/\d+\.\d+.\d+/)
    end
  end
end
