# Xboard-Mihomo 长期维护通道

本文件用于把 Xboard-Mihomo 的日常维护、发版巡检、依赖观察和后续积压收敛成一个固定节奏，避免“这一版修好了，下一版又忘了怎么验”。

## 维护目标

长期维护通道需要稳定产出四类结果：

1. **每个交付批次的 release note / change summary**
2. **依赖 watchlist**，重点盯 Flutter、Linux 桌面打包链路与 SDK 子模块分支
3. **每周一次 Git / release hygiene sweep**
4. **后续 backlog 收口**，把非阻塞事项持续整理成明确的后续工作

---

## 固定节奏

### 每周例行巡检

在主仓库根目录执行：

```bash
git fetch --all --prune
git status --short --branch
git submodule status
flutter analyze lib tool
dart setup.dart linux --arch amd64 --out core
```

巡检时同时检查：

- `main` 是否和 `origin/main` 保持一致，是否出现额外漂移分支
- `lib/sdk/flutter_xboard_sdk` 是否仍停在 `theLucius7/flutter_xboard_sdk` 的 `xboard-mihomo-compat` 维护线上
- `core/Clash.Meta`、`plugins/flutter_distributor`、SDK 子模块是否出现意外漂移
- `flutter analyze lib tool` 是否新增项目自有告警
- `dart setup.dart linux --arch amd64 --out core` 是否仍能产出 Linux 所需核心产物

### 发布候选批次（RC）前

```bash
flutter build linux --release
```

发布前必须确认 Linux bundle 中仍然包含：

- `Flclash`
- `FlClashCore`
- `assets/config/xboard.config.example.yaml`

如果任一项缺失，先修复构建或打包链路，再谈发版。

### SDK 变更节奏

SDK 改动先落在：

- 仓库：`theLucius7/flutter_xboard_sdk`
- 分支：`xboard-mihomo-compat`

只有在应用侧验证通过后，才更新主仓库中的子模块指针。不要把“SDK 仍在试验中”的提交直接混进主仓库交付批次。

---

## Release Note 模板

每次交付至少覆盖下面四段信息：

### 1. 批次摘要

- 这一批主要修了什么
- 对用户可见的变化是什么
- 是否包含配置、SDK、构建链路或打包行为变化

### 2. 变更来源

建议从以下范围整理：

```bash
git log --oneline --decorate <last_tag>..HEAD
git diff --stat <last_tag>..HEAD
git submodule status
```

如果没有 tag，可以直接从上一个稳定交付 commit 起算。

### 3. 风险备注

重点说明是否触及：

- Linux 托盘 / `tray_manager` 兼容性
- 首次启动配置资产加载
- 证书校验与证书资源存在性
- SDK 子模块指针更新
- 生成代码、分析器或第三方插件带来的额外告警

### 4. 验证结果

最少给出：

- `flutter analyze lib tool`
- `dart setup.dart linux --arch amd64 --out core`
- `flutter build linux --release`（发布批次时）

---

## Dependency Watchlist

### 高优先级观察项

#### Flutter / Dart

- Flutter 版本升级是否带来 Linux embedder、打包或 analyzer 行为变化
- 代码生成产物是否因为 SDK / generator 升级出现漂移

#### Linux 桌面打包链路

- `tray_manager` 及其相关桌面头文件兼容性
- `flutter_distributor` 输出的 Linux 产物结构是否变化
- AppImage / deb / rpm 产物命名与 bundle 内容是否仍然符合当前发布预期

#### SDK 子模块

- `lib/sdk/flutter_xboard_sdk` 是否仍保持在 `xboard-mihomo-compat`
- SDK 是否新增需要主仓库同步的初始化、模型或 API 变更

#### 配置与安全

- `assets/config/xboard.config.example.yaml` 是否仍被正确打包
- 证书锁定逻辑是否只在证书资源存在时启用
- fresh clone 下配置回退链路是否仍完整

### 中优先级观察项

- `core/Clash.Meta` 子模块是否需要跟进安全或协议修复
- `plugins/flutter_distributor` 是否有上游 breaking change
- analyzer 对 generated Clash 文件或第三方插件树的告警是否向主项目扩散

---

## Weekly Hygiene Checklist

每周跑一次，完成后把结果写入 issue comment 或维护日志：

- [ ] `git fetch --all --prune`
- [ ] `git status --short --branch`
- [ ] `git submodule status`
- [ ] `flutter analyze lib tool`
- [ ] `dart setup.dart linux --arch amd64 --out core`
- [ ] 检查是否需要补 release note / change summary
- [ ] 检查 follow-up backlog 是否需要拆成新 issue

---

## 当前 Follow-up Backlog

这些项暂时不阻塞当前交付，但应持续排队：

1. 清理项目自有文件中的非阻塞 analyzer warnings
2. 把启动链路中的调试 `print` 替换为结构化日志
3. 为 Linux 构建和 SDK smoke check 增加 CI 或脚本化 release gates

如果其中任何一项开始影响交付稳定性，就把它从“后续”升级为正式 issue。
