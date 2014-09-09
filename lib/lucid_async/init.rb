module LucidAsync
  module Init

    def active_record?
      defined?( ::ActiveRecord::Base ) && ::ActiveRecord::Base.connected?
    end

    def pool
      return @pool if @pool

      @pool = if active_record?
        ActiveRecordPool.new( _pool_options )
      else
        Pool.new( _pool_options )
      end
    end

    def task_class
      active_record? ? ActiveRecordTask : Task
    end

    # Obviously only use this with ActiveRecord ...
    #
    def with_connection( &block )
      ActiveRecord::Base.connection_pool.with_connection( &block )
    end

    private

    def _pool_options
      if m = ENV['LA_POOL']
        return { :max => m.to_i }
      end

      Hash.new
    end

  end
end
