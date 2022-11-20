class FailedCounterAdapter
  include FailedCounterMethods

  attr_reader :client

  def initialize
    @client = RestClient::Resource.new('https://failed-counter.jimytc.com',
                                       headers: {
                                         'Content-Type' => 'application/json',
                                         'Accept' => 'application/json'
                                       })
  end

  def is_locked?(account)
    is_locked_response = client[:api][:is_locked].post(account: account)
    JSON.parse(is_locked_response.body, object_class: OpenStruct).locked
  end

  def increment_failed_count(account)
    client[:api][:increment].post(account: account)
  end

  def current_failed_count(account)
    failed_count_response = client[:api][:failed_count].post(account: account)
    JSON.parse(failed_count_response.body, object_class: OpenStruct).count
  end

  def reset(account)
    client[:api][:failed_counter][:reset].post(account: account)
  end
end
