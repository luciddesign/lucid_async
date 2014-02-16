module LucidAsync
  class TaskDelegator

    attr_reader :task, :pool

    def initialize( options = {}, &block )
      @task = LucidAsync.new_task( &block )
      @pool = _fetch_pool( options )
    end

    def call( method, *args )
      if pool
        pool.send( method, *args, task )
      else
        task.send( method, *args )
      end
    end

    private

    def _fetch_pool( options )
      if pool = options[:pool]
         pool == true ? LucidAsync.pool : pool
      end
    end

  end
end
