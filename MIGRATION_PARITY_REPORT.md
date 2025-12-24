# biu → biu_flutter 功能一致性/模块边界检查报告（代码存在即算功能）

生成时间：2025-12-24  
范围：`./biu`（Electron + React + TypeScript）→ `./biu_flutter`（Flutter）  
口径：**代码内存在即算功能**（即：即便未接入 UI/路由，只要代码中定义了能力/入口，也纳入一致性对齐范围）  
目标：目标项目功能需对齐源项目；目标项目不应新增源项目没有的功能（移动端 UI 适配除外）；若移动端无法实现/无意义/经讨论可舍弃，需要明确记录。

---

## 0. 方法与证据口径

本报告通过静态阅读代码得到，覆盖点：

- 源项目路由与页面入口：`biu/src/routes.tsx:1`、`biu/src/pages/*`
- 源项目“全局能力/动作入口”：
  - Renderer → Electron API 调用点：`rg "window.electron."`（例如 `biu/src/app.tsx:38`）
  - Electron IPC 能力总表：`biu/electron/ipc/channel.ts:1` + 对应 handlers（如 `biu/electron/ipc/download/*`）
  - 核心 store：`biu/src/store/*`（如播放器 `biu/src/store/play-list.ts:18`）
- 目标项目路由与页面入口：`biu_flutter/lib/core/router/app_router.dart:1`、`biu_flutter/lib/core/router/routes.dart:1`
- 目标项目 feature 清单：`biu_flutter/lib/features/*`
- 目标项目 TODO/Unimplemented：`rg "TODO|UnimplementedError|NotImplemented"`（例如 `biu_flutter/lib/core/storage/storage_service.dart:8`）

注意：该方法不运行项目，不验证运行时行为；但在“代码存在即算功能”的约束下，已覆盖全部可枚举入口与能力定义。

---

## 1. 源项目（biu）功能清单（代码存在即算功能）

### 1.1 路由/页面（React Router）
来源：`biu/src/routes.tsx:1`

- `/` 热歌精选（`MusicRank`）
- `/artist-rank` 音乐大咖
- `/music-recommend` 推荐音乐
- `/later` 稍后再看
- `/history` 历史记录
- `/follow` 我的关注
- `/collection/:id` 收藏夹/合集详情（同一路由承载多种类型，见 `biu/src/pages/video-collection/index.tsx:4`）
- `/user/:id` 用户主页（多 Tab，见 `biu/src/pages/user-profile/index.tsx:96`）
- `/settings` 设置
- `/download-list` 下载记录
- `/search` 搜索
- `/mini-player` mini 播放窗口页
- `/empty` 空页面
- `*` 404

### 1.2 默认侧边菜单项（可隐藏）
来源：`biu/src/common/constants/menus.tsx:1`

- 热歌精选 `/`
- 音乐大咖 `/artist-rank`
- 推荐音乐 `/music-recommend`
- 我的关注 `/follow`（需登录）
- 稍后再看 `/later`（需登录）
- 历史记录 `/history`（需登录）
- 下载记录 `/download-list`

菜单隐藏策略（含文件夹菜单隐藏）：
- 默认菜单隐藏：`biu/src/layout/side/default-menu/index.tsx:1`、配置项 `hiddenMenuKeys`（`biu/shared/settings/app-settings.ts:1`）
- 文件夹菜单隐藏 + 新建收藏夹入口：`biu/src/layout/side/collection/index.tsx:1`

### 1.3 搜索（含：搜索历史 + 搜索建议）
- 搜索页（视频/用户 + “仅音乐”开关）：`biu/src/pages/search/index.tsx:1`
- 顶栏搜索框（含搜索建议 + 搜索历史管理）：`biu/src/layout/navbar/search/index.tsx:1`
- 搜索历史持久化 store：`biu/src/store/search-history.ts:1`

### 1.4 登录（扫码/密码/短信）+ 极验
- 登录入口（扫码 + Tabs）：`biu/src/layout/navbar/login/index.tsx:1`
- 扫码登录：`biu/src/layout/navbar/login/qrcode-login.tsx:1`
- 密码登录（RSA 加密 + 极验 + 找回密码 openExternal）：`biu/src/layout/navbar/login/password-login.tsx:1`
- 短信登录（国家区号 + 极验 + 倒计时）：`biu/src/layout/navbar/login/code-login.tsx:1`

### 1.5 播放器（核心能力）
核心 store：`biu/src/store/play-list.ts:18`

