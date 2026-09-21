///|
fn ascii_lower(input : String) -> String {
  let out = StringBuilder()
  for i = 0; i < input.length(); i = i + 1 {
    let c = input[i].to_int()
    out.write_char(
      Int::unsafe_to_char(if c >= 65 && c <= 90 { c + 32 } else { c }),
    )
  }
  out.to_string()
}

///|
fn is_lcalpha(c : Int) -> Bool {
  c >= 97 && c <= 122
}

///|
fn is_digit(c : Int) -> Bool {
  c >= 48 && c <= 57
}

///|
fn is_key_first(c : Int) -> Bool {
  is_lcalpha(c) || c == 42
}

///|
fn is_key_rest(c : Int) -> Bool {
  is_lcalpha(c) || is_digit(c) || c == 95 || c == 45 || c == 46 || c == 42
}

///|
fn hex_value(c : Int) -> Int {
  if c >= 48 && c <= 57 {
    c - 48
  } else if c >= 65 && c <= 70 {
    c - 55
  } else if c >= 97 && c <= 102 {
    c - 87
  } else {
    -1
  }
}

///|
fn hex_to_bytes(value : String) -> Bytes raise DigestFieldError {
  if value.length() % 2 != 0 {
    raise State("ODD_HEX_DIGEST")
  }
  let out : Array[Byte] = []
  for i = 0; i < value.length(); i = i + 2 {
    let hi = hex_value(value[i].to_int())
    let lo = hex_value(value[i + 1].to_int())
    if hi < 0 || lo < 0 {
      raise State("INVALID_HEX_DIGEST")
    }
    out.push((hi * 16 + lo).to_byte())
  }
  Bytes::from_array(out)
}

///|
fn bytes_equal_constant_time(left : Bytes, right : Bytes) -> Bool {
  let max_length = left.length().max(right.length())
  let mut difference = left.length() ^ right.length()
  for i = 0; i < max_length; i = i + 1 {
    let a = if i < left.length() { left[i].to_int() } else { 0 }
    let b = if i < right.length() { right[i].to_int() } else { 0 }
    difference = difference | (a ^ b)
  }
  difference == 0
}

///|
fn string_in(values : Array[String], expected : String) -> Bool {
  for value in values {
    if ascii_lower(value) == expected {
      return true
    }
  }
  false
}

///|
fn sort_digest_members(values : Array[DigestMember]) -> Array[DigestMember] {
  let out : Array[DigestMember] = []
  for value in values {
    out.push(value)
  }
  out.sort_by(fn(a, b) { String::lexical_compare(a.algorithm, b.algorithm) })
  out
}

///|
fn sort_preferences(values : Array[Preference]) -> Array[Preference] {
  let out : Array[Preference] = []
  for value in values {
    out.push(value)
  }
  out.sort_by(fn(a, b) { String::lexical_compare(a.algorithm, b.algorithm) })
  out
}
