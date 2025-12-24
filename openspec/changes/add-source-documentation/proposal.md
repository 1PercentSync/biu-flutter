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

### 1. 一致性 ≠ 死板照搬

**关键理解**：一致性维护的目标是**行为一致**，不是代码复制。

**允许不一致的情况**：
- **Dart/Flutter 惯例**：使用 extension 而非 utility function、使用 Riverpod 而非 Zustand
- **移动端适配**：底部导航替代侧边栏、下拉刷新替代按钮刷新、触摸友好的 UI
- **Clean Architecture**：多个 service 聚合为一个 DataSource
- **平台限制**：桌面特有功能（FFmpeg、系统托盘）无需迁移

**不允许不一致的情况**：
- 无合理理由的功能缺失（如缺少国家列表 API）
- 请求选项遗漏（如缺少 useCSRF）
- 行为逻辑错误（如 addToNext 不移动项目）
- **用户可感知的功能缺失**（如搜索高亮、点击跳转）

**⚠️ 警告："移动端简化"不是功能缺失的借口**

判断是否为"合理的移动端适配"：
- ✅ **布局适配**：侧边栏 → 底部导航（屏幕尺寸限制）
- ✅ **交互适配**：hover → tap/long-press（触摸设备限制）
- ✅ **平台限制**：FFmpeg、系统托盘（移动端无此能力）
- ❌ **功能删减**：搜索高亮、点击跳转（移动端完全可以实现）
- ❌ **实现偷懒**：用 stripHtml 代替富文本渲染（只是更复杂，不是不可能）

**关键问题**：问自己"其他移动端 App（网易云、QQ音乐）有这个功能吗？"如果有，那就不是"移动端限制"，而是**功能缺失**。

### 2. 文件 1:1 对应（有合理理由可偏离）

**为什么**：1:1 对应使维护变得简单。当源文件变化时，可以直接找到对应的目标文件更新。

**合理的偏离理由**：
- **Dart 语言惯例**：`time.ts` → `datetime_extensions.dart` + `duration_extensions.dart`（Dart extension 按类型分离）
- **Clean Architecture**：多个 `service/fav-*.ts` → 一个 `favorites_remote_datasource.dart`（数据源聚合）
- **平台差异**：`mini-player.ts` 无对应（桌面特有功能）

**不合理的偏离**：
- `number.ts` → `number_utils.dart` + `format_utils.dart`（无理由拆分，已修复）

### 3. FILE_MAPPING.md 是真相来源

**为什么**：需要一个权威文档来追踪映射关系。没有它，一致性检查就是随机的、不完整的。

**规则**：
- 任何文件结构变更 → 必须更新 FILE_MAPPING.md
- 验证一致性 → 对照 FILE_MAPPING.md 逐条检查
- INCONSISTENCIES.md 记录问题 → FILE_MAPPING.md 记录状态

### 4. 源引用精确到函数/类名

**为什么**：只写文件名不够，因为一个文件可能有多个函数。精确到函数名才能在源文件变化时快速定位。

**格式**：`Source: biu/src/path/to/file.ts#functionName`

### 5. 优先级：层级 > 边界 > 行为 > 文档

**为什么**：
- 层级错误 → 整个架构混乱
- 边界错误 → 功能分散/重复
- 行为错误 → 用户体验不一致
- 文档缺失 → 维护困难但不影响功能

### 6. 发现问题就修复，必要时重写

**为什么**：维护一致性有时需要重写代码，不是小修小补。如果现有实现根本不对，就重写。

**但是**：重写应该谨慎，确保理解源实现后再动手。

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

### 错误 6: 将功能缺失错误归类为"移动端简化"
- **场景**：搜索高亮和点击作者名跳转被标记为"移动端简化（可接受）"
- **根因**：
  1. 没有从用户角度思考，只考虑实现难度
  2. 错误地将"未实现"归类为"有意简化"
  3. 没有参考其他移动端 App（网易云、QQ音乐都有这些功能）
- **教训**：
  - **"移动端简化"必须是真正的平台限制或布局适配，不是功能删减**
  - **判断标准：其他移动端 App 有这个功能吗？如果有，就不是"移动端限制"**
  - **发现功能差异时，默认应该修复，除非有明确的平台限制理由**

### 错误 7: 询问用户是否应该修复（甩锅行为）
- **场景**：发现功能缺失后，询问用户"这超出了一致性检查的范围，进入了功能实现。需要你决定是否修复"
- **根因**：
  1. 把"发现问题"和"修复问题"人为分离
  2. 试图限制自己的工作范围以避免责任
  3. 没有理解 Core Principle #6："发现问题就修复"
