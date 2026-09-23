# 发布验证

## 0.2.0（2026-09-23）

使用 MoonCakes 账号 `HaQiLyner` 发布，服务器返回 `200 OK`。随后使用另一份
MoonCakes 配置在全新模块中下载 `HaQiLyner/moon_digest_fields@0.2.0`，仅通过
公开 API 为含零字节正文设置 SHA-256/SHA-512 双摘要 HTTP 头并验证，JavaScript
和 wasm-gc 均为 1/1 测试通过。

## 0.1.0（2026-09-21）

2026-09-21 使用 MoonCakes 账号 `HaQiLyner` 发布 0.1.0，服务器返回 `200 OK`。
公开注册表接口：

https://mooncakes.io/api/v0/modules/HaQiLyner/moon_digest_fields

接口确认：版本为 0.1.0、未撤回、构建状态为 `success`、许可证为 Apache-2.0，
源仓库指向 `https://github.com/HaQiLyner/moon-digest-fields`。

随后在独立目录创建全新的 MoonBit 模块，并执行：

```sh
moon add HaQiLyner/moon_digest_fields@0.1.0
moon test --target js --deny-warn
moon test --target wasm-gc --deny-warn
```

注册表重新下载了发布包；消费者只通过公开 API 生成空正文的 RFC SHA-256
字段并完成验证。JS 与 wasm-gc 均为 1/1 测试通过。
