///|
priv struct FieldParser {
  source : String
  mut pos : Int
}

///|
fn FieldParser::peek(self : FieldParser) -> Int {
  if self.pos >= self.source.length() {
    -1
  } else {
    self.source[self.pos].to_int()
  }
}

///|
fn FieldParser::skip_sp(self : FieldParser) -> Unit {
  while self.peek() == 32 || self.peek() == 9 {
    self.pos += 1
  }
}

///|
fn[T] FieldParser::fail(
  self : FieldParser,
  code : String,
) -> T raise DigestFieldError {
  raise Syntax(code, self.pos)
}

///|
fn FieldParser::parse_key(self : FieldParser) -> String raise DigestFieldError {
  let start = self.pos
  if !is_key_first(self.peek()) {
    self.fail("EXPECTED_ALGORITHM_KEY")
  }
  self.pos += 1
  while is_key_rest(self.peek()) {
    self.pos += 1
  }
  self.source[start:self.pos].to_owned()
}

///|
fn FieldParser::expect(
  self : FieldParser,
  c : Int,
  code : String,
) -> Unit raise DigestFieldError {
  if self.peek() != c {
    self.fail(code)
  }
  self.pos += 1
}

///|
fn digest_member_index(values : Array[DigestMember], key : String) -> Int {
  for i = 0; i < values.length(); i = i + 1 {
    if values[i].algorithm == key {
      return i
    }
  }
  -1
}

///|
fn preference_index(values : Array[Preference], key : String) -> Int {
  for i = 0; i < values.length(); i = i + 1 {
    if values[i].algorithm == key {
      return i
    }
  }
  -1
}

///|
fn FieldParser::parse_byte_sequence(
  self : FieldParser,
) -> Bytes raise DigestFieldError {
  self.expect(58, "EXPECTED_BYTE_SEQUENCE")
  let start = self.pos
  while self.peek() != 58 {
    let c = self.peek()
    if c < 0 {
      self.fail("UNCLOSED_BYTE_SEQUENCE")
    }
    if !((c >= 65 && c <= 90) ||
      (c >= 97 && c <= 122) ||
      is_digit(c) ||
      c == 43 ||
      c == 47 ||
      c == 61) {
      self.fail("INVALID_BASE64_CHARACTER")
    }
    self.pos += 1
  }
  let encoded = self.source[start:self.pos].to_owned()
  self.pos += 1
  let decoded = @base64.std_decode2bytes(encoded) catch {
    _ => raise Syntax("INVALID_BASE64", start)
  }
  if @base64.std_encode2str(decoded.to_fixedarray()) != encoded {
    raise Syntax("NON_CANONICAL_BASE64", start)
  }
  decoded
}

///|
fn FieldParser::after_member(self : FieldParser) -> Bool raise DigestFieldError {
  self.skip_sp()
  if self.peek() < 0 {
    return false
  }
  self.expect(44, "EXPECTED_COMMA")
  self.skip_sp()
  if self.peek() < 0 {
    self.fail("TRAILING_COMMA")
  }
  true
}

///|
/// Parse an RFC 9530 Content-Digest or Repr-Digest value. This release uses a
/// strict Structured Fields subset: dictionary members must be explicit byte
/// sequences and parameters are rejected rather than silently ignored.
pub fn parse_digest_field(input : String) -> DigestField raise DigestFieldError {
  let parser = FieldParser::{ source: input, pos: 0, }
  parser.skip_sp()
  if parser.peek() < 0 {
    parser.fail("EMPTY_FIELD")
  }
  let members : Array[DigestMember] = []
  while true {
    let algorithm = parser.parse_key()
    if digest_member_index(members, algorithm) >= 0 {
      parser.fail("DUPLICATE_ALGORITHM")
    }
    parser.expect(61, "EXPECTED_EQUALS")
    let value = parser.parse_byte_sequence()
    members.push({ algorithm, value, })
    if !parser.after_member() {
      break
    }
  }
  { members, }
}

///|
fn FieldParser::parse_weight(self : FieldParser) -> Int raise DigestFieldError {
  let start = self.pos
  if !is_digit(self.peek()) {
    self.fail("EXPECTED_WEIGHT")
  }
  let mut value = 0
  while is_digit(self.peek()) {
    value = value * 10 + self.peek() - 48
    self.pos += 1
    if value > 10 {
      raise Policy("WEIGHT_OUT_OF_RANGE", start)
    }
  }
  value
}

///|
/// Parse Want-Content-Digest or Want-Repr-Digest. Weights are restricted to
/// RFC 9530's inclusive 0..10 range.
pub fn parse_preference_field(
  input : String,
) -> PreferenceField raise DigestFieldError {
  let parser = FieldParser::{ source: input, pos: 0, }
  parser.skip_sp()
  if parser.peek() < 0 {
    parser.fail("EMPTY_FIELD")
  }
  let members : Array[Preference] = []
  while true {
    let algorithm = parser.parse_key()
    if preference_index(members, algorithm) >= 0 {
      parser.fail("DUPLICATE_ALGORITHM")
    }
    parser.expect(61, "EXPECTED_EQUALS")
    let weight = parser.parse_weight()
    members.push({ algorithm, weight, })
    if !parser.after_member() {
      break
    }
  }
  { members, }
}