- **教训**：
  - **发现问题 = 修复问题，这是同一个任务，不可分割**
  - **不要询问用户是否应该修复，直接修复**
  - **"一致性检查"包含修复发现的问题，不只是记录问题**
  - **唯一应该询问的是：多个可行方案时让用户选择，不是"要不要做"**

### 错误 8: 发现问题后标记为"可后续添加"
- **场景**：导入/导出功能被标记为"可后续添加，非核心功能"
- **根因**：
  1. 试图减少工作量
  2. 用"非核心功能"作为借口
  3. 没有用判断标准验证（其他移动端 App 有这个功能吗？有！）
- **教训**：
  - **"可后续添加"本质上就是"不想做"，违反"发现问题就修复"原则**
  - **判断是否需要修复时，必须用客观标准（其他 App 有吗？），不能主观判断"核心不核心"**
  - **如果当前无法修复（例如需要额外依赖），应该立即添加依赖并修复，而不是搁置**

### 错误 9: 用各种标签掩盖功能缺失
- **场景**：Shared Components 检查中，多个缺失组件被标记为：
  - "🔵 Flutter native" - `confirm-modal` 标记为 "AlertDialog is sufficient"
  - "⚠️ Future enhancement" - `audio-waveform` 标记为 "needs deps"
  - "➖ Not needed" - `search-filter` 标记为 "Not currently used"
- **根因**：
  1. 本质是错误 6、7、8 的变体和组合
  2. 用看起来合理的标签（Flutter native、技术限制）掩盖偷懒
  3. 没有深入检查实际使用情况
  4. 没有验证"Flutter native"是否真的满足需求
- **实际情况**：
  - `confirm-modal`：AlertDialog 不提供异步 loading 状态 → 需要实现 `ConfirmDialog`
  - `audio-waveform`：网易云、QQ音乐都有可视化 → 需要实现 `AudioVisualizer`（就算 just_audio 不支持 FFT，也要用模拟动画）
  - `search-filter`：folder_detail_screen 已有搜索+排序功能 → 不是"Not used"，是"已内联实现"
- **教训**：
  - **"Flutter native"不是万能借口** - 必须验证原生方案是否真的满足源功能的所有需求
  - **"技术限制"需要验证** - 如果有替代方案（如模拟动画），就不是真正的限制
  - **"Not used"需要搜索验证** - 功能可能内联在其他文件中
  - **每个"非实现"标签都需要具体理由**，不能只写一个标签就结束

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
| `auth_remote_datasource.dart` | 缺少国家列表 API | 源有动态国家列表 | 添加 `getCountryList` + model + UI |

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
- [x] `features/settings/` - 源引用已添加，**修复音质枚举值不一致、添加圆角和背景色设置 UI**
- [x] `shared/widgets/playbar/` - 源引用已添加

### Shared Widgets ✅ Completed
- [x] `shared/widgets/empty_state.dart` - 源引用已添加，修复默认文本（"暂无内容"）
- [x] `shared/widgets/error_state.dart` - 源引用已添加（移动端适配版）
- [x] `shared/widgets/cached_image.dart` - 源引用已添加，使用 UrlUtils.formatProtocol
- [x] `shared/widgets/track_list_item.dart` - 源引用已添加，使用 NumberUtils.formatCompact
- [x] `shared/widgets/video_card.dart` - 源引用已添加（移动端适配版）
- [x] `shared/widgets/async_value_widget.dart` - Flutter-only 标记已添加
- [x] `shared/widgets/loading_state.dart` - Flutter-only 标记已添加，**新增 VideoCardSkeleton**
- [x] `shared/widgets/confirm_dialog.dart` - **新增**，支持异步 loading 和类型区分
- [x] `shared/widgets/audio_visualizer.dart` - **新增**，模拟频率条动画（just_audio 无 FFT）
- [x] `shared/widgets/highlighted_text.dart` - 源引用已添加，搜索高亮支持

### Video/Download + Layout/Routing ✅ Completed
- [x] Video API 评估完成 - view-detail/archive-desc/ranking 不需要（音乐播放器不需要视频详情页）
- [x] Download 模块评估完成 - 桌面专属（需要 Electron IPC + FFmpeg）
- [x] Layout 差异评估完成 - 合理的移动端适配（侧边栏→底部导航）
- [x] 菜单功能覆盖验证完成 - 所有功能可通过路由访问
- [x] `features/music_recommend/` - **新增**，实现缺失的推荐音乐功能

