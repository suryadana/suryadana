---
layout: post
title: Membalikkan Bit
lang: id
lang-ref: flipping-bits
category:
  - python
  - python3
  - programming
---
Bit flipping adalah manipulasi algoritmik dari digit biner (bit). Ini melakukan negasi logika pada satu bit, atau beberapa bit, mengubah status 0 menjadi 1, dan sebaliknya. Bit flipping adalah salah satu algoritma manipulasi bit yang populer selain manipulasi bit lainnya seperti AND, OR, XOR, NOT, dan bit shifts. Ini biasanya digunakan pada algoritma kriptografi untuk mengaburkan pesan.

```python
def flipping_bit(n, base=8):
    bits = '{0:{fill}{base}b}'.format(n, fill='0', base=8)
    return int(''.join('1' if x == '0' else '0' for x in bits), 2)

def main():
    message = "This is secret message!!!"

    # Flipping the message
    flipping_bit_message = "".join(chr(flipping_bit(ord(x))) for x in message)
    print(flipping_bit_message)

    message = "".join(chr(flipping_bit(ord(x))) for x in flipping_bit_message)
    print(message)

if __name__ == '__main__':
    main()
```

Pada fungsi **flipping_bit** di atas, kamu bisa mengubah panjang bit sesuai kebutuhan.

Ya, itu adalah flipping bit untuk bermain dengan manipulasi bit. Selamat membaca dan terima kasih sudah mampir, selamat malam.
