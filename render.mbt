///|
pub fn DigestField::to_string(self : DigestField) -> String {
  let members = sort_digest_members(self.members)
  let out = StringBuilder()
  for i = 0; i < members.length(); i = i + 1 {
    if i > 0 {
      out.write_string(", ")
    }
    out.write_string(ascii_lower(members[i].algorithm))
    out.write_string("=:")
    out.write_string(@base64.std_encode2str(members[i].value.to_fixedarray()))
    out.write_char(':')
  }
  out.to_string()
}

///|
pub fn PreferenceField::to_string(self : PreferenceField) -> String {
  let members = sort_preferences(self.members)
  let out = StringBuilder()
  for i = 0; i < members.length(); i = i + 1 {
    if i > 0 {
      out.write_string(", ")
    }
    out.write_string(ascii_lower(members[i].algorithm))
    out.write_char('=')
    out.write_string(members[i].weight.to_string())
  }
  out.to_string()
}

///|
pub fn canonicalize_digest_field(
  input : String,
) -> String raise DigestFieldError {
  parse_digest_field(input).to_string()
}

///|
pub fn canonicalize_preference_field(
  input : String,
) -> String raise DigestFieldError {
  parse_preference_field(input).to_string()
}

///|
pub fn DigestField::get(self : DigestField, algorithm : String) -> Bytes? {
  let expected = ascii_lower(algorithm)
  for item in self.members {
    if item.algorithm == expected {
      return Some(item.value)
    }
  }
  None
}
