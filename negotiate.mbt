///|
/// Select the supported algorithm with the greatest non-zero client weight.
/// Server preference order breaks ties.
pub fn negotiate_digest_algorithm(
  preferences : PreferenceField,
  supported : Array[String],
) -> NegotiationResult {
  let mut selected : String? = None
  let mut selected_weight = -1
  let mut selected_priority = supported.length()
  let mut acceptable = 0
  let mut unsupported = 0
  let mut prohibited = 0
  for pref in preferences.members {
    let algorithm = ascii_lower(pref.algorithm)
    if pref.weight == 0 {
      prohibited += 1
      continue
    }
    let mut priority = -1
    for i = 0; i < supported.length(); i = i + 1 {
      if ascii_lower(supported[i]) == algorithm {
        priority = i
        break
      }
    }
    if priority < 0 {
      unsupported += 1
      continue
    }
    acceptable += 1
    if pref.weight > selected_weight ||
      (pref.weight == selected_weight && priority < selected_priority) {
      selected = Some(algorithm)
      selected_weight = pref.weight
      selected_priority = priority
    }
  }
  { algorithm: selected, acceptable, unsupported, prohibited, }
}
