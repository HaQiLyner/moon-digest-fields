# 生态定位与独立边界

## 与通用 Structured Fields 库的关系

通用 Structured Fields 库负责字典、列表、参数等语法结构，可以成为本项目未来
替换或扩展解析层的基础，但它通常不计算消息正文摘要，也不知道
`Content-Digest` 与 `Repr-Digest` 对应哪一组字节。本项目增加 SHA-256/SHA-512、
资源策略、摘要比较、Want-* 协商以及 HTTP 头字段接入，因此下游调用边界不同。

## 与 HTTP Message Signatures 的关系

HTTP Message Signatures 解决签名者身份和消息组件认证，可以把 Digest Fields
作为被签名组件，但不会自动证明调用方传入的正文与摘要字段一致。本项目不管理
密钥和签名，而是在签名前生成摘要、在签名验证后校验正文。两者组合形成“正文
完整性 + 身份认证”流程，单独使用时安全结论不同。

## 可独立复用的下游接口

- `apply_digest_header`：源站或文件服务生成并设置双摘要头；
- `verify_http_message`：客户端、反向代理或 API 网关校验头与正文；
- `negotiate_http_digest`：根据重复的 Want-* 字段选择服务端算法；
- `audit_entries`：离线检查抓包、对象存储元数据或网关日志。

接口只使用 `HttpHeader`、`HttpMessage` 和 `Bytes`，不绑定具体 HTTP 框架。仓库的
可执行示例展示协商、生成、验证和篡改检测；2500 条集成测试以及 20000 次双摘要
工作负载验证实际交付边界。
