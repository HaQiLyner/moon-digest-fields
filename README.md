# Moon Digest Fields

[![CI](https://github.com/HaQiLyner/moon-digest-fields/actions/workflows/ci.yml/badge.svg)](https://github.com/HaQiLyner/moon-digest-fields/actions/workflows/ci.yml)

MoonBit 实现的 RFC 9530 HTTP Digest Fields 工具库，用于生成、解析和验证
`Content-Digest`、`Repr-Digest`、`Want-Content-Digest` 与
`Want-Repr-Digest`。它面向下载网关、API 响应校验、代理审计和消息签名流水线，
把“字段是否能解析”和“消息体是否真的匹配”分成可观察的结果。0.2.0 可直接接收
框架无关的 HTTP 头与正文，不要求下游自行拼装字段。

## 核心能力

- 严格解析 RFC 9530 所用 Structured Fields 字典子集，拒绝重复算法、非法 Base64、越界权重和尾随逗号；
- 对字段成员排序并生成稳定表示；
- 一次性或分块计算二进制安全的 SHA-256 与 SHA-512，可生成双算法字段；
- 以大小写不敏感方式读取 HTTP 头、合并重复字段行并设置/替换摘要头；
- 从 `Want-Content-Digest`/`Want-Repr-Digest` 直接协商服务端算法；
- 区分匹配、篡改、字段无效、算法不支持、策略阻止、字段缺失和正文超限；
- 按客户端权重和服务端优先级协商算法；
- 批量审计捕获的 HTTP 记录，单条坏数据不会中断整批处理；
- 在 wasm、wasm-gc、JavaScript、native 四个目标上执行 CI。

## 快速开始

```sh
moon add HaQiLyner/moon_digest_fields@0.2.0
```

```moonbit nocheck
let body = @base64.str2bytes("{\"hello\": \"world\"}\n")
let response = @digest.apply_digest_header(
  { headers: [{ name: "Content-Type", value: "application/json" }], body },
  @digest.Content,
)
let result = @digest.verify_http_message(response, @digest.Content)
println(result.verification.decision.to_string()) // verified
```

```sh
moon update
moon test --target js
moon run cmd/main --target js
moon run examples/bench --target js
```

## 验收边界

0.2.0 的验收范围是：四类字段的严格解析/稳定输出、SHA-256/SHA-512 生成与
分块计算、HTTP 头接入、验证策略、算法协商、批量审计、RFC/NIST 已知向量、
篡改用例、2500 条 HTTP 集成场景和 20000 次双摘要吞吐工作负载。明确不包含
HTTP 传输栈、TLS、HTTP Message Signatures、内容编码解压或媒体格式规范化。调用方必须把正确的
内容（Content）或选定表示（Representation）字节交给库。

## 测试与实际场景

`http_scenario_test.mbt` 通过 HTTP 适配层处理 2500 条响应：2000 条通过、250
条正文被改动、125 条字段损坏、125 条字段缺失。`examples/bench` 对完整的
HTTP 头查找、双字段解析、SHA-256/SHA-512 与比较路径执行 20000 次。测量方法见
[场景验证](docs/scenario-validation.md)。

## 文档

- [场景验证与复现](docs/scenario-validation.md)
- [来源、依赖与许可证](docs/provenance.md)
- [生态定位与独立边界](docs/ecosystem-positioning.md)
- [开发路线图](docs/roadmap.md)
- [0.1.0 发布验证](docs/release-verification.md)
- [项目申报书](docs/proposal.md)

## 许可证

Apache-2.0。依赖与改编来源说明见 `docs/provenance.md`。
