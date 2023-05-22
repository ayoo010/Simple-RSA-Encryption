import math
import time
import random

random.seed(time.time())

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n))+1):
        if n % i == 0:
            return False
    return True

def generate_primes(bit_length):
    p, q = 0, 0
    while True:
        p = random.randint(2**(bit_length//2), 2**(bit_length//2+1))
        if is_prime(p):
            break
    while True:
        q = random.randint(2**(bit_length//2), 2**(bit_length//2+1))
        if is_prime(q):
            break
    return p, q

def euler_func(p, q):
    return (p-1) * (q-1)

def generate_private_key(e, phi):
    k = 1
    while True:
        d = (k * phi + 1) / e
        if d == int(d):
            if d < 0:
                d = d * -1
            return d
        k = k + 1

def generate_rsa_keys(bit_length):
    p, q = generate_primes(bit_length)
    n = p * q
    phi = euler_func(p, q)
    print("p = " + str(p) + " q = " + str(q) + " phi(n) = " + str(phi))
    e = 65537
    d = generate_private_key(e, phi)
    if e < 0:
        e = e * -1
    if n < 0:
        n = n * -1
    return {'n': n, 'e': e, 'd': d}
    
def plaintext(text):
    ascii = [ord(char) for char in text]
    return ascii

keys = generate_rsa_keys(30) # Генерируем RSA ключи
e, n, d = keys['e'], keys['n'], keys['d']
print("e = ", e, " n = ", n, " d = ", d)

# Функция для возведения в степень по модулю
def modexp(base, exponent, modulus):
    if modulus == 1:
        return 0
    result = 1
    base = base % modulus
    while exponent > 0:
        if exponent % 2 == 1:
            result = (result * base) % modulus
        exponent = exponent // 2
        base = (base * base) % modulus
    return result

# Функция шифрования
length = []
def rsa_encrypt(M):
    M = plaintext(M)
    c = ''
    for i in range(len(M)):
        c += str(modexp(M[i], e, n))
        length.append(len(str(modexp(M[i], e, n))))
    return c

# Функция дешифрования
def rsa_decrypt(c):
    m = ''
    numbers = []
    startIndex = 0
    for i in range(len(length)):
        endIndex = startIndex + length[i]
        number = int(c[startIndex:endIndex])
        numbers.append(number)
        startIndex = endIndex
    for i in range(len(numbers)):
        m += chr(modexp(numbers[i], d, n))
    return m

# Пример шифрования и дешифрования
massage = "This is RSA encryption on python!:)"
enc = rsa_encrypt(massage)
dec = rsa_decrypt(enc)
print("\nEncrypted massage: ", enc, "\n\nDecrypted massage: ", dec)
