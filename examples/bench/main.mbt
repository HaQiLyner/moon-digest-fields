///|
/// Print a local wall-clock throughput result. This is a reproducible workload,
/// not a cross-language benchmark.
fn main raise {
  let body = @base64.str2bytes(
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  )
  let field = @digest.content_digest_sha256(body)
  let policy = @digest.VerificationPolicy::default()
  let iterations = 20_000
  let started = @env.now()
  let mut verified = 0
  for i = 0; i < iterations; i = i + 1 {
    let result = @digest.verify_digest_field(
      @digest.Content,
      field,
      body,
      policy,
    )
    if result.decision == @digest.Verified {
      verified += 1
    }
  }
  let elapsed_ms = @env.now() - started
  let per_second = if elapsed_ms > 0 {
    iterations.to_uint64() * 1000UL / elapsed_ms
  } else {
    0UL
  }
  println(
    "verified \{verified}/\{iterations} records in \{elapsed_ms} ms (\{per_second} records/s)",
  )
}