- 播放/暂停、上一首/下一首
- 播放模式（顺序/循环/单曲/随机）
- 倍速（0.5x–2.0x）
- 音量/静音
- 播放队列/“下一首播放”（nextId）
- 多 P（分页）播放队列注入与管理（依赖 `getWebInterfaceView`）
- 媒体会话/播放状态同步（含 Electron IPC `updatePlaybackState` 调用：`biu/src/store/play-list.ts:206`）

播放器 UI（playbar）：
- 结构：`biu/src/layout/playbar/index.tsx:1`
- 多 P 列表：`biu/src/layout/playbar/left/video-page-list/index.tsx:1`
- 播放模式/倍速/音量：`biu/src/layout/playbar/right/play-mode.tsx:1`、`biu/src/layout/playbar/right/rate.tsx:1`、`biu/src/layout/playbar/right/volume.tsx:1`
- 波形可视化（可切换）：`biu/src/components/audio-waveform/index.tsx:1`

### 1.6 通用媒体动作菜单（MVAction：页面/卡片共用）
来源：`biu/src/components/mv-action/index.tsx:1`

- 下一首播放：`key: "nextPlay"`（`biu/src/components/mv-action/index.tsx:89`）
- 收藏（弹出收藏夹选择）：`key: "collect"`（`biu/src/components/mv-action/index.tsx:106`）
- 添加到稍后再看：`key: "addToLater"`（`biu/src/components/mv-action/index.tsx:119`）
- 下载（音乐/音频/视频）：`key: "downloadAudio"`/`"downloadVideo"`（`biu/src/components/mv-action/index.tsx:126`）

### 1.7 收藏夹/合集（创建/编辑/删除/收藏/取消收藏/资源管理）
- 文件夹菜单（我创建/我收藏）：`biu/src/layout/side/collection/index.tsx:1`
- 合集页（根据 query param `type` 切换 Favorite/VideoSeries）：`biu/src/pages/video-collection/index.tsx:4`
- 收藏夹详情：`biu/src/pages/video-collection/favorites.tsx:1`
- 视频合集详情/系列：`biu/src/pages/video-collection/video-series.tsx:1`

### 1.8 历史/稍后再看/关注/用户主页（关键差异点）
- 历史：`biu/src/pages/history/index.tsx:1`（仅支持 archive 类型播放）
- 稍后再看：`biu/src/pages/later/index.tsx:1`（含删除确认）
- 关注：`biu/src/pages/follow-list/index.tsx:1`、用户卡片 `biu/src/pages/follow-list/user-card.tsx:1`
- 用户主页 Tabs：动态/投稿/收藏/合集（`biu/src/pages/user-profile/index.tsx:96`）

### 1.9 下载系统（桌面强相关）
- 下载列表页：`biu/src/pages/download-list/index.tsx:1`
- 下载入口（playbar 下载按钮）：`biu/src/layout/playbar/right/download.tsx:1`
- Electron 下载队列与 ffmpeg 合并/转码：
  - IPC channel：`biu/electron/ipc/channel.ts:21`
  - 队列：`biu/electron/ipc/download/download-queue.ts:14`
  - ffmpeg：`biu/electron/ipc/download/ffmpeg-processor.ts:33`

### 1.10 设置（字段对齐基准）
源设置字段（默认值）：`biu/shared/settings/app-settings.ts:1`

- `autoStart`（开机自启，桌面）
- `closeWindowOption`（关闭隐藏/退出，桌面）
- `fontFamily`（字体选择，桌面依赖枚举字体）
- `downloadPath`（下载目录，桌面）
- `ffmpegPath`（ffmpeg 路径，桌面）
- `audioQuality`
- `displayMode`
- `hiddenMenuKeys`（菜单/文件夹隐藏）
- `backgroundColor`/`contentBackgroundColor`/`primaryColor`/`borderRadius`

设置页结构：
- Tabs：系统/菜单/快捷键：`biu/src/pages/settings/index.tsx:1`
- 系统设置：`biu/src/pages/settings/system-settings.tsx:1`
- 菜单设置（隐藏默认菜单 + 文件夹菜单）：`biu/src/pages/settings/menu-settings.tsx:1`
- 快捷键设置：`biu/src/pages/settings/shortcut-settings.tsx:1`
- 导入导出：`biu/src/pages/settings/export-import.tsx:1`

快捷键默认配置（桌面）：`biu/shared/settings/shortcut-settings.ts:1`

### 1.11 Electron IPC 能力总表（代码存在即算功能）
IPC channel 定义：`biu/electron/ipc/channel.ts:1`

