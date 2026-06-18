---
layout: post
title: ASYNCIO Sederhana Python 3
lang: id
lang-ref: asyncio-python3
category:
  - python
  - python3
  - optimization
---
Saya punya masalah dengan penggunaan asyncio. Di mana setiap pemanggilan fungsi harus berjalan dengan event loop. Saya tidak menyukainya, karena akan membuat kode saya panjang dan tidak efisien. Saya pikir jika menggunakan dekorator akan menyederhanakan kode saya dan bekerja cepat dengan async. Ini adalah dekorator sederhana saya yang akan membungkus fungsi async dan dipanggil dengan event loop.

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

Saya punya dua fungsi, yang pertama adalah static_async, fungsi static_async akan memanggil fungsi async tanpa mengembalikan nilai atau hanya dipanggil saja. Yang kedua dynamic_async akan memanggil fungsi async dengan mengembalikan hasil dari fungsi tersebut. Contoh penggunaannya:

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

Sekarang kamu bisa menggunakan fungsi asynchronous dengan senang.
