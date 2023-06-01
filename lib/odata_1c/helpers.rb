module Odata1c
  # @api private
  class Helpers

    def self.connection_url(host, port, db_name, verify_ssl)
      "#{verify_ssl ? "https" : "http"}://#{host}:#{port}/#{db_name}/odata/standard.odata"
    end

    def self.concat_urls(url, suburl)
      url = url.to_s
      suburl = suburl.to_s
      if (url.slice(-1, 1) == '/') && (suburl.slice(0, 1) == '/')
        url + suburl[1..-1]
      elsif (url.slice(-1, 1) == '/') || (suburl.slice(0, 1) == '/')
        url + suburl
      else
        "#{url}/#{suburl}"
      end
    end

    def self.convert_to_nil(response)
      if response.kind_of? Array
        return response.each {|hash| convert_to_nil hash}
      elsif response.kind_of? Hash
        response.each do |k, v|
          response[k] = nil if v == '' || v == "0001-01-01T00:00:00" || v == "00000000-0000-0000-0000-000000000000"
        end
      end
    end

  end
end