- `store`：get/set/clear（settings 与通用 store）
- `dialog`：选目录、选文件、打开目录、showFileInFolder、openExternal
- `font`：获取系统字体列表
- `file`：获取文件大小
- `download`：下载队列全生命周期（list/add/pause/resume/retry/cancel/clear/sync）
- `router`：navigate（主进程驱动 renderer 路由跳转）
- `http`：get/post（主进程代理请求）
- `player`：state/prev/next/toggle（主进程控制播放）
- `shortcut`：register/unregister/registerAll/unregisterAll + triggered 广播
- `app`：版本/更新检查/下载更新/quitAndInstall/更新消息等
- `cookie`：get/set（CSRF、gaia vtoken 等）
- `window`：toggleMini/minimize/maximize/fullscreen/isMaximized/isFullScreen/close 等

桌面行为（托盘/单例/关闭隐藏/mini 窗口/全局快捷键/自动更新等）集中在：`biu/electron/main.ts:1`

---

## 2. 目标项目（biu_flutter）功能清单（代码存在即算功能）

### 2.1 路由/页面
路由实现：`biu_flutter/lib/core/router/app_router.dart:1`  
路由常量：`biu_flutter/lib/core/router/routes.dart:1`

已接入页面路由：
- `/` Home（Hot Songs）
- `/search`
- `/favorites`
- `/history`
- `/profile`
- `/login`
- `/settings`
- `/about`
- `/artists`
- `/music-recommend`
- `/follow`
- `/user/:mid`
- `/later`
- `/favorites/:folderId`
- `/player`

仅“常量存在”但未接入实现的路由（也算功能入口）：
- `/video/:bvid`、`/audio/:sid`（`biu_flutter/lib/core/router/routes.dart:42`）

### 2.2 登录/鉴权
- 登录页（三 Tab：扫码/密码/短信）：`biu_flutter/lib/features/auth/presentation/screens/login_screen.dart:1`
- 密码登录：`biu_flutter/lib/features/auth/presentation/widgets/password_login_widget.dart:1`
- 短信登录：`biu_flutter/lib/features/auth/presentation/widgets/sms_login_widget.dart:1`
- 扫码登录：`biu_flutter/lib/features/auth/presentation/widgets/qr_login_widget.dart:1`
- 极验弹窗：`biu_flutter/lib/features/auth/presentation/widgets/geetest_dialog.dart:1`
- AuthGuard（路由级强制跳登录）：`biu_flutter/lib/core/router/auth_guard.dart:1`

### 2.3 播放器
- 播放队列/播放模式/倍速/音量/持久化：`biu_flutter/lib/features/player/presentation/providers/playlist_notifier.dart:1`
- mini playbar：`biu_flutter/lib/shared/widgets/playbar/mini_playbar.dart:1`
- full player（含：模式、倍速、音量、多 P 列表、播放列表、收藏夹选择）：`biu_flutter/lib/shared/widgets/playbar/full_player_screen.dart:1`
- 音频后台服务初始化（audio_service）：`biu_flutter/lib/features/player/services/audio_service_init.dart:1`

### 2.4 收藏夹/关注/历史/稍后再看/搜索/用户主页
- 收藏夹列表/详情/批量操作：`biu_flutter/lib/features/favorites/presentation/screens/favorites_screen.dart:1`、`biu_flutter/lib/features/favorites/presentation/screens/folder_detail_screen.dart:1`
- 关注：`biu_flutter/lib/features/follow/presentation/screens/follow_list_screen.dart:1`
- 历史：`biu_flutter/lib/features/history/presentation/screens/history_screen.dart:1`
- 稍后再看（含删除）：`biu_flutter/lib/features/later/presentation/screens/later_screen.dart:1`
- 搜索（视频/用户 + 搜索历史 + **Hot Searches**）：`biu_flutter/lib/features/search/presentation/screens/search_screen.dart:1`
- 用户主页（当前仅 Videos + Favorites 两个 Tab）：`biu_flutter/lib/features/user_profile/presentation/screens/user_profile_screen.dart:1`

### 2.5 设置
- 设置页（音质/外观/隐藏文件夹/导入导出/关于入口）：`biu_flutter/lib/features/settings/presentation/screens/settings_screen.dart:1`
- 设置字段（仅音质/颜色/圆角/显示模式/hiddenFolderIds）：`biu_flutter/lib/features/settings/domain/entities/app_settings.dart:1`
- 导入导出实现：`biu_flutter/lib/features/settings/presentation/providers/settings_notifier.dart:1`
- About（含 Licenses/Privacy/Terms）：`biu_flutter/lib/features/settings/presentation/screens/about_screen.dart:1`

---

## 3. 功能对齐结论（必须修复/必须讨论/可接受差异）

