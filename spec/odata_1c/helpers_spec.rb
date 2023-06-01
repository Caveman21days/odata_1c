require 'spec_helper'

RSpec.describe Odata1c::Helpers do
  describe '.connection_url' do
    context 'with ssl' do
      it "returns connection url" do
        expect(Odata1c::Helpers.connection_url('192.168.242.150', '', 'DemoHRM1', true)).to eq("https://192.168.242.150:/DemoHRM1/odata/standard.odata")
      end
    end

    context 'without ssl' do
      it "returns connection url" do
        expect(Odata1c::Helpers.connection_url('192.168.242.150', '', 'DemoHRM1', false)).to eq("http://192.168.242.150:/DemoHRM1/odata/standard.odata")
      end
    end
  end

  describe '.concat_urls' do
    it 'concats urls correctly when first url has / as last symbol' do
      expect(Odata1c::Helpers.concat_urls('a/', 'b')).to eq('a/b')
    end

    it 'concats urls correctly when second url has / as first symbol' do
      expect(Odata1c::Helpers.concat_urls('a', '/b')).to eq('a/b')
    end

    it 'concats urls correctly when both of urls have slash' do
      expect(Odata1c::Helpers.concat_urls('a/', '/b')).to eq('a/b')
    end
  end

  describe '.converting_to_nil' do
    let(:pseudo_nil_response) { [{ attr1: '', attr2: "0001-01-01T00:00:00", attr3: '', attr4: "00000000-0000-0000-0000-000000000000" }] }
    it 'converts pseudo-nils to nil' do
      expect(Odata1c::Helpers.convert_to_nil(pseudo_nil_response)).to eq [{ attr1: nil, attr2: nil, attr3: nil, attr4: nil }]
    end
  end
end