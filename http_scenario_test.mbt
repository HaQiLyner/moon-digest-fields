///|
/// Reverse-proxy integration scenario using real header lookup, field
/// combination, SHA-256/SHA-512 verification, and stable outcome accounting.
test "HTTP gateway classifies 2500 responses" {
  let body = @base64.str2bytes("release artifact bytes\n")
  let valid = apply_digest_header(
    {
      headers: [{ name: "Content-Type", value: "application/octet-stream", }],
      body,
    },
    Content,
  )
  let changed = @base64.str2bytes("release artifact changed\n")
  let mut verified = 0
  let mut mismatch = 0
  let mut invalid = 0
  let mut missing = 0
  for i = 0; i < 2500; i = i + 1 {
    let message : HttpMessage = if i < 2000 {
      valid
    } else if i < 2250 {
      { headers: valid.headers, body: changed, }
    } else if i < 2375 {
      {
        headers: [{ name: "Content-Digest", value: "sha-512=:broken:", }],
        body,
      }
    } else {
      {
        headers: [{ name: "Content-Type", value: "application/octet-stream", }],
        body,
      }
    }
    match verify_http_message(message, Content).verification.decision {
      Verified => verified += 1
      Mismatch => mismatch += 1
      InvalidField => invalid += 1
      MissingField => missing += 1
      _ => ()
    }
  }
  assert_eq(verified, 2000)
  assert_eq(mismatch, 250)
  assert_eq(invalid, 125)
  assert_eq(missing, 125)
}
