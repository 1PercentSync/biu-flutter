# Change: Maintain Flutter-Electron Consistency

## Why This Change Matters

### Background
biu-flutter 是从 biu (Electron) 迁移而来的项目。迁移不是一次性的，而是需要持续维护的：
- 源项目会继续更新
- Flutter 项目需要跟进这些变化
- 两个项目必须保持一致性，否则功能行为会出现偏差

### Problem
没有系统的一致性维护机制会导致：
1. **漂移** - Flutter 实现逐渐偏离源行为（如 `formatCompact` 用 "K" 而非万）
2. **重复** - 相同逻辑在多处实现（如 `_formatCount` 在 4 个文件中重复）
3. **遗漏** - 源功能没有迁移（如 `biliDio` 缺失）
4. **不可追溯** - 不知道 Flutter 代码对应源代码哪里

---

## Core Principles

### 1. 文件 1:1 对应（除非有合理理由）

**为什么**：1:1 对应使维护变得简单。当源文件变化时，可以直接找到对应的目标文件更新。

**合理的偏离理由**：
- **Dart 语言惯例**：`time.ts` → `datetime_extensions.dart` + `duration_extensions.dart`（Dart extension 按类型分离）
- **Clean Architecture**：多个 `service/fav-*.ts` → 一个 `favorites_remote_datasource.dart`（数据源聚合）
- **平台差异**：`mini-player.ts` 无对应（桌面特有功能）

**不合理的偏离**：
- `number.ts` → `number_utils.dart` + `format_utils.dart`（无理由拆分，已修复）

### 2. FILE_MAPPING.md 是真相来源

**为什么**：需要一个权威文档来追踪映射关系。没有它，一致性检查就是随机的、不完整的。

**规则**：
- 任何文件结构变更 → 必须更新 FILE_MAPPING.md
- 验证一致性 → 对照 FILE_MAPPING.md 逐条检查
- INCONSISTENCIES.md 记录问题 → FILE_MAPPING.md 记录状态

### 3. 源引用精确到函数/类名

**为什么**：只写文件名不够，因为一个文件可能有多个函数。精确到函数名才能在源文件变化时快速定位。

**格式**：`Source: biu/src/path/to/file.ts#functionName`

### 4. 优先级：层级 > 边界 > 行为 > 文档

**为什么**：
- 层级错误 → 整个架构混乱
- 边界错误 → 功能分散/重复
- 行为错误 → 用户体验不一致
- 文档缺失 → 维护困难但不影响功能

---

## Lessons Learned (避免重复犯错)

### 错误 1: 修改文件结构后没有更新 FILE_MAPPING.md
- **场景**：删除了 `format_utils.dart`，但 FILE_MAPPING.md 仍显示它存在
- **根因**：没有意识到 FILE_MAPPING.md 是真相来源
- **教训**：**任何文件增删改 → 第一时间更新 FILE_MAPPING.md**

### 错误 2: 源引用只写文件名，没有写函数名
- **场景**：`Source: biu/src/service/response-interceptors.ts` 缺少 `#geetestInterceptors`
- **根因**：执行时疏忽，没有坚持格式要求
- **教训**：**源引用必须是 `file.ts#functionName` 格式，缺函数名视为不完整**

### 错误 3: 发现重复代码只记录不修复
- **场景**：`_formatCount` 在 4 个文件重复定义，只记录在 INCONSISTENCIES.md
- **根因**：把"记录问题"当成了完成任务，实际上应该立即修复
- **教训**：**文件内部的不优雅实现应该立即修复，不是搁置**

### 错误 4: 计划侧重文档，忽视层级和边界
- **场景**：大量时间添加文档注释，但忽略了检查层级对应和功能边界
- **根因**：没有正确理解优先级
- **教训**：**先验证层级和边界正确，再添加文档**

### 错误 5: 计划只写"怎么做"，不写"为什么"
- **场景**：proposal.md 列出了步骤，但没解释为什么这样做
- **根因**：急于执行，没有充分思考
- **教训**：**每个决策都要有理由，否则无法判断是否正确执行**

---

## Verification Process

对每个模块，按以下顺序执行：

### Step 1: 层级验证（最重要）
对照 FILE_MAPPING.md 检查：
- [ ] 所有源文件都有目标映射？
- [ ] 1:1 对应或有合理偏离理由？
- [ ] 没有未记录的目标文件？

### Step 2: 边界验证
- [ ] Flutter feature 模块包含了源项目的所有相关功能？
- [ ] 没有功能被错误地放在其他模块？

### Step 3: 行为验证
- [ ] 读取源文件，理解实现
- [ ] 对比目标文件，检查逻辑是否一致
- [ ] 发现差异 → 立即修复

### Step 4: 代码质量
- [ ] 检查重复代码 → 提取到共享 utility
- [ ] 检查不优雅实现 → 立即重构（文件内部）

