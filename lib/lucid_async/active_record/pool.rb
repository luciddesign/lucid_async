module LucidAsync
  class ActiveRecordPool < Pool

    # The max is set to ActiveRecord's connection pool minus one (representing
    # the main thread connection).
    #
    def initialize( options = {} )
      options[:max] ||= _active_record_pool.size - 1

      super( options )
    end

    private

    def _block_arg( task, block )
      task ? task.block : ActiveRecordTask.new( &block ).block
    end

    def _active_record_pool
      ::ActiveRecord::Base.connection_pool
    end

  end
end
