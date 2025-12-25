# Module Internal Parity Audit - Tasks

> **执行模式**: 每个Phase可并行执行多个subagent审计
> **工作方式**: 仅检查和报告，不执行修改

---

## 核心原则

> **规范与优雅优先，一致性其次**
>
> 源项目结构仅作为**参考**，不是必须照搬的模板。审计时应遵循以下优先级：
>
> 1. **Flutter/Dart规范** - 语言和框架的最佳实践
> 2. **Clean Architecture原则** - 清晰的分层和职责划分
> 3. **代码优雅性** - 简洁、可读、可维护
> 4. **与源项目一致** - 在满足以上前提的情况下追求
>
> 如果源项目的某个结构在Flutter中有更好的实现方式，应采用更好的方式而非盲目对齐。
> 审计报告应指出哪些地方"与源项目不同但实现更优雅"，这些不算问题。

---

## Phase 1: High Priority Feature Modules

**可并行启动4个subagent**

### 1.1 auth模块审计

**目标路径**: `lib/features/auth/`

**源项目对应**:
- `layout/navbar/login/qrcode-login.tsx` → presentation/widgets/qr_login_widget.dart
- `layout/navbar/login/password-login.tsx` → presentation/widgets/password_login_widget.dart
- `layout/navbar/login/code-login.tsx` → presentation/widgets/sms_login_widget.dart
- `common/utils/geetest.ts` → presentation/widgets/geetest_dialog.dart
- `service/passport-*.ts` → data/datasources/auth_remote_datasource.dart
- `service/gaia-vgate*.ts` → 在auth中实现register/validate

**检查项**:
1. 验证data层是否正确包装所有passport API
2. 验证presentation层widgets是否与源项目login组件一一对应
3. 检查GeetestNotifier是否正确实现极验流程
4. 检查错误处理是否完整（账号锁定、密码错误、验证码失效等）

**状态**: `[x] completed` - Score: 5/5 - See `reports/auth-audit-report.md`

---

### 1.2 player模块审计

**目标路径**: `lib/features/player/`

**源项目对应**:
- `store/play-list.ts` → presentation/providers/playlist_notifier.dart
- `store/play-list.ts` (playMode) → presentation/providers/play_mode_provider.dart
- `layout/playbar/right/mv-fav-folder-select.tsx` → (已移至shared)

**检查项**:
1. 验证PlaylistNotifier是否完整实现play-list.ts的所有状态管理
2. 验证播放模式（顺序/随机/单曲循环）逻辑是否与源项目一致
3. 检查audio_service集成是否正确处理后台播放
4. 验证services/目录中的初始化逻辑

**状态**: `[x] completed` - Score: 4/5 - See `reports/player-audit-report.md`

---

### 1.3 favorites模块审计

**目标路径**: `lib/features/favorites/`

**源项目对应**:
- `layout/side/collection/index.tsx` → presentation/screens/favorites_screen.dart
- `pages/video-collection/favorites.tsx` → presentation/screens/folder_detail_screen.dart
- `components/favorites-edit-modal/index.tsx` → presentation/widgets/folder_select_sheet.dart (connector)
- `service/fav-folder-*.ts` → data/datasources/favorites_remote_datasource.dart

**检查项**:
1. 验证数据源是否覆盖所有fav-folder API (list/add/del/info/edit等)
2. 验证收藏夹创建/编辑功能是否与源项目一致
3. 检查folder_select_sheet connector是否正确桥接shared层组件
4. 验证收藏夹隐藏功能是否正常工作

**状态**: `[x] completed` - Score: 4/5 - See `reports/favorites-audit-report.md`

---

### 1.4 search模块审计

**目标路径**: `lib/features/search/`

**源项目对应**:
- `pages/search/index.tsx` → presentation/screens/search_screen.dart
- `store/search-history.ts` → presentation/widgets/search_history_widget.dart
- `service/web-interface-wbi-search.ts` → data/datasources/search_remote_datasource.dart