### Step 5: 文档和记录
- [ ] 添加源引用（`file.ts#functionName` 格式）
- [ ] 更新 FILE_MAPPING.md（如有变更）
- [ ] 更新 INCONSISTENCIES.md（记录发现和修复）

---

## Already Fixed (Core Layer)

| File | Issue | Why It's Wrong | Fix |
|------|-------|----------------|-----|
| `number_utils.dart` | 1000-9999 用 "K" | 源用 zh-CN Intl，只在 ≥10000 时用万 | 改为匹配源行为 |
| `format_utils.dart` | 与 number_utils 重复 | 违反 1:1 原则，无合理理由拆分 | 删除，更新 FILE_MAPPING.md |
| `url_utils.dart` | 缺少 pageIndex | 源的 getBiliVideoLink 支持分P | 添加可选参数 |
| `dio_client.dart` | 缺少 biliDio | 源有 biliRequest (www.bilibili.com) | 添加 biliDio getter |
| 4 个 UI 文件 | `_formatCount` 重复 | 应使用共享 utility | 改用 `NumberUtils.formatCompact` |

## Already Fixed (Feature Modules)

| File | Issue | Why It's Wrong | Fix |
|------|-------|----------------|-----|
| `playlist_notifier.dart` | `addToNext` 只设 nextId 不移动位置 | 源会移动已存在的项到当前项后面 | 添加移动逻辑，匹配源行为 |
| `later_remote_datasource.dart` | `add/remove` 缺少 `useCSRF: true` | 源使用 `useCSRF: true` | 添加 CSRF 选项 |

---

## Progress

### Core Layer ✅ Completed
- [x] `core/constants/` - 源引用已添加
- [x] `core/utils/` - 删除重复，修复行为，源引用已添加
- [x] `core/extensions/` - 源引用已添加
- [x] `core/network/` - 添加缺失的 biliDio，源引用已添加
- [x] `core/router/` - 源引用已添加
- [x] `core/storage/` - 源引用已添加

### Feature Modules ✅ Completed
- [x] `features/auth/` - 源引用已添加，行为一致
- [x] `features/favorites/` - 源引用已添加，行为一致
- [x] `features/player/` - 源引用已添加，**修复 addToNext 行为不一致**
- [x] `features/search/` - 源引用已添加，行为一致
- [x] `features/history/` - 源引用已添加，行为一致
- [x] `features/later/` - 源引用已添加，行为一致
- [x] `features/user_profile/` - 源引用已添加，行为一致
- [x] `features/follow/` - 源引用已添加，行为一致
- [x] `features/video/` - 行为一致（WBI 签名正确使用）
- [x] `shared/widgets/playbar/` - 源引用已添加

---

## Success Criteria

1. **FILE_MAPPING.md 与实际状态一致** - 没有过时的映射
2. **所有公共 API 有源引用** - 格式 `file.ts#functionName`
3. **没有无理由的 1:N 或 N:1 映射** - 每个偏离都有文档说明
4. **没有重复代码** - 共享逻辑在 core/utils 或 shared/
5. **行为与源一致** - 所有差异已修复或有意为之（记录原因）

---

## Lessons Learned

### 问题：陷入只更新文档而忽略实际验证

**根本原因**：
1. Todo 太粗粒度 - 只记录"验证 X 模块"，没有分解为具体检查点
2. 源引用添加是"可见的进度"，让人有完成感，但没有实际验证行为
3. 没有强制读取源文件和目标文件进行对比

**改进后的验证流程**：

### 新的 Todo 结构

每个模块必须拆分为以下检查点：

```
[ ] {module}: Layer - DataSource 聚合是否有合理理由？
[ ] {module}: Boundary - 源项目的所有功能是否都覆盖？
[ ] {module}: Behavior - 关键方法的参数/选项是否匹配？
    - [ ] 方法1: 参数 X, 选项 Y (useCSRF/useWbi)
    - [ ] 方法2: 参数 X, 选项 Y
[ ] {module}: Quality - 重复代码？不优雅实现？
```

### 强制检查清单

**对于每个 DataSource 方法**，必须验证：

1. **API 路径** - 与源项目一致
2. **请求方法** - GET/POST 一致
3. **参数名称** - 字段名一致（如 `rid` vs `resourceId`）
4. **请求选项** - useCSRF、useWbi、useFormData 与源一致
5. **错误处理** - 错误码覆盖完整

### 本次发现的实际问题

| 类型 | 问题 | 如果继续只写文档的后果 |
|------|------|------------------------|
| 行为 | `later` 缺少 `useCSRF` | API 调用永远失败 (-111) |
| 行为 | `addToNext` 不移动位置 | 用户体验不一致 |
| 边界 | 缺少国家列表 API | 非中国用户无法 SMS 登录 |
| 边界 | 缺少 article/photo/live 搜索 | 功能简化（可接受） |
