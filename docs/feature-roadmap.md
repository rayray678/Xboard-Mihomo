# Xboard-Mihomo 新功能路线图

本路线图用于把“修到能跑”之后的下一阶段工作明确成可研究、可拆分、可持续推进的产品能力。重点不是堆功能，而是优先做能明显提升可用性、转化率和运维稳定性的能力。

## 目标

下一阶段优先回答四个问题：

1. 如何让被封锁环境下的首次接入更稳
2. 如何补齐用户侧安全和自助能力
3. 如何把邀请、支付、提现链路做成后端可配置产品
4. 如何把当前实验性的远程任务和域名检测升级成真正可用的运维能力

---

## P0: 内置抗封锁接入通道

### 为什么现在做

- [核心特性文档](./features.md) 已经把“内置代理访问”列为规划中能力
- 当前主路径仍依赖外部中转服务器、备案域名或未被封锁的海外域名
- 这是决定新用户是否能成功首次接入的关键体验

### 目标能力

- 客户端内置受控代理/bootstrap 通道
- 域名竞速与代理接入协同工作，而不是二选一
- 失败时能自动回退到直连、中转或备用配置源
- 明确风险控制：代理泄漏防护、限流、证书校验、关闭条件

### 设计边界

- 不做通用开放代理
- 不允许明文 HTTP 透传成为默认行为
- 必须和当前 `domain_service`、`remote_config`、证书逻辑兼容

### 核心代码落点

- `lib/xboard/infrastructure/network/`
- `lib/xboard/config/`
- `lib/xboard/features/domain_status/`

---

## P0: 账号安全中心与自助恢复

### 为什么现在做

- SDK 中 `changePassword` 和 `resetSecurity` 仍未实现
- 当前用户侧更多是订阅、支付、邀请能力，安全侧明显偏弱
- 这类能力对实际面板运营非常关键，能减少人工客服压力

### 目标能力

- 修改密码
- 重置安全凭据
- 明确 Token 过期后的提示和恢复路径
- 后续可扩展为设备踢下线、敏感操作确认、登录安全提醒

### 代码证据

- `lib/sdk/flutter_xboard_sdk/lib/src/adapters/xboard/xboard_user_adapter.dart`
- `lib/sdk/flutter_xboard_sdk/lib/src/core/auth/auth_interceptor.dart`
- `lib/xboard/features/profile/`
- `lib/xboard/features/auth/`

### 交付标准

- SDK API 与主应用 UI 同步落地
- 错误提示、成功提示和会话刷新逻辑闭环
- 不引入新的明文敏感信息存储

---

## P1: 动态支付与邀请结算中心

### 为什么现在做

- 提现方式当前仍是客户端硬编码
- 支付页和订单链路已经存在，但“运营策略可配置”程度还不够
- 这条线直接影响转化、复购和代理/分销体验

### 目标能力

- 从后端动态拉取提现方式、支付方式和结算规则
- 支持面板运营活动配置，而不是每次改客户端发版
- 统一支付、订单、邀请、佣金展示逻辑

### 代码证据

- `lib/xboard/features/invite/dialogs/withdraw_dialog.dart`
- `lib/xboard/features/payment/pages/plan_purchase_page.dart`
- `lib/xboard/features/payment/providers/`
- `lib/xboard/features/invite/providers/`

### 交付标准

- 前端不再硬编码提现方式列表
- 后端未返回动态配置时有稳定降级策略
- 佣金、订单、提现状态能在 UI 上形成统一闭环

---

## P1: 设备诊断与远程运维面板

### 为什么现在做

- 项目已经具备设备信息采集、远程任务、WebSocket 状态上报和域名健康检查的基础模块
- 但当前更像实验性基础设施，还不是一个可运营、可审计、可解释的用户能力

### 目标能力

- 域名健康与切换原因可视化
- 设备诊断报告导出
- 远程任务白名单化与结果回执
- 在线客服、远程诊断、订阅异常排查联动

### 代码证据

- `lib/xboard/features/remote_task/remote_task_manager.dart`
- `lib/xboard/features/remote_task/services/`
- `lib/xboard/features/domain_status/services/domain_status_service.dart`
- `lib/xboard/features/online_support/`

### 风险提醒

- 当前远程任务管理器里仍有示例级硬编码 token，进入正式产品前必须替换为真实鉴权链路
- 这条线涉及隐私、审计、权限边界，必须先做最小授权模型

---

## P2: 平台扩展与发版自动化

### 候选方向

- iOS 适配与签名链路梳理
- Linux release gate 自动化
- SDK smoke test 自动化
- 更细的 analyzer 与 generated code 漂移治理

### 为什么放在 P2

- 价值明确，但不如上面几条直接影响用户首登、账号安全和收入链路
- 更适合在当前 Linux 可交付基线稳定后并行推进

---

## 建议执行顺序

### 阶段一

1. 内置抗封锁接入通道可行性研究
2. 账号安全中心 API 与 UI 缺口补齐

### 阶段二

1. 动态支付 / 提现配置
2. 远程运维面板最小闭环

### 阶段三

1. iOS 与多平台扩展
2. 发版自动化和质量门禁

---

## Paperclip 分工建议

- `codex`
  - 做产品/架构裁剪
  - 把每条功能线收敛成明确边界、风险和验收标准
- `opencode`
  - 做技术实现 spike、接口补齐、模块重构和验证
- `clawdbot`
  - 维护 feature backlog、release impact、依赖风险和节奏巡检

路线图不是承诺全部立刻开发，而是把“下一步值得做什么”固定成持续推进的队列。
