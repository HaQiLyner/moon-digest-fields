///|
/// Verify many captured HTTP records without aborting the batch on bad input.
pub fn audit_entries(
  entries : Array[AuditEntry],
  policy : VerificationPolicy,
) -> AuditReport {
  let findings : Array[AuditFinding] = []
  let mut verified = 0
  let mut mismatch = 0
  let mut invalid = 0
  let mut missing = 0
  let mut blocked = 0
  let mut too_large = 0
  for entry in entries {
    let result = match entry.field_value {
      None =>
        Verification::{
          target: entry.target,
          decision: MissingField,
          algorithm: "",
          code: "MISSING_FIELD",
          checked: 0,
          ignored: 0,
        }
      Some(value) =>
        verify_digest_field(entry.target, value, entry.body, policy)
    }
    match result.decision {
      Verified => verified += 1
      Mismatch => mismatch += 1
      InvalidField | NoSupportedAlgorithm => invalid += 1
      MissingField => missing += 1
      PolicyBlocked => blocked += 1
      BodyTooLarge => too_large += 1
    }
    findings.push({
      record_id: entry.record_id,
      target: entry.target,
      decision: result.decision,
      algorithm: result.algorithm,
      code: result.code,
    })
  }
  { findings, verified, mismatch, invalid, missing, blocked, too_large, }
}
