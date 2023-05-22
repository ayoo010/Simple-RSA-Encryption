math.randomseed(os.time())
-- Функция для проверки, является ли число простым
function is_prime(n)
  if n < 2 then
    return false
  end
  for i = 2, math.sqrt(n) do
    if n % i == 0 then
      return false
    end
  end
  return true
end

-- Генерация двух простых чисел
function generate_primes(bit_length)
  local p, q
  repeat
    p = math.random(2^(bit_length/2), 2^(bit_length/2+1))
  until is_prime(p)
  repeat
    q = math.random(2^(bit_length/2), 2^(bit_length/2+1))
  until is_prime(q)
  return p, q
end

-- Вычисление значения функции Эйлера
function euler_func(p, q)
  return (p-1) * (q-1)
end

-- Вычисление закрытой экспоненты
function generate_private_key(e, phi)
  local k = 1
  while true do
    local d = (k * phi + 1) / e
    if d == math.floor(d) then
    	if d < 0 then d = d * -1 end
      return d
    end
    k = k + 1
  end
end

-- Генерация ключей
function generate_rsa_keys(bit_length)
  -- Генерация двух простых чисел
  local p, q = generate_primes(bit_length)
  
  -- Вычисление модуля и функции Эйлера
  local n = p * q
  local phi = euler_func(p, q)
  print("p = "..p, " q = "..q, "phi(n) = "..phi)
  -- Выбор открытой экспоненты
  local e = 65537
  
  -- Вычисление закрытой экспоненты
  local d = generate_private_key(e, phi)
  
  if e < 0 then e = e * -1 end
  if n < 0 then n = n * -1 end
  
  -- Возвращаем открытый и закрытый ключи
  return {n=n,e=e,d=d}
end

-- Разбиваем получаемое сообщение на ASCII
function plaintext(text)
	local ascii = {text:byte(1,-1)}
	return ascii
end

keys = generate_rsa_keys(30) -- Генерируем RSA ключи
e, n, d = keys.e, keys.n, keys.d
print("e = "..e, " n = "..n, " d = "..d)

-- Функция для возведения в степень по модулю
function modexp(base, exponent, modulus)
  if modulus == 1 then
    return 0
  end
  local result = 1
  base = base % modulus
  while exponent > 0 do
    if exponent % 2 == 1 then
      result = (result * base) % modulus
    end
    exponent = math.floor(exponent / 2)
    base = (base * base) % modulus
  end
  return result
end

-- Функция шифрования
length = {}
function rsa_encrypt(M)
  M = plaintext(M)
  local c = ''
  for i = 1, #M do
	c = c..modexp(M[i], e, n)
	length[i] = tostring(modexp(M[i], e, n)):len()
  end
  return c
end

-- Функция дешифрования
function rsa_decrypt(c)
  local c = tostring(c)
  local m = ''
  local numbers = {}
  local startIndex = 1
  for i = 1, #length do
    local endIndex = startIndex + length[i] - 1
    local number = tonumber(string.sub(tostring(c), startIndex, endIndex))
    table.insert(numbers, number)
    startIndex = endIndex + 1
  end
  for i in ipairs(numbers) do
  	m = m..string.char(modexp(numbers[i], d, n))
  end
  return m
end

-- Пример шифрования и дешифрования
massage = "This is RSA encryption on lua!:)"
enc = rsa_encrypt(massage)
dec = rsa_decrypt(enc)
print("\nEncrypted massage: "..enc, "\n\nDecrypted massage: "..dec)
