module LucidAsync
  class Task

    attr_reader :block, :status, :exception

    def initialize( &block )
      @block        = _wrap_block( block )
      @status       = :new
      @thread       = nil
    end

    def process( *args, &callback )
      @thread = Thread.new { block.call( *args, &callback ) }
    end

    # Create a duplicate of this task for each element in a collection and
    # process each easynchronously. Blocks until all threads have completed
    # and returns +false+ if any thread returns a falsey value.
    #
    def each_of( collection, *args, &callback )
      threads = collection.each_with_index.map do |*loop_args|
        self.dup.process *( loop_args + args ), &callback
      end

      _wait_for( threads )
    end

    def wait
      @thread.value if @thread
    end

    def active?
      status == :active
    end

    def complete?
      status == :complete
    end

    def success?
      status == :complete && exception.nil?
    end

    private

    def _wrap_block( block )
      -> ( *args, &callback ) do
        begin
          @exception = nil
          @status    = :active

          block.call( *args ).tap do |result|
            callback.call( result ) if callback
          end

        rescue => exception
          @exception = exception

        ensure
          _cleanup
          @status = :complete

        end
      end
    end

    # Returns +false+ if any thread in +threads+ returns a falsey value.
    #
    def _wait_for( threads )
      threads.inject( true ) { |bool, t| bool && t.value }
    end

    def _cleanup
    end

  end
end
