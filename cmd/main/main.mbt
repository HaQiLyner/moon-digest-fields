///|
/// End-to-end HTTP example: negotiate, generate both active algorithms, verify,
/// then demonstrate a downstream body mutation.
fn main raise {
  let body = @base64.str2bytes("{\"artifact\":\"moonbit\",\"version\":1}\n")
  let request_headers : Array[@digest.HttpHeader] = [
    { name: "Want-Content-Digest", value: "sha-512=10, sha-256=5", },
  ]
  let selected = @digest.negotiate_http_digest(request_headers, @digest.Content)
  let selected_name = match selected.algorithm {
    Some(value) => value
    None => "none"
  }
  println("negotiated: \{selected_name}")
  let origin = @digest.apply_digest_header(
    { headers: [{ name: "Content-Type", value: "application/json", }], body, },
    @digest.Content,
  )
  let verified = @digest.verify_http_message(origin, @digest.Content)
  println("verification: \{verified.verification.decision.to_string()}")
  println("Content-Digest: \{verified.combined_value}")
  let tampered : @digest.HttpMessage = {
    headers: origin.headers,
    body: @base64.str2bytes("{\"artifact\":\"changed\",\"version\":1}\n"),
  }
  println(
    "tampered body: \{@digest.verify_http_message(tampered, @digest.Content).verification.decision.to_string()}",
  )
}
