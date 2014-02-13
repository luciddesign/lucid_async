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

    private

    attr_reader :_thread_lock

    def _signal_block( &block )
      ->( *args ) do
        block.call( *args )

        _available.signal
        threads.delete( Thread.current )
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
