require 'spec_helper'

RSpec.describe Odata1c::Error do
  let(:response) { instance_double('RestClient::Response', code: 400) }

  context 'with custom error message' do
    subject { Odata1c::ClientError.new(response, 'The server made a boo-boo.') }

    describe '#message' do
      it 'returns custom response message' do
        expect(subject.message).to eq('The server made a boo-boo.')
      end
    end
  end

  context 'without custom error message' do
    subject { Odata1c::ClientError.new(response) }

    describe '#message' do
      it 'returns the default message' do
        expect(subject.message).to eq "Odata1c::ClientError"
      end
    end
  end
end

RSpec.describe Odata1c do
  let(:exception) { instance_double('RestClient::Unauthorized', http_code: 401, response: "Boo", default_message: 'Bad..So') }

  describe '.process_response' do
    it 'returns new ClientError instance' do
      expect(Odata1c.process_response(exception)).to eq Odata1c::ClientError.new(exception.response, exception.default_message)
    end
  end

end
