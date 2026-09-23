///|
fn compute_supported_digest(
  algorithm : String,
  body : Bytes,
) -> Bytes? raise DigestFieldError {
  match algorithm {
    "sha-256" => Some(sha256(body))
    "sha-512" => Some(sha512(body))
    _ => None
  }
}

///|
/// Verify a parsed Content-Digest or Repr-Digest value against body bytes.
pub fn verify_digest(
  target : IntegrityTarget,
  field : DigestField,
  body : Bytes,
  policy : VerificationPolicy,
) -> Verification {
  if body.length() > policy.max_body_bytes {
    return {
      target,
      decision: BodyTooLarge,
      algorithm: "",
      code: "BODY_LIMIT",
      checked: 0,
      ignored: 0,
    }
  }
  if field.members.length() > policy.max_field_members {
    return {
      target,
      decision: PolicyBlocked,
      algorithm: "",
      code: "MEMBER_LIMIT",
      checked: 0,
      ignored: 0,
    }
  }
  let mut checked = 0
  let mut ignored = 0
  let mut matched = 0
  let mut last_algorithm = ""
  for item in field.members {
    let algorithm = ascii_lower(item.algorithm)
    match algorithm_status(algorithm) {
      Deprecated if policy.reject_deprecated =>
        return {
          target,
          decision: PolicyBlocked,
          algorithm,
          code: "DEPRECATED_ALGORITHM",
          checked,
          ignored,
        }
      _ => ()
    }
    if !string_in(policy.allowed_algorithms, algorithm) {
      ignored += 1
      continue
    }
    let actual = compute_supported_digest(algorithm, body) catch {
      _ =>
        return {
          target,
          decision: InvalidField,
          algorithm,
          code: "DIGEST_FAILURE",
          checked,
          ignored,
        }
    }
    guard actual is Some(actual_digest) else {
      ignored += 1
      continue
    }
    checked += 1
    last_algorithm = algorithm
    if bytes_equal_constant_time(actual_digest, item.value) {
      matched += 1
    } else if policy.require_all_supported {
      return {
        target,
        decision: Mismatch,
        algorithm,
        code: "DIGEST_MISMATCH",
        checked,
        ignored,
      }
    }
  }
  if checked == 0 {
    {
      target,
      decision: NoSupportedAlgorithm,
      algorithm: "",
      code: "NO_SUPPORTED_ALGORITHM",
      checked,
      ignored,
    }
  } else if matched > 0 {
    {
      target,
      decision: Verified,
      algorithm: last_algorithm,
      code: "OK",
      checked,
      ignored,
    }
  } else {
    {
      target,
      decision: Mismatch,
      algorithm: last_algorithm,
      code: "DIGEST_MISMATCH",
      checked,
      ignored,
    }
  }
}

///|
/// Parse and verify a wire-format field value.
pub fn verify_digest_field(
  target : IntegrityTarget,
  field_value : String,
  body : Bytes,
  policy : VerificationPolicy,
) -> Verification {
  let field = parse_digest_field(field_value) catch {
    _ =>
      return {
        target,
        decision: InvalidField,
        algorithm: "",
        code: "INVALID_FIELD",
        checked: 0,
        ignored: 0,
      }
  }
  verify_digest(target, field, body, policy)
}
