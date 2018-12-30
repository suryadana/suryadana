---
layout: post
title: Flipping Bits
category:
  - python
  - python3
  - programming
---
Bit flipping is an algorithmic manipulation of binary digits (bits). It’s performing logical negation to a single bit, or each of several bits, switching state 0 to 1, and vice versa. Bit flipping one of bit manipulation algorithm which popular except other bit manipulation like AND, OR, XOR, NOT, and bit shifts. It’s usually used on a cryptography algorithm to make obfuscate of the message.

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

On the above function **flipping_bit**, you can change the base of bits length to your case.

Yeah, that is flipping bit for play with bits manipulation. Enjoy for reading and thanks for come in, goodnight.
