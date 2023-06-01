require 'spec_helper.rb'

RSpec.describe Odata1c::Property do
  subject(:property) {described_class.new type: type, name: name, nullable: nullable}
  let(:type) {'Edm.DateTime'}
  let(:name) {'Period'}
  let(:nullable) {false}

  example '#type returns type passed on initialization' do
    expect(property.type).to eql type
  end

  example '#name returns name passed on initialization' do
    expect(property.name).to eql name
    expect(property.name).not_to be_a_kind_of described_class
  end

  example '#nullable returns value passed on initialization' do
    expect(property.nullable).to eql nullable
  end

  describe '#nullable?' do
    subject(:nullable?) {property.nullable?}

    let(:nullable) {true}

    it 'returns #nullable value' do
      expect(nullable?).to be true
    end
  end

  describe '#==' do
    subject(:compare) {property == another_property}

    context 'with similar object' do
      let(:another_property) do
        # Наследование сделано специально
        Class.new(described_class).new type: type, name: name, nullable: nullable
      end

      it 'returns true' do
        expect(compare).to be true
      end
    end

    context 'when object has different attribute value' do
      let(:another_property) {described_class.new type: 'Edm.String', name: name, nullable: nullable}

      it 'returns false' do
        expect(compare).to be false
      end
    end

    context 'when object is not inherited from Property' do
      let(:another_property) {"not a property"}

      it 'returns false' do
        expect(compare).to be false
      end
    end
  end

  describe '#eql?' do
    subject(:compare) {property.eql? another_property}

    context 'with similar object' do
      let(:another_property) {described_class.new type: type, name: name, nullable: nullable}

      it 'returns true' do
        expect(compare).to be true
      end
    end

    context 'when object has different attribute value' do
      let(:another_property) {described_class.new type: 'Edm.String', name: name, nullable: nullable}

      it 'returns false' do
        expect(compare).to be false
      end
    end

    context 'when object class is not a Property' do
      let(:another_property) do
        # Наследование сделано специально
        Class.new(described_class).new type: type, name: name, nullable: nullable
      end

      it 'returns false' do
        expect(compare).to be false
      end
    end
  end
end