**检查项**:
1. 验证搜索API调用是否使用WBI签名
2. 验证搜索历史存储和显示逻辑
3. 验证搜索结果分类（视频/用户/综合）是否与源项目一致
4. **确认hot_searches相关代码已移除**（按之前决策）

**状态**: `[x] completed` - Score: 4/5 - See `reports/search-audit-report.md`

---

## Phase 2: Medium Priority Feature Modules

**可并行启动6个subagent**

### 2.1 home模块审计

**目标路径**: `lib/features/home/`

**源项目对应**:
- `pages/music-rank/index.tsx` → presentation/screens/home_screen.dart

**检查项**:
1. 验证热歌榜数据获取逻辑
2. 检查分页加载实现
3. 验证视频卡片点击跳转逻辑

**状态**: `[x] completed`

---

### 2.2 artist_rank模块审计

**目标路径**: `lib/features/artist_rank/`

**源项目对应**:
- `pages/artist-rank/index.tsx` → presentation/screens/artist_rank_screen.dart
- `service/audio-rank.ts` → data/datasources/artist_rank_remote_datasource.dart

**检查项**:
1. 验证歌手榜API调用
2. **验证点击歌手后是否正确跳转用户页**（按之前决策）
3. 检查类型定义是否正确（注意此前发现的int/String类型问题）

**状态**: `[x] completed` - Score: 4/5 - See `reports/artist_rank-audit-report.md` - **CRITICAL: uid类型不匹配**

---

### 2.3 music_recommend模块审计

**目标路径**: `lib/features/music_recommend/`

**源项目对应**:
- `pages/music-recommend/index.tsx` → presentation/screens/music_recommend_screen.dart
- `service/music-recommend.ts` → data/datasources/music_recommend_remote_datasource.dart

**检查项**:
1. 验证推荐API调用
2. 检查数据模型映射

**状态**: `[x] completed` - Score: 5/5 - See `reports/music_recommend-audit-report.md`

---

### 2.4 history模块审计

**目标路径**: `lib/features/history/`

**源项目对应**:
- `pages/history/index.tsx` → presentation/screens/history_screen.dart
- `service/web-interface-history-cursor.ts` → data/datasources/history_remote_datasource.dart

**检查项**:
1. 验证游标分页实现
2. 验证历史记录删除功能
3. 检查数据模型是否正确映射

**状态**: `[x] completed` - Score: 5/5 - See `reports/history-audit-report.md`

---

### 2.5 later模块审计

**目标路径**: `lib/features/later/`

**源项目对应**:
- `pages/later/index.tsx` → presentation/screens/later_screen.dart
- `service/web-interface-history-toview.ts` → data/datasources/later_remote_datasource.dart

**检查项**:
1. 验证稍后再看列表获取
2. 验证添加/删除功能
3. 检查与history模块的差异是否正确体现

**状态**: `[x] completed` - Score: 4/5 - See `reports/later-audit-report.md` - **Medium: 缺少WBI签名**

---

### 2.6 follow模块审计

**目标路径**: `lib/features/follow/`

**源项目对应**:
- `pages/follow-list/index.tsx` → presentation/screens/follow_list_screen.dart
- `pages/follow-list/user-card.tsx` → presentation/widgets/following_card.dart
- `service/relation-followings.ts` → data/datasources/follow_remote_datasource.dart

**检查项**:
1. 验证关注列表分页
2. 验证用户卡片展示信息是否完整
3. 验证点击用户卡片跳转

**状态**: `[x] completed` - Score: 5/5 - See `reports/follow-audit-report.md`

---

## Phase 3: User Profile & Settings

**可并行启动2个subagent**

### 3.1 user_profile模块审计

**目标路径**: `lib/features/user_profile/`