### 3.1 明确一致性违规：源项目有，目标项目缺失（必须补齐或明确舍弃）

#### A. 下载系统整体缺失（源=完整功能；目标=仅占位入口）
- 源：下载页 `biu/src/pages/download-list/index.tsx:1`；IPC `biu/electron/ipc/channel.ts:21`；队列 `biu/electron/ipc/download/download-queue.ts:14`；ffmpeg `biu/electron/ipc/download/ffmpeg-processor.ts:33`
- 目标：仅 Profile 里有 “Downloads” 入口且 TODO（`biu_flutter/lib/features/profile/presentation/screens/profile_screen.dart:153`）

#### B. 设置字段未对齐（按“代码存在即算功能”口径）
源 `AppSettings` 字段：`biu/shared/settings/app-settings.ts:1`  
目标 `AppSettings` 字段：`biu_flutter/lib/features/settings/domain/entities/app_settings.dart:57`

目标缺失源字段：
- `autoStart`（桌面，需讨论是否移动端舍弃）
- `closeWindowOption`（桌面，需讨论）
- `fontFamily`（源有 UI + IPC 支持，目标缺失）
- `downloadPath`（源与下载系统强相关，目标缺失）
- `ffmpegPath`（源与下载系统强相关，目标缺失）
- `hiddenMenuKeys`（源可隐藏默认菜单 + 文件夹菜单；目标仅有 hiddenFolderIds）

#### C. 用户主页功能不齐：缺少 dynamic / video-series（合集）
- 源 Tabs：`biu/src/pages/user-profile/index.tsx:96`
- 目标 Tabs：`biu_flutter/lib/features/user_profile/presentation/screens/user_profile_screen.dart:82`

#### D. “点用户进入用户页”在部分入口未完成
- 源：搜索用户点击 `navigate(/user/:mid)`（`biu/src/pages/search/user-list.tsx:25`），歌手榜点击用户（`biu/src/pages/artist-rank/index.tsx:62`）
- 目标：仍是 TODO（`biu_flutter/lib/features/search/presentation/screens/search_screen.dart:654`，`biu_flutter/lib/features/artist_rank/presentation/screens/artist_rank_screen.dart:107`）

#### E. 快捷键系统缺失（源存在 UI + 默认配置 + Electron 支持）
- 源：`biu/shared/settings/shortcut-settings.ts:1`、`biu/src/pages/settings/shortcut-settings.tsx:1`、`biu/electron/shortcut.ts:1`
- 目标：无对应 feature/UI（移动端是否可实现需要讨论；但“代码存在即算功能”→ 默认属于缺失）

### 3.2 明确一致性违规：目标项目新增了源项目没有的功能（必须移除或经讨论认可）

#### A. Hot Searches（热搜）——源项目不存在
- 目标 UI：`biu_flutter/lib/features/search/presentation/screens/search_screen.dart:678`
- 目标 API：`biu_flutter/lib/features/search/data/datasources/search_remote_datasource.dart:201`
- 源项目全库未发现对应功能/UI/接口调用（`rg` 未命中 “search/square|热搜|Hot Searches”）

#### B. About 页的 Privacy Policy / Terms / Licenses ——源项目不存在
- 目标：`biu_flutter/lib/features/settings/presentation/screens/about_screen.dart:106`
- 源：全库未发现对应功能/UI（`rg` 未命中）

#### C. `/video/:bvid` 与 `/audio/:sid` 路由常量（代码存在即算功能）
- 目标常量：`biu_flutter/lib/core/router/routes.dart:42`
- 源路由：`biu/src/routes.tsx:1` 无对应

### 3.3 行为不一致（需要记录并后续对齐）

#### A. 登录拦截策略：Flutter 路由级强制跳转 vs 源项目页面内提示
- 目标：`biu_flutter/lib/core/router/auth_guard.dart:1`
- 源：例如 history 页面通过接口返回 -101 再提示（`biu/src/pages/history/index.tsx:25`）

#### B. 找回密码行为：源直接打开浏览器；目标仅弹框提示
- 源：`biu/src/layout/navbar/login/password-login.tsx:176`
- 目标：`biu_flutter/lib/features/auth/presentation/widgets/password_login_widget.dart:150`

---

## 4. “中间地带”讨论清单（需与你确认是否舍弃/替代）

这些功能源项目代码中存在，但移动端可能“无法实现/无意义/需替代方案”。在未达成一致前，按规则都应视为“缺失待对齐”。

### 4.1 桌面强相关能力（来自 Electron IPC 与 main 进程）
能力总表：`biu/electron/ipc/channel.ts:1`，桌面行为：`biu/electron/main.ts:1`

