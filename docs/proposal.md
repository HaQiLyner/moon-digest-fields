# Moon Digest Fields 项目申报书

## 一、项目名称及地址

- 项目名称：Moon Digest Fields——RFC 9530 HTTP 正文完整性工具库
- GitHub：https://github.com/HaQiLyner/moon-digest-fields
- MoonBit 模块：`HaQiLyner/moon_digest_fields`
- 开源许可证：Apache-2.0

## 二、项目简介

Moon Digest Fields 是一个使用 MoonBit 实现的 RFC 9530 工具库，为 HTTP
`Content-Digest`、`Repr-Digest`、`Want-Content-Digest` 和
`Want-Repr-Digest` 提供从字段解析、SHA-256/SHA-512 计算、算法协商到正文验证的完整链路。
项目解决的不是通用 Structured Fields 语法问题，而是源站、客户端下载器、反向代理和 API
网关如何把摘要字段真正应用到 HTTP 正文，并明确区分“字段损坏”“算法不支持”“策略拒绝”
与“正文遭到改变”。

## 三、项目方向与适用场景

项目属于网络协议基础库与开发工具方向。第一类场景是制品下载或对象存储：源站调用
`apply_digest_header` 为二进制正文生成 SHA-256 与 SHA-512，客户端或下载网关调用
`verify_http_message` 检测传输损坏及内容替换。第二类场景是 CDN 和反向代理：分别处理
`Content-Digest` 与 `Repr-Digest`，避免把经过内容编码的消息字节和选定表示混淆。第三类场景
是协议协商：服务端读取一个或多个 Want-* 头，根据客户端权重和服务端优先级选择算法。第四类
场景是 HTTP Message Signatures 流程，在签名前生成摘要、签名验证后再核对正文完整性。

## 四、核心功能、生态差异及复用边界

项目严格解析 RFC 9530 使用的 Structured Fields 字典子集，拒绝重复算法、非法 Base64、
尾随逗号和越界权重；支持稳定规范输出、二进制安全的分块 SHA-256/SHA-512、双算法联合验证、
旧算法策略、字段成员及正文大小限制、批量审计和 Want-* 权重协商。0.2.0 新增框架无关的
`HttpHeader`/`HttpMessage` 适配层，能够大小写不敏感地查找头部、按 HTTP 规则合并重复字段行、
替换陈旧摘要头，并直接返回可用于告警和统计的判定结果。

本项目与现有生态组件边界明确：通用 Structured Fields 库提供字典等语法结构，但不负责选择
正确的正文/表示字节、计算摘要和执行验证策略；HTTP 签名库负责身份与消息组件认证，但不自动
证明实际正文和摘要字段一致。Moon Digest Fields 不管理密钥、不实现 TLS 和 HTTP 传输栈，
而是提供可单独复用的正文完整性层，也可以与上述两类库组合。

## 五、实际场景、测试及验收标准

仓库当前包含 17 个确定性测试。已知向量包括 RFC 9530 的 JSON/空正文 SHA-256 示例、NIST
SHA-512 `abc` 向量以及含零字节二进制正文，验证分块与一次性结果一致。HTTP 测试覆盖重复字段
行、不同大小写头名、陈旧头替换、Content/Repr 选择、Want-* 协商、正文改变和字段缺失。

实际网关场景通过 HTTP 适配层处理 2500 条响应，固定得到 2000 条 Verified、250 条 Mismatch、
125 条 InvalidField 和 125 条 MissingField。性能工作负载对 64 字节正文连续执行 20000 次
“头查找与合并 + 双字段解析 + Base64 解码 + SHA-256 + SHA-512 + 比较”；在 Windows 11、
i7-14650HX、MoonBit 0.10.12、JS 后端上五次顺序运行中位数为 998 ms，约 20040 条/秒。

验收标准为：RFC/NIST 向量完全匹配；嵌入零字节不丢失；单字节正文变化必须判定为 Mismatch；
所有 2500 条场景记录分类总和准确；可执行示例完成协商、生成、验证和篡改检测；wasm、
wasm-gc、JavaScript、native 四后端 CI 全部通过。

## 六、原创性及后续规划

项目根据 RFC 9530 独立设计并以 MoonBit 实现，摘要与 Base64 使用已声明版本和许可证的
MoonCakes 依赖，来源记录在 `docs/provenance.md`。后续计划包括 Structured Fields 更完整的
互操作语料、模糊测试、流式文件/网络读取适配、常用 MoonBit HTTP 框架示例以及与 HTTP
Message Signatures 的组合演示。当前项目成果仅以仓库中已实现的双算法、HTTP 适配、17 个
测试、2500 条场景和可复现性能工作负载为验收依据。
