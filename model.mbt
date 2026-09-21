///|
/// Stable syntax or policy failure. Offsets are zero-based UTF-16 positions
/// in the original field value. Error values never echo the full input.
pub(all) suberror DigestFieldError {
  Syntax(String, Int)
  Policy(String, Int)
  State(String)
} derive(Eq, @debug.Debug)

///|
pub(all) enum AlgorithmStatus {
  Active
  Deprecated
  Unknown
} derive(Eq, @debug.Debug)

///|
pub fn algorithm_status(algorithm : String) -> AlgorithmStatus {
  match ascii_lower(algorithm) {
    "sha-256" | "sha-512" => Active
    "md5" | "sha" | "unixsum" | "unixcksum" | "adler" | "crc32c" => Deprecated
    _ => Unknown
  }
}

///|
pub(all) struct DigestMember {
  algorithm : String
  value : Bytes
} derive(Eq, @debug.Debug)

///|
pub(all) struct DigestField {
  members : Array[DigestMember]
} derive(Eq, @debug.Debug)

///|
pub(all) struct Preference {
  algorithm : String
  weight : Int
} derive(Eq, @debug.Debug)

///|
pub(all) struct PreferenceField {
  members : Array[Preference]
} derive(Eq, @debug.Debug)

///|
pub(all) enum IntegrityTarget {
  Content
  Representation
} derive(Eq, @debug.Debug)

///|
pub(all) enum VerificationDecision {
  Verified
  Mismatch
  NoSupportedAlgorithm
  PolicyBlocked
  BodyTooLarge
  MissingField
  InvalidField
} derive(Eq, @debug.Debug)

///|
pub fn VerificationDecision::to_string(self : VerificationDecision) -> String {
  match self {
    Verified => "verified"
    Mismatch => "mismatch"
    NoSupportedAlgorithm => "no-supported-algorithm"
    PolicyBlocked => "policy-blocked"
    BodyTooLarge => "body-too-large"
    MissingField => "missing-field"
    InvalidField => "invalid-field"
  }
}

///|
pub(all) struct VerificationPolicy {
  allowed_algorithms : Array[String]
  reject_deprecated : Bool
  require_all_supported : Bool
  max_body_bytes : Int
  max_field_members : Int
} derive(Eq, @debug.Debug)

///|
pub fn VerificationPolicy::default() -> VerificationPolicy {
  {
    allowed_algorithms: ["sha-256"],
    reject_deprecated: true,
    require_all_supported: true,
    max_body_bytes: 16 * 1024 * 1024,
    max_field_members: 8,
  }
}

///|
pub(all) struct Verification {
  target : IntegrityTarget
  decision : VerificationDecision
  algorithm : String
  code : String
  checked : Int
  ignored : Int
} derive(Eq, @debug.Debug)

///|
pub(all) struct AuditEntry {
  record_id : String
  target : IntegrityTarget
  field_value : String?
  body : Bytes
} derive(Eq, @debug.Debug)

///|
pub(all) struct AuditFinding {
  record_id : String
  target : IntegrityTarget
  decision : VerificationDecision
  algorithm : String
  code : String
} derive(Eq, @debug.Debug)

///|
pub(all) struct AuditReport {
  findings : Array[AuditFinding]
  verified : Int
  mismatch : Int
  invalid : Int
  missing : Int
  blocked : Int
  too_large : Int
} derive(Eq, @debug.Debug)

///|
pub(all) struct NegotiationResult {
  algorithm : String?
  acceptable : Int
  unsupported : Int
  prohibited : Int
} derive(Eq, @debug.Debug)
