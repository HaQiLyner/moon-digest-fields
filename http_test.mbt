///|
test "HTTP adapter combines repeated case-insensitive digest fields" {
  let body = @base64.str2bytes("HTTP representation body")
  let generated = digest_field_for(body, ["sha-256", "sha-512"])
  let message : HttpMessage = {
    headers: [
      { name: "content-type", value: "text/plain", },
      {
        name: "content-digest",
        value: DigestField::{ members: [generated.members[0]], }.to_string(),
      },
      {
        name: "Content-Digest",
        value: DigestField::{ members: [generated.members[1]], }.to_string(),
      },
    ],
    body,
  }
  let result = verify_http_message(message, Content)
  assert_eq(result.occurrences, 2)
  assert_eq(result.verification.decision, Verified)
  assert_eq(result.verification.checked, 2)
}

///|
test "HTTP adapter detects body mutation and missing representation field" {
  let original = @base64.str2bytes("download-v1")
  let field = content_digest_sha512(original)
  let changed : HttpMessage = {
    headers: [{ name: "Content-Digest", value: field, }],
    body: @base64.str2bytes("download-v2"),
  }
  assert_eq(
    verify_http_message(changed, Content).verification.decision,
    Mismatch,
  )
  assert_eq(
    verify_http_message(changed, Representation).verification.decision,
    MissingField,
  )
}

///|
test "HTTP adapter replaces stale header and negotiates client preference" {
  let message : HttpMessage = {
    headers: [
      { name: "Content-Type", value: "application/octet-stream", },
      { name: "CONTENT-DIGEST", value: "sha-256=:AA==:", },
      { name: "Want-Content-Digest", value: "sha-256=5", },
      { name: "want-content-digest", value: "sha-512=10", },
    ],
    body: @base64.str2bytes("release"),
  }
  let updated = apply_digest_header(message, Content)
  let verified = verify_http_message(updated, Content)
  assert_eq(verified.occurrences, 1)
  assert_eq(verified.verification.decision, Verified)
  assert_eq(
    negotiate_http_digest(message.headers, Content).algorithm,
    Some("sha-512"),
  )
}
