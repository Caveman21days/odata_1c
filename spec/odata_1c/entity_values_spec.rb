require 'spec_helper.rb'

RSpec.describe Odata1c::EntityValues do
  subject(:object) {described_class.new entity, values}
  let(:entity) {double Odata1c::Entity, properties: entity_properties}
  let(:entity_properties) {Odata1c::Properties.new name_property, datetime_property, uuid_property, skipped_property}
  let(:name_property) {Odata1c::Property.new type: 'Edm.String', name: 'Имя', nullable: false}
  let(:datetime_property) {Odata1c::Property.new type: 'Edm.DateTime', name: 'ДатаСоздания', nullable: true}
  let(:uuid_property) {Odata1c::Property.new type: 'Edm.Guid', name: 'Ключ_Key', nullable: true}
  let(:skipped_property) {Odata1c::Property.new type: 'Edm.String', name: 'ПропущенноеЗначение', nullable: true}

  let(:values) do
    {
        'Имя' => name,
        'ДатаСоздания' => datetime_raw,
        'Ключ_Key' => uuid_raw
    }
  end
  let(:uuid_raw){ 'a878edaa-9484-11e8-a45d-e269cdf4837d' }

  let(:name) {'Пётр'}
  let(:datetime_raw) {'2000-12-12T12:00'}

  describe '#[]' do
    subject(:value) {object['Имя']}
    it 'returns value by property name' do
      expect(value).to eql name
    end

    context 'with Edm.DateTime property' do
      subject(:value) {object['ДатаСоздания']}

      it 'returns correct Time value (in current timezone)' do
        expect(value).to eql Time.new(2000, 12, 12, 12)
      end

      context 'with nil value' do
        let(:datetime_raw) {nil}

        it 'returns nil' do
          expect(value).to be_nil
        end
      end

      context 'when value equals "0001-01-01T00:00:00"' do
        let(:datetime_raw) {'0001-01-01T00:00:00'}

        it 'returns nil' do
          expect(value).to be_nil
        end
      end
    end

    context 'with Edm.Guid property' do
      subject(:value){ object['Ключ_Key'] }

      context 'when value equals "00000000-0000-0000-0000-000000000000"' do
        let(:uuid_raw){ '00000000-0000-0000-0000-000000000000' }

        it 'returns nil' do
          expect(value).to be_nil
        end
      end
    end

    context 'with unknown property name' do
      it 'raises UnknownAttributeError' do
        expect{ object['НичегоНеЗнаю'] }.to raise_error Odata1c::UnknownAttributeError
      end
    end
  end

  describe '#to_h' do
    subject(:hash){ object.to_h }

    it 'returns Hash' do
      expect(hash).to be_a_kind_of Hash
    end

    it 'has type casted values for all known properties' do
      expect(hash).to eql 'ПропущенноеЗначение' => nil,
                          'Ключ_Key' => uuid_raw,
                          'Имя' => name,
                          'ДатаСоздания' => Time.new(2000, 12, 12, 12)
    end
  end
end