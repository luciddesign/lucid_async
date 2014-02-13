module LucidAsync
  class ActiveRecordPool < Pool

    # The max is set to ActiveRecord's connection pool minus one (representing
    # the main thread connection).
    #
    # Each thread may potentially have its own connection.
    #
    def initialize( options = {} )
      super( options )

      @max ||= ::ActiveRecord::Base.connection_pool.size - 1
    end

    def self.active_record?
      defined?( ::ActiveRecord::Base ) && ::ActiveRecord::Base.connected?
    end

    private

    def _signal_block( &block )
      -> ( *args ) do
        begin
          block.call( *args )

          _available.signal
          threads.delete( Thread.current )
        ensure
          close_connection
        end
      end
    end

    # Need to close thread local ActiveRecord connections to prevent dead
    # connections blocking on the connection pool.
    #
    #     async { SomeAPI.product( 123 ).save }
    #
    def close_connection
      if defined?( ::ActiveRecord::Base ) && ::ActiveRecord::Base.connected?
        ::ActiveRecord::Base.connection.close
      end
    end

  end
end
