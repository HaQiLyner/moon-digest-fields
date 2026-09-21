///|
/// A repeatable integration workload modelling an artifact gateway audit.
test "gateway audit classifies 2000 captured responses" {
  let body = @base64.str2bytes("signed release artifact\n")
  let good_field = content_digest_sha256(body)
  let wrong_field = content_digest_sha256(
    @base64.str2bytes("tampered artifact\n"),
  )
  let entries : Array[AuditEntry] = []
  for i = 0; i < 2000; i = i + 1 {
    let field_value = if i < 1600 {
      Some(good_field)
    } else if i < 1800 {
      Some(wrong_field)
    } else if i < 1900 {
      Some("sha-256=:not-base64:")
    } else {
      None
    }
    entries.push({
      record_id: "response-" + i.to_string(),
      target: if i % 2 == 0 {
        Content
      } else {
        Representation
      },
      field_value,
      body,
    })
  }
  let report = audit_entries(entries, VerificationPolicy::default())
  assert_eq(report.findings.length(), 2000)
  assert_eq(report.verified, 1600)
  assert_eq(report.mismatch, 200)
  assert_eq(report.invalid, 100)
  assert_eq(report.missing, 100)
  assert_eq(report.blocked, 0)
  assert_eq(report.too_large, 0)
}
