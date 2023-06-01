module Odata1c
  class Error < StandardError; end

  class RequestError < Error
    attr_reader :response

    def initialize(response, message = nil)
      super(message)
      @response = response
      @message  = message
    end
  end

  class ClientError < RequestError; end
  class ServerError < RequestError; end
  class UnknownEntityError < Error; end
  class UnknownAttributeError < Error; end
  class InvalidArgumentError < Error; end

  def self.process_response(e)
    if e.http_code
      case e.http_code.to_i
      when 400..500
        Odata1c::ClientError.new(e.response, e.default_message)
      when 500..600
        Odata1c::ServerError.new(e.response, e.default_message)
      end
    else
      Odata1c::RequestError.new(e.response, e.default_message)
    end
  end
end
