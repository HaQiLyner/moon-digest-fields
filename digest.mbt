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