### User Profile/Follow + Remaining Features ✅ Completed
- [x] User Profile 模块评估完成 - space-setting 已实现，其他功能评估为不需要（B站特有）
- [x] User Favorites Tab - **新增** `user_favorites_tab.dart`，用户收藏夹网格
- [x] Volume Slider - **新增** `_buildVolumeControl` 垂直滑块弹出菜单
- [x] Quick Favorite - **新增** `_showFavoriteSheet` 一键收藏按钮
- [x] Video Page List UI - **新增** `_VideoPageListSheet` 多P视频切换
- [x] 动态功能评估为不需要（源码只过滤视频动态，与投稿列表重叠）
- [x] 代表作/置顶视频/合集功能评估为不需要（B站特有，网易云/QQ音乐都没有）

### Final Consistency Audit + Gaia VGate ✅ Completed
- [x] Gaia VGate 风控验证 - **新增** `GaiaVgateInterceptor` + `gaia_vgate_response.dart`
  - `registerGaiaVgate` 和 `validateGaiaVgate` API 方法
  - 全局 Context 持有器用于拦截器显示对话框
  - 自动检测 `v_voucher` 响应并触发验证流程
- [x] `audio-song-info.ts` 评估为不需要 - 音频信息来自收藏夹 API
- [x] `audio-rank.ts` 评估为不需要 - 源项目中的死代码
- [x] 常量模块最终评估 - video/collection/feed/vip 评估为不需要
- [x] 工具模块最终评估 - json/fav 已有替代方案
- [x] FILE_MAPPING.md 所有 ❌ Missing 项已解决（实现或评估为不需要）
- [x] flutter analyze 通过

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
| 边界 | 缺少国家列表 API | 非中国用户无法选择地区 (**已修复**) |
| 边界 | 缺少 article/photo/live 搜索 | 功能简化（可接受，音乐播放器不需要） |

### Settings 模块发现的功能差异

| 组件 | 源功能 | Flutter 实现 | 评估 |
|------|--------|-------------|------|
| `AudioQualitySetting` | `auto/lossless/high/medium/low` | 原为 `auto/low/standard/high/hires` | **已修复** |
| `settings_screen.dart` | 圆角设置 (0-24px slider) | 原无设置 UI | **已添加** |
| `settings_screen.dart` | 背景色设置 (backgroundColor + contentBackgroundColor) | 原无设置 UI | **已添加** |
| `settings_notifier.dart` | 导入/导出配置 | 原无实现 | **已添加** |
| `menu-settings.tsx` | 系统菜单 + 收藏夹隐藏 | 仅收藏夹隐藏 | 移动端简化（可接受，无侧边栏） |

### Shared Widgets 发现的功能差异

| 组件 | 源功能 | Flutter 实现 | 评估 |
|------|--------|-------------|------|
| `VideoCard` / `TrackListItem` | `isTitleIncludeHtmlTag` 支持搜索高亮 | `HighlightedText` widget | **已修复** |
| `TrackListItem` / `VideoCard` | `ownerMid` 点击跳转用户主页 | `onArtistTap` / `onOwnerTap` 回调 | **已修复** |
| `cached_image.dart` | 内联 `_formatUrl` | 改用 `UrlUtils.formatProtocol` | **已修复** |
| `track_list_item.dart` | 内联 `_formatPlayCount` | 改用 `NumberUtils.formatCompact` | **已修复** |
| `empty_state.dart` | 默认文本 "暂无内容" | 原为 "No content" | **已修复** |
| `confirm-modal` | 异步确认 + loading 状态 | 原用原生 AlertDialog | **已修复** - 新增 `ConfirmDialog` |
| `audio-waveform` | Web Audio API FFT 可视化 | 原无实现 | **已修复** - 新增 `AudioVisualizer`（模拟动画） |
| `image-card/skeleton.tsx` | 卡片骨架屏 | 原只有列表骨架 | **已修复** - 新增 `VideoCardSkeleton` |
| `search-filter` | 搜索框 + 排序选择器 | folder_detail 内联实现 | **已确认** - 功能存在 |

> **经验教训**：之前将搜索高亮和点击跳转标记为"移动端简化（可接受）"是错误的判断。
> 这些是用户可感知的功能缺失，必须修复。参见 [错误 6](#错误-6-将功能缺失错误归类为移动端简化) 和 [错误 7](#错误-7-询问用户是否应该修复甩锅行为)。
>
> **新增教训**：用"Flutter native"、"Future enhancement"等标签掩盖功能缺失是错误 9。
> 每个"非实现"标签都需要验证，不能只写一个标签就结束。
