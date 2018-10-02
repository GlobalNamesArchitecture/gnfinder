describe Gnfinder::Client do
  let(:subject) { Gnfinder::Client.new }

  describe '.ping' do
    it 'connects to the server' do
      expect(subject.ping).to eq 'pong'
    end
  end
end
