module LucidAsync
  module Mixin

    def self.included( base )
      base.extend( self )
    end

    # Maybe this should take a callback argument at some stage?
    #
    def async( *args, &block )
      LucidAsync.pool.process( *args, &block )
    end

    def async_each( collection, &block )
      LucidAsync.pool.process_each( collection, &block )
    end

    def async_map( collection, &block )
      lock, results = Mutex.new, Array.new

      async_each( collection ) do |element, i|
        result = block.call( element, i )

        lock.synchronize do
          results[i] = result
        end
      end

      results
    end

    private

    # For convenience, allows calling any method asynchronously with the
    # +_async+ suffix. Be very careful to ensure that any method called in
    # this manner is thread safe!
    #
    #     def wait_a_long_time
    #       sleep 60
    #     end
    #
    #     wait_a_long_time_async
    #
    def method_missing( sym, *args, &block )
      if method = _missing_check( sym )
        async { send( method, *args, &block ) }
      else
        super
      end
    end

    def respond_to_missing?( sym, include_private = false )
      !( _missing_check( sym ).nil? ) || super
    end

    def _missing_check( sym )
      method = _missing_method( sym )

      if sym =~ /_async$/ && respond_to?( method )
        method
      end
    end

    def _missing_method( sym )
      sym.to_s.split( '_async' ).first
    end

  end
end
