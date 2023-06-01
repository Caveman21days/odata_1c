require 'spec_helper'

RSpec.describe Odata1c::Connection do
  let(:entity_name) { "Catalog_ФизическиеЛица" }
  let(:service) { Odata1c::Connection.new(host: '192.168.242.150', db_name: 'DemoHRM1', user: 'Администратор') }

  before do
    stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata/$metadata").
        to_return(status: 200,
                  body: "<Schema><EntityType Name='Catalog_ФизическиеЛица'><Property Name='Имя' Type='Edm.String' Nullable='false'/><Property Name='Фамилия' Type='Edm.String' Nullable='true'/><Property Name='Возраст' Type='Edm.Int64' Nullable='false'/></EntityType><EntityType Name='Catalog_ВыдуманныеЛица'><Property Name='Имя' Type='Edm.String' Nullable='false'/><Property Name='Фамилия' Type='Edm.String' Nullable='true'/></EntityType></Schema>", headers: {})
  end

  describe '#[]' do
    context 'with valid metadata' do
      it 'returns Entity object' do
        expect(service[entity_name].class).to eq Odata1c::Entity
        expect(service[entity_name].service).to eq service
      end
    end
    context 'with invalid metadata' do
      it 'returns exception' do
        expect { service['Catalog_Физические'] }.to raise_error Odata1c::UnknownEntityError
      end
    end
  end

  describe '#metadata' do
    subject(:metadata){ service.metadata }

    it "returns metadata" do
      expect(metadata).to be_a_kind_of described_class::Metadata
    end

    it 'has key for each data collection' do
      expect(service.metadata.keys).to match_array %w(Catalog_ФизическиеЛица Catalog_ВыдуманныеЛица)
    end

    it 'has correct properties for each collection' do
      expected_properties = [
          Odata1c::Property.new(name: 'Имя', type: 'Edm.String', nullable: false),
          Odata1c::Property.new(name: 'Фамилия', type: 'Edm.String', nullable: true),
          Odata1c::Property.new(name: 'Возраст', type: 'Edm.Int64', nullable: false)
      ]

      expect(service.metadata['Catalog_ФизическиеЛица'].to_a).to match_array expected_properties
    end
  end

  describe '#execute_request' do
    it 'executes any url request' do
      stub_request(:get, "http://192.168.242.150/DemoHRM1/odata/standard.odata").with(basic_auth: [service.user, service.password])
      expect(service.execute_request(service.url)).to be_truthy
    end
  end
end