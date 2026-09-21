///|
fn digest_parse_rejected(input : String) -> Bool {
  try {
    ignore(parse_digest_field(input))
    false
  } catch {
    _ => true
  }
}

///|
test "RFC 9530 JSON example produces the published SHA-256 value" {
  let body = @base64.str2bytes("{\"hello\": \"world\"}\n")
  assert_eq(
    content_digest_sha256(body),
    "sha-256=:RK/0qy18MlBSVnWgjwz6lZEWjP/lF5HF9bvEF8FabDg=:",
  )
}

///|
test "empty content has the standard SHA-256 digest" {
  assert_eq(
    content_digest_sha256(Bytes::from_array([])),
    "sha-256=:47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=:",
  )
}

///|
test "streaming chunks equal one-shot digest" {
  let stream = Sha256Stream::new()
  stream.update(@base64.str2bytes("hello "))
  stream.update(@base64.str2bytes("world"))
  assert_eq(stream.finish(), sha256_utf8("hello world"))
}

///|
test "digest dictionaries canonicalize order and whitespace" {
  assert_eq(
    canonicalize_digest_field(" zed=:AA==:, sha-256=:AQI=: "),
    "sha-256=:AQI=:, zed=:AA==:",
  )
  assert_eq(
    canonicalize_preference_field("sha-512=4, sha-256=10"),
    "sha-256=10, sha-512=4",
  )
}

///|
test "malformed digest fields are rejected deterministically" {
  let invalid = [
    "", "sha-256=abcd", "sha-256=:***=:", "sha-256=:AQI:", "sha-256=:AQI=:,", "sha-256=:AQI=:, sha-256=:AQI=:",
    "SHA-256=:AQI=:",
  ]
  for input in invalid {
    assert_true(digest_parse_rejected(input))
  }
}

///|
test "preference weights outside 0 through 10 are rejected" {
  assert_true(
    try {
      ignore(parse_preference_field("sha-256=11"))
      false
    } catch {
      _ => true
    },
  )
}
