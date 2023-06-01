require 'spec_helper.rb'

RSpec.describe Odata1c::Entity do
  let(:entity_name) { "Catalog_ФизическиеЛица" }
  let(:service) { Odata1c::Connection.new(host: '192.168.242.150', db_name: 'DemoHRM1', user: 'Администратор') }
  let(:entity) { service['Catalog_ФизическиеЛица'] }


  before do
    stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/$metadata").
      to_return(status: 200, body: "<Schema><EntityType Name='Catalog_ФизическиеЛица'><Property Name='Имя' Type='Edm.String' Nullable='false'/><Property Name='Фамилия' Type='Edm.String' Nullable='false'/><Property Name='Возраст' Type='Edm.Int64' Nullable='false'/><Property Name='Ref_Key' Type='Edm.String' Nullable='false'/></EntityType> <EntityType Name='InformationRegister_ФИОФизическихЛиц'><Property Name='Имя' Type='Edm.String' Nullable='false'/><Property Name='Ref_Key' Type='Edm.String' Nullable='false'/></EntityType></Schema>", headers: {})
  end

  describe '#list' do
    context 'without filter' do
      it 'returns array of EntityValues`s' do
        stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0?$format=json").
          to_return(status: 200, body: " {\r\n\"value\": [{\r\n\"Имя\": \"Игорь\"\r\n, \r\n\"Фамилия\": \"Булатов\"\r\n}]\r\n} ")
        expect(entity.list[0].class).to eq Odata1c::EntityValues
        expect(entity.list[0].values).to eq({"Имя" => "Игорь", "Фамилия" => "Булатов"})
      end
    end

    context 'without filter with select' do
      it 'returns array of EntityValues`s' do
        stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0?$format=json&$select=TEST").
          to_return(status: 200, body: " {\r\n\"value\": [{\r\n\"Имя\": \"Игорь\"\r\n, \r\n\"Фамилия\": \"Булатов\"\r\n}]\r\n} ")
        expect(entity.list(select: 'TEST')[0].class).to eq Odata1c::EntityValues
        expect(entity.list(select: "TEST")[0].values).to eq({"Имя" => "Игорь", "Фамилия" => "Булатов"})
      end
    end

    context 'with filter' do
      context 'with metadata-valid filter' do
        it 'returns filtered EntityValues' do
          stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0?$filter=%D0%98%D0%BC%D1%8F%20eq%20'%D0%98%D0%B3%D0%BE%D1%80%D1%8C'&$format=json").
            to_return(status: 200, body: " {\r\n\"value\": [{\r\n\"Имя\": \"Игорь\"\r\n, \r\n\"Фамилия\": \"Булатов\"\r\n}]\r\n} ")
          expect(entity.list("Имя eq 'Игорь'")[0].class).to eq Odata1c::EntityValues
          expect(entity.list("Имя eq 'Игорь'")[0].values).to eq({"Имя" => "Игорь", "Фамилия" => "Булатов"})
        end
      end
      context 'with invalid filter' do
        it 'raises Odata1c::ClientError (400 Bad Request)' do
          stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0?$filter=%D0%A4%D1%83%20eq%20'%D0%98%D0%B3%D0%BE%D1%80%D1%8C'&$format=json").
            to_return(status: 400)
          expect {entity.list("Фу eq 'Игорь'")}.to raise_error Odata1c::ClientError
        end
      end
    end
  end

  describe '#get' do
    context 'with valid key' do
      it 'returns EntityValues' do
        stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0('e09df266-7bf4-11e2-9362-001b11b25590')?$format=json").
          to_return(status: 200, body: "{\r\n\"Имя\": \"Игорь\"\r\n, \r\n\"Фамилия\": \"Булатов\"\r\n, \r\n\"Ref_Key\": \"e09df266-7bf4-11e2-9362-001b11b25590\"\r\n}")
        expect(entity.get("e09df266-7bf4-11e2-9362-001b11b25590").class).to eq Odata1c::EntityValues
        expect(entity.get("e09df266-7bf4-11e2-9362-001b11b25590").values).to eq({"Ref_Key" => "e09df266-7bf4-11e2-9362-001b11b25590", "Имя" => "Игорь", "Фамилия" => "Булатов"})
      end
    end
    context 'with invalid key' do
      it 'raises Odata1c::ClientError (400 Bad Request)' do
        stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0('e09df266-11')?$format=json").
          to_return(status: 400)
        expect {entity.get("e09df266-11").class}.to raise_error Odata1c::ClientError
      end
    end
  end

  describe '#build_response' do
    let(:entity) {service['Catalog_ФизическиеЛица']}

    it 'returns array of EntityValues' do
      expect(entity.build_response([{name: 'Foo'}]).first.class).to eq Odata1c::EntityValues
      expect(entity.build_response([{name: 'Foo'}]).first.values).to eq(name: 'Foo')
    end
  end

  describe '.url' do
    it 'returns normalized str for request' do
      expect(entity.url('abc')).to eq Addressable::URI.parse(service.service_url + '/' + entity.entity_name).normalize.to_s + 'abc'
    end
  end

  describe '.build_query' do
    it 'returns normalized query for request' do
      expect(entity.build_query(name: 'foo')).to eq "name=foo"
    end
  end

  describe '#properties' do
    let(:service) {double Odata1c::Connection}
    let(:entity) {described_class.new service, 'Catalog_ФизическиеЛица'}
    let(:properties_double) {double Odata1c::Properties}

    before do
      metadata = Odata1c::Connection::Metadata.try_convert('Catalog_ФизическиеЛица' => properties_double,
                                                           'Catalog_ЮридическиеЛица' => double(Odata1c::Properties))
      allow(service).to receive(:metadata).and_return metadata
    end

    it 'returns properties for this entity' do
      expect(entity.properties).to be properties_double
    end
  end

  describe '.detect_arg' do
    context 'argument is string' do
      it 'returns params for get request in odata-valid form' do
        expect(Odata1c::Entity.detect_arg('Foo')).to eq "('Foo')"
      end
    end
    context 'argument is map' do
      it 'returns params for get request in odata-valid form' do
        expect(Odata1c::Entity.detect_arg('Foo' => 'Bar', 'Bar' => 'Baz')).to eq "(Foo='Bar', Bar='Baz')"
      end
    end
  end

  describe '#write' do
    let(:entity2) {service['Catalog_ФизическиеЛица']}
    let(:post_request) { "http://192.168.242.150/DemoHRM1/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0?$format=json" }

    context 'empty or nil argument' do
      it 'raises InvalidAttributeError' do
        data = {}
        stub_request(:post, post_request).with(body: data, headers: { content_type: 'application/json' })
        expect {entity.write({})}.to raise_error Odata1c::InvalidArgumentError
        expect {entity.write(nil)}.to raise_error Odata1c::InvalidArgumentError
      end
    end
    context 'with metadata-valid argument' do
      it 'returns new EntityValues' do
        data = { 'Имя' => 'TEST' }
        stub_request(:post, post_request).with(body: data, headers: { content_type: 'application/json' }).to_return(status: 201, body: data.to_json)
        expect(entity.write(data).class).to eq Odata1c::EntityValues
        expect(entity.write(data).values).to eq data
      end
    end
    context 'with metadata-invalid argument' do
      it 'returns new EntityValues' do
        data = { 'BLABLA' => 'TEST' }
        stub_request(:post, post_request).with(body: data, headers: { content_type: 'application/json' })
        expect {entity.write(data)}.to raise_error Odata1c::InvalidArgumentError
      end
    end
  end

  describe '#update' do
    let(:entity2) {service['InformationRegister_ФИОФизическихЛиц']}
    let(:person_id) { "e35ede60-caeb-11e8-a45d-e269cdf4837d" }
    let(:patch_request) { "http://192.168.242.150/DemoHRM1/odata/standard.odata/InformationRegister_%D0%A4%D0%98%D0%9E%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D1%85%D0%9B%D0%B8%D1%86(e35ede60-caeb-11e8-a45d-e269cdf4837d)?$format=json" }

    context 'data is Hash' do
      context 'with not-empty data' do
        it 'updates EntityValues and returns new EntityValues' do
          data = { 'Имя' => 'TEST' }
          stub_request(:patch, patch_request).
          with(
            body: "{\"Имя\":\"TEST\"}",
            headers: { 'Content-Type'=>'application/json' }).to_return(status: 200, body: data.to_json, headers: {}
          )
          expect(entity2.update(person_id, data).class).to eq Odata1c::EntityValues
          expect(entity2.update(person_id, data).values).to eq({"Имя" => "TEST"})
        end
      end

      context 'with empty data' do
        it 'updates EntityValues and returns new EntityValues' do
          stub_request(:patch, patch_request).with(
            body: "{}",
            headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip, deflate',
              'Authorization'=>'Basic 0JDQtNC80LjQvdC40YHRgtGA0LDRgtC+0YA6',
              'Content-Length'=>'2',
              'Content-Type'=>'application/json',
              'Host'=>'192.168.242.150',
              'User-Agent'=> /rest-client/
            }).to_return(status: 200, body: { 'Имя' => 'TEST' }.to_json, headers: {})
          expect(entity2.update(person_id).class).to eq Odata1c::EntityValues
          expect(entity2.update(person_id).values).to eq({"Имя" => "TEST"})
        end
      end
    end

    context 'data is not Hash' do
      it 'raises InvalidAttributeError' do
        expect {entity2.update(person_id, 'BLABLA')}.to raise_error(Odata1c::InvalidArgumentError)
      end
    end
  end


  describe '#perform' do
    let(:url){ 'http://192.168.242.150/DemoHRM1/odata/standard.odata' }
    let(:entity_name_encoded){ 'Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0' }

    let(:perform){ entity.perform 'abc123', 'Operation' }

    before do
      stub_request(:post, "#{url}/#{entity_name_encoded}(abc123)/Operation()?$format=json").
        to_return(status: response_code)
    end

    context 'when response is 200 OK' do
      let(:response_code){ 200 }

      it 'returns true' do
        expect(perform).to eq true
      end
    end

    context 'when response is not 200 OK' do
      let(:response_code){ 400 }

      it 'raises Error' do
        expect { perform }.to raise_error Odata1c::Error
      end
    end
  end
end
