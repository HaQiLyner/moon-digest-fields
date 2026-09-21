///|
/// End-to-end example: origin generates a field and a gateway verifies it.
fn main raise {
  let body = @base64.str2bytes("{\"artifact\":\"moonbit\",\"version\":1}\n")
  let field = @digest.content_digest_sha256(body)
  let result = @digest.verify_digest_field(
    @digest.Content,
    field,
    body,
    @digest.VerificationPolicy::default(),
  )
  println("Content-Digest: \{field}")
  println("verification: \{result.decision.to_string()}")
  let tampered = @digest.verify_digest_field(
    @digest.Content,
    field,
    @base64.str2bytes("{\"artifact\":\"changed\",\"version\":1}\n"),
    @digest.VerificationPolicy::default(),
  )
  println("tampered body: \{tampered.decision.to_string()}")
}
