---
layout: post
title: Simple ASYNCIO Python 3
category:
  - python
  - python3
  - optimization
---
I have a problem with use of asyncio. Where every call my function must running with event loop. I hate it, because will make my code to long and not efficient. I think if used decorator will make simplify my code and work fast with async. This is my simple decorator which one will wrapping async function and called with event loop.

```python
import asyncio

def static_async(method):
  def wrapper(*args, **kwargs):
    event = asyncio.new_event_loop()
    asyncio.set_event_loop(event)
    event.run_until_complete(method(*args, **kwargs))
    event.close()
  return wrapper

def dynamic_async(method):
  def wrapper(*args, **kwargs):
    event = asyncio.new_event_loop()
    asyncio.set_event_loop(event)
    task = (method(*args, **kwargs),)
    result = event.run_until_complete(asyncio.gather(*task))
    event.close()
    return result[0]
  return wrapper

```

I have two function the first is static_async, static_async function will call function async without return value of function or only called. The second dynamic_async will call function async with return of result of function. For the example usage of them.

```python
import asyncio

def static_async(method):
    def wrapper(*args, **kwargs):
        event = asyncio.new_event_loop()
        asyncio.set_event_loop(event)
        event.run_until_complete(method(*args, **kwargs))
        event.close()
    return wrapper

def dynamic_async(method):
    def wrapper(*args, **kwargs):
        event = asyncio.new_event_loop()
        asyncio.set_event_loop(event)
        task = (method(*args, **kwargs),)
        result = event.run_until_complete(asyncio.gather(*task))
        event.close()
        return result[0]
    return wrapper

@static_async
async def static_fun():
    for i in range(0, 10):
        print('Printed of {}'.format(i))

@dynamic_async
async def dynamic_fun(x):
    result = 0
    for i in range(0, 10):
        result += i * x
    return result

print('--- Running static function ---')
static_fun()
print('--- Running dynamic function ---')
result_dynamic = dynamic_fun(2)
print(result_dynamic)
```

```
--- Running static function ---
Printed of 0
Printed of 1
Printed of 2
Printed of 3
Printed of 4
Printed of 5
Printed of 6
Printed of 7
Printed of 8
Printed of 9
--- Running dynamic function ---
90
```

Now you can use asynchronous function with happy.
