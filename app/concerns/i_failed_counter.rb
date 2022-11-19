module IFailedCounter
  def is_locked?(account)
    raise NotImplementedError
  end

  def increment_failed_count(account)
    raise NotImplementedError
  end

  def current_failed_count(account)
    raise NotImplementedError
  end

  def reset(account)
    raise NotImplementedError
  end
end
