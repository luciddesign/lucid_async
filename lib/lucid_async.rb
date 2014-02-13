require 'lucid_async/thread_list'
require 'lucid_async/pool'
require 'lucid_async/active_record_pool'
require 'lucid_async/mixin'

module LucidAsync

  def self.pool
    @pool ||= _instantiate_pool
  end

  class << self
    private

    def _instantiate_pool
      if ActiveRecordPool.active_record?
        ActiveRecordPool.new
      else
        Pool.new
      end
    end
  end

end