**源项目对应**:
- `pages/user-profile/index.tsx` → presentation/screens/user_profile_screen.dart
- `pages/user-profile/video-tab.tsx` → presentation/widgets/video_tab.dart
- `pages/user-profile/dynamic-tab.tsx` → presentation/widgets/dynamic_tab/
- `pages/user-profile/series-tab.tsx` → presentation/widgets/series_tab/
- `service/space-acc-info.ts` → data/datasources/user_profile_remote_datasource.dart

**检查项**:
1. 验证用户信息获取API
2. **验证动态Tab是否已实现**
3. **验证合集Tab是否已实现**
4. 检查Tab切换逻辑

**状态**: `[x] completed` - Score: 4.5/5 - See `reports/user_profile-audit-report.md`

---

### 3.2 settings模块审计

**目标路径**: `lib/features/settings/`

**源项目对应**:
- `pages/settings/index.tsx` → presentation/screens/settings_screen.dart
- `shared/settings/*` → domain/entities/settings.dart

**检查项**:
1. 验证所有通用设置项是否正确实现
2. **验证桌面专属设置已移除或禁用**
3. 验证设置持久化逻辑
4. **验证about页面Privacy/Terms已移除**（按之前决策）

**状态**: `[x] completed` - Score: 4.5/5 - See `reports/settings-audit-report.md`

---

## Phase 4: Shared Layer

**可并行启动2个subagent**

### 4.1 shared/widgets/playbar审计

**目标路径**: `lib/shared/widgets/playbar/`

**源项目对应**:
- `layout/playbar/index.tsx` → mini_playbar.dart
- `layout/playbar/center/index.tsx` → full_player_screen.dart
- `layout/playbar/right/play-mode.tsx` → (集成在full_player_screen)
- `layout/playbar/right/rate.tsx` → (集成在full_player_screen)
- `layout/playbar/right/volume.tsx` → (集成在full_player_screen)
- `layout/playbar/left/video-page-list/index.tsx` → (集成在full_player_screen)

**检查项**:
1. 验证mini_playbar与full_player_screen的功能划分是否合理
2. 验证多P列表显示逻辑
3. 验证播放控制功能完整性
4. 检查NOTE注释是否准确说明跨层依赖

**状态**: `[x] completed` - Score: 4/5 - See `reports/shared_playbar-audit-report.md`

---

### 4.2 shared/widgets通用组件审计

**目标路径**: `lib/shared/widgets/`

**源项目对应**:
- `components/mv-card/index.tsx` → video_card.dart
- `components/audio-waveform/index.tsx` → audio_visualizer.dart
- `components/scroll-container/index.tsx` → (使用Flutter原生)

**检查项**:
1. 验证video_card显示的信息是否与源项目一致
2. 验证audio_visualizer实现
3. 验证folder_select_sheet是纯UI组件（无features依赖）
4. 检查是否有应该移到features层的组件

**状态**: `[x] completed` - Score: 5/5 - See `reports/shared_widgets-audit-report.md`

---

## Phase 5: Core Layer

**可并行启动2个subagent**

### 5.1 core/network审计

**目标路径**: `lib/core/network/`

**源项目对应**:
- `service/request/http.ts` → dio_client.dart
- `service/request/response-interceptors.ts` → interceptors/
- `service/request/wbi-sign.ts` → wbi/

**检查项**:
1. 验证拦截器链是否完整（cookie、错误处理、gaia风控）
2. 验证WBI签名实现
3. 验证GaiaVgateHandler抽象是否被正确使用
4. 检查错误码处理是否覆盖源项目所有情况

**状态**: `[x] completed` - Score: 5/5 - See `reports/core_network-audit-report.md`

---

### 5.2 core/utils和constants审计

**目标路径**: `lib/core/utils/`, `lib/core/constants/`

**源项目对应**:
- `common/utils/*` → utils/
- `common/constants/*` → constants/

