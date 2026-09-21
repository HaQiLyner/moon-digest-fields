# Moon Digest Fields 项目申报书事实底稿

> 重要：比赛要求申报书由参赛者本人完成。以下是技术事实和一页结构底稿，
> 不是可直接冒充本人写作提交的成稿。请参赛者亲自改写表达、补充真实动机并
> 核对实测数据后，再复制到报名表。

## 1. 项目名称与仓库

- 项目名称：Moon Digest Fields
- GitHub：https://github.com/HaQiLyner/moon-digest-fields
- MoonCakes：[`HaQiLyner/moon_digest_fields@0.1.0`](https://mooncakes.io/api/v0/modules/HaQiLyner/moon_digest_fields)
- 许可证：Apache-2.0

## 2. 项目简介（请本人改写）

用自己的话说明：这是一个 MoonBit 的 RFC 9530 HTTP Digest Fields 工具库，
解决 HTTP 正文/表示在传输、缓存、代理或制品分发过程中缺少统一生成和验真
工具的问题。当前实现能够解析和稳定输出四类字段，增量计算 SHA-256，执行
策略化验证与算法协商，并对捕获记录做隔离式批量审计。

## 3. 项目方向与适用场景

1. 下载/API 网关：生成或验证 `Content-Digest`，区分字段无效与正文不匹配。
2. CDN/代理：分别处理 `Content-Digest` 与 `Repr-Digest`，避免把内容字节和
   选定表示混为一谈。
3. 签名流水线：在 HTTP Message Signatures 之前生成或验证摘要字段；本项目
   本身不负责身份认证。
4. 离线审计：批量检查抓包或网关日志，坏记录不终止整批任务。

## 4. 核心功能与验收边界

- 严格解析、规范输出四类 RFC 9530 字段；
- SHA-256 一次性/分块生成和摘要验证；
- 旧算法拒绝、未知算法处理、正文及字段成员上限；
- 权重协商和 2000 条批量审计；
- 11 项测试覆盖 RFC 已知向量、篡改、非法输入和策略分支；
- CI 覆盖 wasm、wasm-gc、JS、native。

0.1 不包含 HTTP 栈、TLS、消息签名、SHA-512 计算、自动解压和媒体规范化。
验收命令是 `moon test --target js`、`moon run cmd/main --target js` 与
`moon run examples/bench --target js`。

## 5. 实际场景与性能证据（提交前重跑并确认）

场景测试固定审计 2000 条记录：1600 条通过、200 条篡改、100 条字段损坏、
100 条缺失，测试断言所有分类。2026-09-21 本机 JS 后端的 20000 次完整验证
工作负载耗时 228 ms，约 87719 条/秒。该数字是本机墙钟结果，不是跨语言性能
承诺；复现方法在 `docs/scenario-validation.md`。

## 6. 原创性、来源与后续计划（请本人确认）

项目为原创 MoonBit 实现，协议依据 RFC 9530；SHA-256 与 Base64 使用已声明的
Apache-2.0 MoonCakes 依赖。检索 MoonCakes 与 GitHub 时未发现精确同方向的
MoonBit 包。下一阶段计划增加 SHA-512、多算法验证、框架适配示例、模糊测试和
流式 IO 适配层。提交前请本人确认上述事实，并补一两句真实的选题动机与后续
维护安排。
