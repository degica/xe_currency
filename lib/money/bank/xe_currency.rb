require 'money'
require 'money/rates_store/rate_removal_support'
require 'open-uri'

class Money
  module Bank
    class XeCurrency < Money::Bank::VariableExchange
    end
  end
end
