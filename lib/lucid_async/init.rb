module LucidAsync
  module Init

    def active_record?
      defined?( ::ActiveRecord::Base ) && ::ActiveRecord::Base.connected?
    end

    def pool
      @pool ||= active_record? ? ActiveRecordPool.new : Pool.new
    end

    def task_class
      active_record? ? ActiveRecordTask : Task
    end

    # Obviously only use this with ActiveRecord ...
    #
    def with_connection( &block )
      ActiveRecord::Base.connection_pool.with_connection( &block )
    end

  end
end
