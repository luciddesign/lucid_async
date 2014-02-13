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

    # Iterate over a collection asynchronously. Blocks until all threads have
    # finished executing and returns false if any threads returned a falsey
    # value.
    #
    def async_each( collection, &block )
      threads = collection.each_with_index.map do|*args|
        async { block.call( *args ) }
      end

      wait_for( threads )
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

    def wait_for( threads )
      threads.inject( true ) { |bool, t| bool && t.value }
    end

    private

    # For convenience, allow calling any method asynchronously with the
    # +_async+ suffix.
    #
    #     def wait_a_long_time
    #       sleep 60
    #     end
    #
    #     wait_a_long_time_async
    #
    def method_missing( sym, *args, &block )
      if method = method_missing_check( sym )
        async { send( method, *args, &block ) }
      else
        super
      end
    end

    def respond_to_missing?( sym, include_private = false )
      !( method_missing_check( sym ).nil? ) || super
    end

    def method_missing_method( sym )
      sym.to_s.split( '_async' ).first
    end

    def method_missing_check( sym )
      method = method_missing_method( sym )
      method if sym =~ /_async$/ && respond_to?( method )
    end

  end
end
