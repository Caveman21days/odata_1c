require 'spec_helper.rb'

RSpec.describe Odata1c::Properties do
  subject(:properties) {described_class.new property_first, property_second}

  let(:property_first) {Odata1c::Property.new type: property_first_type, name: property_first_name, nullable: property_first_nullable}
  let(:property_second) {Odata1c::Property.new type: 'Edm.DateTime', name: property_second_name, nullable: 'False'}

  let(:property_first_name) {'Город'}
  let(:property_first_type) {'Edm.String'}
  let(:property_first_nullable) {'True'}
  let(:property_second_name) {'ДатаСоздания'}

  describe '#include?' do
    subject(:include?) {properties.include? test_property}

    context 'with String (property name)' do
      context 'with known property name' do
        let(:test_property) {property_first_name}

        it 'returns true' do
          expect(include?).to be true
        end
      end

      context 'with unknown property name' do
        let(:test_property) {'unknown'}

        it 'returns false' do
          expect(include?).to be false
        end
      end
    end

    context 'with Property' do
      context 'with similar property' do
        let(:test_property) do
          # Наследование делается специально
          Class.new(Odata1c::Property).new type: property_first_type, name: property_first_name, nullable: property_first_nullable
        end

        it 'returns true' do
          expect(include?).to be true
        end
      end

      context 'with different property' do
        let(:test_property) do
          Odata1c::Property.new type: property_first_type, name: 'unkbiwb', nullable: property_first_nullable
        end

        it 'returns false' do
          expect(include?).to be false
        end
      end
    end

    context 'with other objects' do
      let(:test_property) {123}

      it 'returns false' do
        expect(include?).to be false
      end
    end
  end

  describe '#[]' do
    subject(:get) {properties[property_name]}

    context 'with known property name' do
      let(:property_name) {property_first_name}

      it 'returns correct property' do
        expect(get).to be property_first
      end
    end

    context 'with unknown property name' do
      let(:property_name) {'unknown'}

      it 'returns nil' do
        expect(get).to be_nil
      end
    end
  end

  describe '#to_a' do
    subject(:to_a) {properties.to_a}

    it 'returns Array' do
      expect(to_a).to be_a_kind_of Array
    end

    it 'contains all properties' do
      expect(to_a).to contain_exactly property_first, property_second
    end
  end

  describe '#to_h' do
    subject(:to_h) {properties.to_h}

    it 'returns Hash' do
      expect(to_h).to be_a_kind_of Hash
    end

    it 'contains all properties with names in keys' do
      expect(to_h).to eql property_first_name => property_first,
                          property_second_name => property_second
    end
  end
end