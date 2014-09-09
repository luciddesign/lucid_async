module LucidAsync
  module Mixin

    def self.included( base )
      base.extend( self )
    end

    def async( options = {}, &block )
      TaskDelegator.new( options, &block ).call( :process )
    end

    def async_each( collection, options = {}, &block )
      TaskDelegator.new( options, &block ).call( :each_of, collection )
    end

    def async_map( collection, options = {}, &block )
      lock, results = Mutex.new, Array.new

      async_each( collection, options ) do |element, i|
        result = block.call( element, i )

        lock.synchronize do
          results[i] = result
        end
      end

      results
    end

    def with_connection( &block )
      LucidAsync.with_connecton( &block )
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
        async { __send__( method, *args, &block ) }
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
