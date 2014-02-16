module LucidAsync
  class Pool

    attr_reader :threads, :max

    def initialize( options = {} )
      @threads      = ThreadList.new( options )
      @_thread_lock = Mutex.new

      @max = threads.max
    end

    def process( task = nil, &block )
      block = _block_arg( task, block )

      _sync do
        if threads.full?
          _available.wait( _thread_lock )
        end

        threads.new &_signal_block( &block )
      end
    end

    # Execute a given block for each element in a collection asynchronously.
    # Blocks until all threads have completed and returns +false+ if any
    # thread returns a falsey value.
    #
    def each_of( collection, task = nil, &block )
      block = _block_arg( task, block )

      collection_threads = collection.each_with_index.map do |*args|
        process *args, &block
      end

      _wait_for( collection_threads )
    end

    private

    attr_reader :_thread_lock

    def _block_arg( task, block )
      task ? task.block : Task.new( &block ).block
    end

    # Returns +false+ if any thread in +collection_threads+ returns a falsey
    # value.
    #
    def _wait_for( collection_threads )
      collection_threads.inject( true ) { |bool, t| bool && t.value }
    end

    def _signal_block( &block )
      ->( *args ) do
        begin
          block.call( *args )
        ensure
          _cleanup
        end
      end
    end

    def _cleanup
      _available.signal
      threads.delete( Thread.current )
    end

    def _available
      @available ||= ConditionVariable.new
    end

    def _sync( &block )
      _thread_lock.synchronize( &block )
    end

  end
end