- 托盘（Tray）、关闭隐藏/退出、单例锁、Windows thumbar
- 全局快捷键（globalShortcut）
- mini-player 独立窗口 + toggleMini
- 自动更新（check/download/quitAndInstall）+ 发布说明 UI
- “主进程代理 http get/post”、cookie get/set
- 字体枚举（font-list）与字体选择

建议讨论方向：
- 移动端可用替代：后台播放通知栏控制（已用 `audio_service`）、系统分享（已用 `share_plus`）等
- 明确哪些桌面能力“移动端永久舍弃”，哪些需要“移动端对应实现”

### 4.2 源项目 service 中“代码存在但未被引用”的能力
说明：在“代码存在即算功能”口径下，这些会成为对齐负担；但它们可能是死代码/预留能力，应先讨论是否从源项目移除或明确不对齐。

未被 `@/service/*` 引用到的 service 文件（baseName）包括：
- `audio-rank`
- `fav-resource-batch-del`、`fav-resource-clean`、`fav-resource-copy`、`fav-resource-infos`、`fav-resource-move`、`fav-resource-utils`
- `fav-video-favoured`
- `gaia-vgate-register`、`gaia-vgate-validate`
- `history-toview-clear`
- `member-web-account`
- `polymer-seasons-archives-list`
- `space-masterpiece`、`space-navnum`、`space-top-arc`
- `web-bili-ticket`、`web-buvid`
- `web-interface-archive-desc`、`web-interface-ranking`、`web-interface-search-all`、`web-interface-view-detail`

（来源：对 `biu/src/service/*.ts` 与 `@/service/*` 引用差集的静态扫描）

---

## 5. 模块边界一致性检查（含目标项目问题记录）

### 5.1 合法映射（非多对多）
- 源 `biu/src/pages/*` ↔ 目标 `biu_flutter/lib/features/*/presentation/*`：整体是一对一/一对多映射
- 源 `biu/src/store/*` ↔ 目标 Riverpod providers：多对一/一对一均可接受
- 源 `biu/src/service/*` ↔ 目标各 feature 的 remote datasource：可接受（但需注意“service 未用但存在”的对齐压力）

### 5.2 目标项目边界问题（需记录，后续重构时处理）

#### A. `core` 反向依赖 `feature`（甚至依赖 UI）
- `GaiaVgateInterceptor` 位于 core/network，但 import 了 auth 的 datasource 与 geetest dialog：
  - `biu_flutter/lib/core/network/interceptors/gaia_vgate_interceptor.dart:7`
- 这会让 core 层变成“需要知道 feature 与 UI”，边界不清晰。

#### B. `shared` 反向依赖 `feature`
- full player（shared）直接 import favorites 的 UI（folder_select_sheet）：
  - `biu_flutter/lib/shared/widgets/playbar/full_player_screen.dart:6`
- shared 应尽量保持“无 feature 依赖”，否则会形成网状依赖。

---

## 6. 目标项目自身问题（发现即记录，不在本任务中修复）

### 6.1 可能导致编译失败的代码
- Dart `switch` 未 `break/return`（疑似非法贯穿）：`biu_flutter/lib/core/router/app_router.dart:262`

### 6.2 明确 TODO 未完成（即：功能缺失/入口未闭合）
- 搜索用户点击进入用户页：`biu_flutter/lib/features/search/presentation/screens/search_screen.dart:654`
- 歌手榜点击进入用户页：`biu_flutter/lib/features/artist_rank/presentation/screens/artist_rank_screen.dart:107`
- Profile → Downloads：`biu_flutter/lib/features/profile/presentation/screens/profile_screen.dart:154`

### 6.3 路由常量定义但未接入
- `videoDetail`/`audioDetail` 常量存在但未在 router 中实现：`biu_flutter/lib/core/router/routes.dart:42`

---

## 7. 下一步建议（不实现，只用于任务拆分）

为达成“biu_flutter 功能对齐 biu”，建议按优先级拆分：

1) 明确“移动端可舍弃清单”（桌面专有：下载/托盘/全局快捷键/mini 窗口/自更新等）  
2) 对齐用户可见核心链路缺口（用户页入口、用户主页 tabs、通用媒体动作菜单覆盖）  
3) 删除目标项目新增功能（Hot Searches、About 的 Privacy/Terms/Licenses、未接入的 detail 路由常量）或将其改造为源项目等价物  
4) 处理目标项目边界问题（core/shared 反向依赖 feature）以便后续扩展不演化成多对多依赖网

