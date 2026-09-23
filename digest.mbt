///|
/// Incremental SHA-256 calculator for HTTP message content.
pub(all) struct Sha256Stream {
  inner : @sha256.Digest
  mut bytes_written : Int
  mut finalized : Bool
}

///|
pub fn Sha256Stream::new() -> Sha256Stream {
  { inner: @sha256.Digest::new(), bytes_written: 0, finalized: false, }
}

///|
/// Add the next body chunk. Updating a finalized stream is rejected.
pub fn Sha256Stream::update(
  self : Sha256Stream,
  chunk : Bytes,
) -> Unit raise DigestFieldError {
  if self.finalized {
    raise State("STREAM_ALREADY_FINALIZED")
  }
  for byte in chunk {
    self.inner.write(byte)
  }
  self.bytes_written += chunk.length()
}

///|
/// Finalize and return the raw 32-byte SHA-256 digest.
pub fn Sha256Stream::finish(
  self : Sha256Stream,
) -> Bytes raise DigestFieldError {
  if self.finalized {
    raise State("STREAM_ALREADY_FINALIZED")
  }
  self.finalized = true
  hex_to_bytes(self.inner.check_sum())
}

///|
/// Compute SHA-256 for one byte string.
pub fn sha256(input : Bytes) -> Bytes raise DigestFieldError {
  let stream = Sha256Stream::new()
  stream.update(input)
  stream.finish()
}

///|
/// Compute SHA-256 over the UTF-8 bytes of a string.
pub fn sha256_utf8(input : String) -> Bytes raise DigestFieldError {
  sha256(@base64.str2bytes(input))
}

///|
/// Build a one-member DigestField using the active sha-256 algorithm.
pub fn sha256_digest_field(input : Bytes) -> DigestField raise DigestFieldError {
  { members: [{ algorithm: "sha-256", value: sha256(input), }], }
}

///|
/// Produce the field value used by Content-Digest or Repr-Digest.
pub fn content_digest_sha256(input : Bytes) -> String raise DigestFieldError {
  sha256_digest_field(input).to_string()
}

///|
/// Incremental binary-safe SHA-512 calculator.
pub(all) struct Sha512Stream {
  inner : @sha2.Sha512
  mut bytes_written : Int
  mut finalized : Bool
}

///|
pub fn Sha512Stream::new() -> Sha512Stream {
  { inner: @sha2.Sha512::new(), bytes_written: 0, finalized: false, }
}

///|
/// Add a body chunk without dropping embedded zero bytes.
pub fn Sha512Stream::update(
  self : Sha512Stream,
  chunk : Bytes,
) -> Unit raise DigestFieldError {
  if self.finalized {
    raise State("STREAM_ALREADY_FINALIZED")
  }
  let values : Array[UInt] = []
  for byte in chunk {
    values.push(byte.to_int().reinterpret_as_uint())
  }
  self.inner.update(values)
  self.bytes_written += chunk.length()
}

///|
/// Finalize and convert eight big-endian words to the RFC byte sequence.
pub fn Sha512Stream::finish(
  self : Sha512Stream,
) -> Bytes raise DigestFieldError {
  if self.finalized {
    raise State("STREAM_ALREADY_FINALIZED")
  }
  self.finalized = true
  let words = self.inner.finalize()
  let output : Array[Byte] = []
  for word in words {
    for shift in [56, 48, 40, 32, 24, 16, 8, 0] {
      output.push(((word >> shift) & 0xffUL).to_int().to_byte())
    }
  }
  Bytes::from_array(output)
}

///|
/// Compute binary-safe SHA-512.
pub fn sha512(input : Bytes) -> Bytes raise DigestFieldError {
  let stream = Sha512Stream::new()
  stream.update(input)
  stream.finish()
}

///|
/// Compute SHA-512 over UTF-8 string bytes.
pub fn sha512_utf8(input : String) -> Bytes raise DigestFieldError {
  sha512(@base64.str2bytes(input))
}

///|
/// Build a one-member DigestField using sha-512.
pub fn sha512_digest_field(input : Bytes) -> DigestField raise DigestFieldError {
  { members: [{ algorithm: "sha-512", value: sha512(input), }], }
}

///|
/// Produce a sha-512 field value.
pub fn content_digest_sha512(input : Bytes) -> String raise DigestFieldError {
  sha512_digest_field(input).to_string()
}

///|
/// Generate a multi-algorithm field in canonical order.
pub fn digest_field_for(
  input : Bytes,
  algorithms : Array[String],
) -> DigestField raise DigestFieldError {
  let members : Array[DigestMember] = []
  for requested in algorithms {
    let algorithm = ascii_lower(requested)
    if digest_member_index(members, algorithm) >= 0 {
      raise Policy("DUPLICATE_ALGORITHM", 0)
    }
    let value = match algorithm {
      "sha-256" => sha256(input)
      "sha-512" => sha512(input)
      _ => raise Policy("UNSUPPORTED_GENERATION_ALGORITHM", 0)
    }
    members.push({ algorithm, value, })
  }
  if members.length() == 0 {
    raise Policy("ALGORITHM_REQUIRED", 0)
  }
  { members, }
}
