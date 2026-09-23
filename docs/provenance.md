# 来源、依赖与许可证

本项目为原创 MoonBit 实现，协议行为依据
[RFC 9530: Digest Fields](https://www.rfc-editor.org/rfc/rfc9530.html)。RFC 文本仅
用于实现互操作规则和测试向量，未复制第三方项目代码。

| 依赖 | 版本 | 用途 | 许可证/来源 |
|---|---|---|---|
| `gmlewis/sha256` | 0.17.33 | 增量 SHA-256 | Apache-2.0；包内注明算法实现源自 Go SHA-256，并保留 BSD notice |
| `gmlewis/base64` | 0.16.12 | byte sequence 编解码 | Apache-2.0 |
| `Tigls/mb-hash` | 0.1.0 | 二进制安全 SHA-512 核心 | MoonCakes 元数据标注 Apache-2.0 |

依赖版本固定在 `moon.mod`。项目自身以 Apache-2.0 发布。

2026-09-21 对 MoonCakes 本地索引和 GitHub 进行关键词核查时，未发现以 RFC
9530 `Content-Digest`/`Repr-Digest` 为边界的 MoonBit 包。该结论仅表示“在所
检索来源中未发现精确匹配”，不声称整个互联网绝对不存在实现。

邻近项目 HTTP Message Signatures 负责身份认证与消息组件签名；通用 Structured
Fields 库提供语法数据结构。本项目负责 RFC 9530 的算法计算、内容/表示语义、
Want-* 协商、HTTP 头接入与策略结果。三者可以串联，但不互相替代。
