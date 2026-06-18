---
layout: post
title: Flipping Bits
lang: en
lang-ref: flipping-bits
category:
  - python
  - python3
  - programming
---
Bit flipping is an algorithmic manipulation of binary digits (bits). It performs logical negation on a single bit, or on each of several bits, switching state 0 to 1 and vice versa. Bit flipping is one of the popular bit manipulation algorithms, alongside AND, OR, XOR, NOT, and bit shifts. It’s usually used in cryptography algorithms to obfuscate messages.

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

In the **flipping_bit** function above, you can change the bit length to suit your needs.

Yeah, that's flipping bit for playing with bit manipulation. Enjoy the read and thanks for coming in, goodnight.
