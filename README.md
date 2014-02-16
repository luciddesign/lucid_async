lucid_async
============

Convenient and safe asynchronous programming (especially with ActiveRecord).


Notes on usage
--------------

Asynchronous programming is complex and despite any conveniences provided by
this library, still requires careful manual control.

When using ActiveRecord, `lucid_async` takes the precaution of closing thread
local connections automatically at the end of each asynchronous block
(assuming you're using the mixin or `ActiveRecordTask`).

However, this will not always be sufficient, and if you have any long running
blocks containing database calls you may still run into timeouts on the
connection pool.

One way to remedy this is to use a thread pool. This will limit the number of
active threads to a certain number. Under ActiveRecord and using the default
global thread pool, this is set to ActiveRecord's connection pool minus one
(where the one represents the main thread).

However, this method has its own downsides. A fairly major one is that nesting
blocks with `#async_each` or `#async_map` can cause the program to block
indefinitely.

In most cases, the safest and most efficient way is simply to wrap any
database calls inside asynchronous blocks with ActiveRecord's
`#with_connection`.