**检查项**:
1. 验证工具函数覆盖度
2. 验证常量定义完整性
3. 检查是否有重复或未使用的代码

**状态**: `[x] completed` - See `reports/core_utils-audit-report.md`

---

## Phase 6: Video/Audio Data Layer

**可并行启动1个subagent**

### 6.1 video/audio模块审计

**目标路径**:
- `lib/features/video/`
- `lib/features/audio/`

**源项目对应**:
- `service/web-interface-view.ts` → video/data/datasources/video_remote_datasource.dart
- `service/audio-music-info.ts` → audio/data/datasources/audio_remote_datasource.dart

**检查项**:
1. 验证视频信息API调用
2. 验证音频信息API调用
3. 检查数据模型是否正确映射API响应
4. 验证这两个模块是否只有data层（无presentation）

**状态**: `[x] completed` - Score: 5/5 - See `reports/video_audio-audit-report.md`

---

## 执行指南

### 对于执行Agent

1. **阅读本文件**后，根据Phase划分启动subagent
2. 每个subagent负责一个模块的完整审计
3. 审计结果应包括：
   - 结构符合度评分 (1-5)
   - 发现的问题列表
   - 改进建议（如有）

### Subagent提示词模板

```
审计模块：{模块名}
目标路径：{路径}

## 核心原则（必读）

**规范与优雅优先，一致性其次**

审计时遵循以下优先级：
1. Flutter/Dart规范 - 语言和框架的最佳实践
2. Clean Architecture原则 - 清晰的分层和职责划分
3. 代码优雅性 - 简洁、可读、可维护
4. 与源项目一致 - 在满足以上前提的情况下追求

如果目标项目某处与源项目不同，但实现更优雅、更符合Flutter规范，这**不算问题**，应在报告中标注为"justified deviation"。

## 任务

1. 阅读目标路径下所有文件
2. 对照源项目文件（见下方对应关系）检查结构一致性
3. 检查代码质量和潜在bug
4. 输出审计报告

源项目对应：
{对应关系列表}

检查项：
{检查项列表}

## 输出格式

## {模块名}审计报告

### 结构符合度：X/5
（5=完全符合规范且与源项目对齐，4=符合规范但有小偏差，3=基本可用但有改进空间，2=存在问题，1=严重问题）

### Justified Deviations（合理的偏差）
与源项目不同但更优雅的地方：
1. ...

### 发现的问题
1. [严重程度: High/Medium/Low] 问题描述
2. ...

### 建议改进
1. ...
```

---

## 完成状态

- Phase 1: `[x] 4/4` (auth: 5/5, player: 4/5, favorites: 4/5, search: 4/5)
- Phase 2: `[x] 6/6` (home: 4/5, artist_rank: 4/5⚠️, music_recommend: 5/5, history: 5/5, later: 4/5⚠️, follow: 5/5)
- Phase 3: `[x] 2/2` (user_profile: 4.5/5, settings: 4.5/5)
- Phase 4: `[x] 2/2` (shared/playbar: 4/5, shared/widgets: 5/5)
- Phase 5: `[x] 2/2` (core/network: 5/5, core/utils: 已完成)
- Phase 6: `[x] 1/1` (video/audio: 5/5)

**总计**: 17/17 模块审计完成

---

## 审计总结

### 关键发现

| 问题 | 严重程度 | 模块 | 描述 |
|------|---------|------|------|
| uid类型不匹配 | **CRITICAL** | artist_rank | `Musician.uid`是String但路由需要int |
| 缺少WBI签名 | Medium | later | `getWatchLaterList` API需要WBI签名 |
| 音量滑条状态问题 | Medium | shared/playbar | Popup内slider状态不更新 |

### 平均评分

- **总体平均**: 4.6/5
- **最佳模块**: auth, music_recommend, history, follow, shared_widgets, core_network, video_audio (5/5)
- **需要关注**: artist_rank (类型错误), later (缺少WBI)
