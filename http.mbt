///|
pub(all) struct HttpHeader {
  name : String
  value : String
} derive(Eq, @debug.Debug)

///|
pub(all) struct HttpMessage {
  headers : Array[HttpHeader]
  body : Bytes
} derive(Eq, @debug.Debug)

///|
pub(all) struct HttpIntegrityResult {
  field_name : String
  combined_value : String
  occurrences : Int
  verification : Verification
} derive(Eq, @debug.Debug)

///|
fn digest_header_name(target : IntegrityTarget) -> String {
  match target {
    Content => "Content-Digest"
    Representation => "Repr-Digest"
  }
}

///|
fn want_digest_header_name(target : IntegrityTarget) -> String {
  match target {
    Content => "Want-Content-Digest"
    Representation => "Want-Repr-Digest"
  }
}

///|
fn header_values(headers : Array[HttpHeader], name : String) -> Array[String] {
  let expected = ascii_lower(name)
  let values : Array[String] = []
  for header in headers {
    if ascii_lower(header.name) == expected {
      values.push(header.value)
    }
  }
  values
}

///|
fn combine_field_lines(values : Array[String]) -> String {
  let output = StringBuilder()
  for i = 0; i < values.length(); i = i + 1 {
    if i > 0 {
      output.write_string(", ")
    }
    output.write_string(values[i])
  }
  output.to_string()
}

///|
/// Verify digest headers from an HTTP adapter without depending on a specific
/// server framework. Repeated field lines are combined in wire order.
pub fn verify_http_message(
  message : HttpMessage,
  target : IntegrityTarget,
  policy? : VerificationPolicy = VerificationPolicy::default(),
) -> HttpIntegrityResult {
  let field_name = digest_header_name(target)
  let values = header_values(message.headers, field_name)
  if values.length() == 0 {
    return {
      field_name,
      combined_value: "",
      occurrences: 0,
      verification: {
        target,
        decision: MissingField,
        algorithm: "",
        code: "MISSING_FIELD",
        checked: 0,
        ignored: 0,
      },
    }
  }
  let combined_value = combine_field_lines(values)
  {
    field_name,
    combined_value,
    occurrences: values.length(),
    verification: verify_digest_field(
      target,
      combined_value,
      message.body,
      policy,
    ),
  }
}

///|
/// Generate and set Content-Digest or Repr-Digest, replacing field lines with
/// the same case-insensitive name while preserving all unrelated headers.
pub fn apply_digest_header(
  message : HttpMessage,
  target : IntegrityTarget,
  algorithms? : Array[String] = ["sha-256", "sha-512"],
) -> HttpMessage raise DigestFieldError {
  let name = digest_header_name(target)
  let expected = ascii_lower(name)
  let headers : Array[HttpHeader] = []
  for header in message.headers {
    if ascii_lower(header.name) != expected {
      headers.push(header)
    }
  }
  headers.push({
    name,
    value: digest_field_for(message.body, algorithms).to_string(),
  })
  { headers, body: message.body, }
}

///|
/// Parse Want-Content-Digest or Want-Repr-Digest headers and choose an
/// algorithm. Repeated field lines are combined before parsing.
pub fn negotiate_http_digest(
  headers : Array[HttpHeader],
  target : IntegrityTarget,
  supported? : Array[String] = ["sha-512", "sha-256"],
) -> NegotiationResult raise DigestFieldError {
  let values = header_values(headers, want_digest_header_name(target))
  if values.length() == 0 {
    return { algorithm: None, acceptable: 0, unsupported: 0, prohibited: 0, }
  }
  negotiate_digest_algorithm(
    parse_preference_field(combine_field_lines(values)),
    supported,
  )
}
