module LucidAsync
  class Pool

    attr_reader :threads, :max

    def initialize( options = {} )
      @threads      = ThreadList.new( options )
      @_thread_lock = Mutex.new

      @max = threads.max
    end

    def process( *args, &block )
      raise ArgumentError, 'no block given' unless block_given?

      _sync do
        if threads.full?
          _available.wait( _thread_lock )
        end

        threads.new *args, &_signal_block( &block )
      end
    end

    # Execute a given block for each element in a collection asynchronously.
    # Blocks until all threads have finished and returns +false+ if any
    # thread returns a falsey value.
    #
    def process_each( collection, &block )
      collection_threads = collection.each_with_index.map do |*args|
         process *args, &block
      end

      _wait_for( collection_threads )
    end

    private

    attr_reader :_thread_lock

    # Returns +false+ if any thread in +threads+ returns a falsey value.
    #
    def _wait_for( collection_threads )
      collection_threads.inject( true ) { |bool, t| bool && t.value }
    end

    def _signal_block( &block )
      ->( *args ) do
        begin
          block.call( *args )
        ensure
          _available.signal
          threads.delete( Thread.current )
        end
      end
    end

    def _available
      @available ||= ConditionVariable.new
    end

    def _sync( &block )
      _thread_lock.synchronize( &block )
    end

  end
end
