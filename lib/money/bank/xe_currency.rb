# frozen_string_literal: true

require 'money'
require 'money/rates_store/rate_removal_support'
require 'net/https'

class Money
  module Bank
    class XeCurrency < Money::Bank::VariableExchange
      # Raised when there is an unexpected error in extracting exchange rates
      # from Xe Finance Calculator
      class XeCurrencyFetchError < Error
      end

      SERVICE_HOST = 'xecdapi.xe.com'
      SERVICE_PATH = '/v1/convert_from.json'

      # @return [Hash] Stores the currently known rates.
      attr_reader :rates

      attr_accessor :account_api_id, :account_api_key

      class << self
        # @return [Integer] Returns the Time To Live (TTL) in seconds.
        attr_reader :ttl_in_seconds

        # @return [Time] Returns the time when the rates expire.
        attr_reader :rates_expiration

        ##
        # Set the Time To Live (TTL) in seconds.
        #
        # @param [Integer] the seconds between an expiration and another.
        def ttl_in_seconds=(value)
          @ttl_in_seconds = value
          refresh_rates_expiration! if ttl_in_seconds
        end

        ##
        # Set the rates expiration TTL seconds from the current time.
        #
        # @return [Time] The next expiration.
        def refresh_rates_expiration!
          @rates_expiration = Time.now + ttl_in_seconds
        end
      end

      def initialize(rate_store, account_api_id:, account_api_key:)
        super(rate_store)
        @store.extend Money::RatesStore::RateRemovalSupport
        @account_api_id = account_api_id
        @account_api_key = account_api_key
      end

      ##
      # Clears all rates stored in @rates
      #
      # @return [Hash] The empty @rates Hash.
      #
      # @example
      #   @bank = XeCurrency.new  #=> <Money::Bank::XeCurrency...>
      #   @bank.get_rate(:USD, :EUR)  #=> 0.776337241
      #   @bank.flush_rates           #=> {}
      def flush_rates
        store.clear_rates
      end

      ##
      # Clears the specified rate stored in @rates.
      #
      # @param [String, Symbol, Currency] from Currency to convert from (used
      #   for key into @rates).
      # @param [String, Symbol, Currency] to Currency to convert to (used for
      #   key into @rates).
      #
      # @return [Float] The flushed rate.
      #
      # @example
      #   @bank = XeCurrency.new    #=> <Money::Bank::XeCurrency...>
      #   @bank.get_rate(:USD, :EUR)    #=> 0.776337241
      #   @bank.flush_rate(:USD, :EUR)  #=> 0.776337241
      def flush_rate(from, to)
        store.remove_rate(from, to)
      end

      ##
      # Returns the requested rate.
      #
      # It also flushes all the rates when and if they are expired.
      #
      # @param [Currency] from Currency to convert from
      # @param [Currency] to Currency to convert to
      #
      # @return [Float] The requested rate.
      #
      # @example
      #   @bank = XeCurrency.new  #=> <Money::Bank::XeCurrency...>
      #   @bank.get_rate(:USD, :EUR)  #=> 0.776337241
      def get_rate(from, to)
        expire_rates

        from_iso_code = from.iso_code
        to_iso_code = to.iso_code

        store.get_rate(from_iso_code, to_iso_code) || store.add_rate(from_iso_code, to_iso_code, fetch_rate(from, to))
      end

      ##
      # Flushes all the rates if they are expired.
      #
      # @return [Boolean]
      def expire_rates
        if self.class.ttl_in_seconds && self.class.rates_expiration <= Time.now
          flush_rates
          self.class.refresh_rates_expiration!
          true
        else
          false
        end
      end

      private

      ##
      # Queries for the requested rate and returns it.
      #
      # @param [Currency] from Currency to convert from
      # @param [Currency] to Currency to convert to
      #
      # @return [BigDecimal] The requested rate.
      def fetch_rate(from, to)
        uri = build_uri(from, to)
        res = get(uri)
        data = raise_or_return(res)
        extract_rate(data)
      end

      ##
      # Build a URI for the given arguments.
      #
      # @param [Currency] from The currency to convert from.
      # @param [Currency] to The currency to convert to.
      #
      # @return [URI::HTTPS]
      def build_uri(from, to)
        URI::HTTPS.build(
          host: SERVICE_HOST,
          path: SERVICE_PATH,
          query: [
            "from=#{from.iso_code}",
            "to=#{to.iso_code}"
          ].join('&')
        )
      end

      # Send a HTTPS Get request
      #
      # @param [URI::HTTPS]
      # @return [Net::HTTPResponse]
      def get(uri)
        req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")
        req.basic_auth(account_api_id, account_api_key)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.request(req)
      end

      ##
      # Takes the response from Xe and extract the rate.
      #
      # @param [String] data The xe rate string to decode.
      #
      # @return [BigDecimal]
      def extract_rate(data)
        rate = JSON.parse(data)['to'][0]['mid']
        BigDecimal(rate.to_s)
      rescue StandardError
        raise XeCurrencyFetchError, 'Error parsing rates or adding rates to store'
      end

      def raise_or_return(response)
        return response.body if response.code == '200'

        rsp_body = JSON.parse(response.body)
        rsp_message = rsp_body.fetch('message')

        raise XeCurrencyFetchError, rsp_message
      end
    end
  end
end
