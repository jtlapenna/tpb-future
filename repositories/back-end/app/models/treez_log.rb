class TreezLog
  def self.debug_webhooks(message=nil)
    @my_log ||= Logger.new("#{Rails.root}/log/webhooks_treez_log.log")
    @my_log.debug(message) unless message.nil?
  end
  def self.debug_storesync(message=nil)
    @my_log ||= Logger.new("#{Rails.root}/log/storesync_treez_log.log")
    @my_log.debug(message) unless message.nil?
  end
end