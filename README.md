# RISC-V Encryption

A **simple XOR-based cipher** implemented in **RISC-V assembly**. It encrypts and decrypts a plaintext string using a 4-byte password (repeated as a key stream) and verifies the result by comparing the original plaintext with the decrypted output.

---

## What It Does

- **Encrypt:** Transforms each plaintext byte with a key derived from the password and writes the result to a cipher buffer.
- **Decrypt:** Applies the same key stream to the cipher text and writes the result to a deciphered buffer.
- **Compare:** Checks that the deciphered text matches the original plaintext, then prints all three (plain, cipher, deciphered) via the simulator.

---

## Algorithm

- **Password:** 4 bytes (e.g. `"SU00"`), used cyclically as the key.
- **Key derivation (per byte):** For each password byte, swap the high and low 4 bits, then clear bits 0 and 4 (`& 0xEE`). That value is the key byte for one step.
- **Cipher:** XOR the current plaintext (or ciphertext) byte with the derived key byte and store the result. The same operation is used for both encrypt and decrypt (XOR is symmetric).

So the cipher is a **repeating 4-byte key**, with each key byte transformed by a nibble swap and mask before XOR with the data.

---

## Project Structure

| File | Role |
|------|------|
| **xor_cipher.s** | Single assembly file: `.data` (plaintext, password, buffers, print strings), `.text` (main, ENCRYPT, DECRYPT, COMPARE, and helpers). |

---

## How to Run

The code uses **ecall** for output and exit, so it is intended for a **RISC-V simulator** such as:

- **RARS** (RISC-V Assembler and Runtime Simulator)
- **Venus** (in-browser RISC-V simulator)

1. Open **xor_cipher.s** in the simulator.
2. Assemble and run (e.g. Run → Assemble, then Run).
3. The program encrypts the built-in plaintext, decrypts the cipher, compares plain vs deciphered, then prints "Plain Text:", "Cipher Text:", and "Generated Plain Text:" with the corresponding buffers.

---

## Data

- **Plaintext** (in the source): `"ken_SU is a junior CompE. student at UMASS, Amherst.00000000"`
- **Password:** `"SU00"`
- **Buffers:** 128 bytes each for cipher and deciphered text.

You can change the `.asciiz` strings in the `.data` section to try other inputs; keep the password to 4 bytes if you leave the key logic unchanged.
