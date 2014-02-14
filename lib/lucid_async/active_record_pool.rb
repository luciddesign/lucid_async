module LucidAsync
  class ActiveRecordPool < Pool

    # The max is set to ActiveRecord's connection pool minus one (representing
    # the main thread connection).
    #
    # Each thread may potentially have its own connection.
    #
    def initialize( options = {} )
      options[:max] ||= _active_record_pool.size - 1

      super( options )
    end

    def self.active_record?
      defined?( ::ActiveRecord::Base ) && ::ActiveRecord::Base.connected?
    end

    private

    def _signal_block( &block )
      -> ( *args ) do
        begin
          block.call( *args )
        ensure
          _available.signal
          threads.delete( Thread.current )

          _close_connection
        end
      end
    end

    def _active_record_pool
      ::ActiveRecord::Base.connection_pool
    end

    # Need to close thread local ActiveRecord connections to prevent dead
    # connections blocking on the connection pool.
    #
    #     async { SomeAPI.product( 123 ).save }
    #
    def _close_connection
      if self.class.active_record?
        ::ActiveRecord::Base.connection.close
      end
    end

  end
end
