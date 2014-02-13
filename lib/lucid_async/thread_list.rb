module LucidAsync
  class ThreadList

    include Enumerable

    attr_reader :threads, :max

    def initialize( options = {} )
      @mutex      = Mutex.new
      @loop_mutex = Mutex.new
      @threads    = []

      @max = options[:max] || nil
    end

    def full?
      _sync { max ? threads.length >= max : false }
    end

    def new( *args, &block )
      _sync_unless_full do
        Thread.new( *args, &block ).tap do |thread|
          threads << thread
        end
      end
    end

    def push( thread )
      _sync_unless_full do
        _type_check( thread )
        threads << thread
      end
    end

    def delete( thread )
      _sync do
        _type_check( thread )
        threads.delete( thread )
      end
    end

    def each( &block )
      _loop_sync { threads.each( &block ) }
    end

    private

    def _type_check( object )
      unless object.kind_of?( Thread )
        raise TypeError, 'expects Thread or subclass'
      end
    end

    def _sync_unless_full( &block )
      if full?
        raise RuntimeError, "thread limit reached (#{max})"
      end

      _sync( &block )
    end

    def _loop_sync( &block )
      @loop_mutex.synchronize( &block )
    end

    def _sync( &block )
      @mutex.synchronize( &block )
    end

  end
end
