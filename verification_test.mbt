///|
fn bytes(value : String) -> Bytes {
  @base64.str2bytes(value)
}

///|
test "generated field verifies and one-byte mutation fails" {
  let body = bytes("release artifact 42")
  let field = content_digest_sha256(body)
  let good = verify_digest_field(
    Content,
    field,
    body,
    VerificationPolicy::default(),
  )
  assert_eq(good.decision, Verified)
  assert_eq(good.algorithm, "sha-256")
  let bad = verify_digest_field(
    Content,
    field,
    bytes("release artifact 43"),
    VerificationPolicy::default(),
  )
  assert_eq(bad.decision, Mismatch)
  assert_eq(bad.code, "DIGEST_MISMATCH")
}

///|
test "unknown, deprecated, and oversized inputs have separate decisions" {
  let policy = VerificationPolicy::default()
  assert_eq(
    verify_digest_field(Content, "future-hash=:AA==:", bytes("x"), policy).decision,
    NoSupportedAlgorithm,
  )
  assert_eq(
    verify_digest_field(Content, "md5=:AA==:", bytes("x"), policy).decision,
    PolicyBlocked,
  )
  let tiny = VerificationPolicy::{ ..policy, max_body_bytes: 1, }
  assert_eq(
    verify_digest_field(Content, "sha-256=:AA==:", bytes("xx"), tiny).decision,
    BodyTooLarge,
  )
}

///|
test "negotiation uses weight then server preference for ties" {
  let first = negotiate_digest_algorithm(
    parse_preference_field("sha-512=4, sha-256=10, md5=0"),
    ["sha-512", "sha-256"],
  )
  assert_eq(first.algorithm, Some("sha-256"))
  assert_eq(first.prohibited, 1)
  let tie = negotiate_digest_algorithm(
    parse_preference_field("sha-256=8, sha-512=8"),
    ["sha-512", "sha-256"],
  )
  assert_eq(tie.algorithm, Some("sha-512"))
}

///|
test "batch audit isolates missing invalid mismatch and verified records" {
  let body = bytes("payload")
  let valid = content_digest_sha256(body)
  let entries : Array[AuditEntry] = [
    { record_id: "ok", target: Content, field_value: Some(valid), body, },
    {
      record_id: "changed",
      target: Content,
      field_value: Some(content_digest_sha256(bytes("other"))),
      body,
    },
    {
      record_id: "broken",
      target: Representation,
      field_value: Some("not a field"),
      body,
    },
    { record_id: "missing", target: Content, field_value: None, body, },
  ]
  let report = audit_entries(entries, VerificationPolicy::default())
  assert_eq(report.findings.length(), 4)
  assert_eq(report.verified, 1)
  assert_eq(report.mismatch, 1)
  assert_eq(report.invalid, 1)
  assert_eq(report.missing, 1)
  assert_eq(report.findings[2].code, "INVALID_FIELD")
}
