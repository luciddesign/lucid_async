require 'lucid_async/task'
require 'lucid_async/thread_list'
require 'lucid_async/pool'

require 'lucid_async/active_record/task'
require 'lucid_async/active_record/pool'

require 'lucid_async/mixin'
require 'lucid_async/task_delegator'
require 'lucid_async/init'

module LucidAsync

  extend Init

  def self.new_task( &block )
    task_class.new( &block )
  end

end
