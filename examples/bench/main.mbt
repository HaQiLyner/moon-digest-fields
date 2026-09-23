///|
/// Print a local wall-clock throughput result. This is a reproducible workload,
/// not a cross-language benchmark.
fn main raise {
  let body = @base64.str2bytes(
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  )
  let message = @digest.apply_digest_header(
    {
      headers: [{ name: "Content-Type", value: "application/octet-stream", }],
      body,
    },
    @digest.Content,
  )
  let iterations = 20_000
  let started = @env.now()
  let mut verified = 0
  for i = 0; i < iterations; i = i + 1 {
    let result = @digest.verify_http_message(message, @digest.Content)
    if result.verification.decision == @digest.Verified {
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
    "verified \{verified}/\{iterations} dual-digest HTTP messages in \{elapsed_ms} ms (\{per_second} messages/s)",
  )
}
