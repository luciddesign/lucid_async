module LucidAsync
  class ActiveRecordTask < Task

    private

    def _cleanup
      _close_connection

      super
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
