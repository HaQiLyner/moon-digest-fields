// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "HaQiLyner/moon_digest_fields"

version = "0.1.0"

readme = "README.mbt.md"

repository = "https://github.com/HaQiLyner/moon-digest-fields"

license = "Apache-2.0"

keywords = [ "http", "digest", "rfc9530", "integrity" ]

preferred_target = "wasm"

description = "RFC 9530 HTTP Digest Fields parsing, SHA-256 generation, verification, negotiation, and audit toolkit"

import {
  "gmlewis/sha256@0.17.33",
  "gmlewis/base64@0.16.12",
}
