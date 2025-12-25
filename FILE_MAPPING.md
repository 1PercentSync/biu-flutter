# biu → biu_flutter 功能对应表

> 生成时间：2025-12-25
> 基于 MIGRATION_PARITY_REPORT.md 分析和决策

---

## 1. 页面/路由对应

| 源项目路由 | 源文件 | 目标路由 | 目标文件 | 状态 |
|-----------|--------|----------|----------|------|
| `/` (热歌精选) | `pages/music-rank/index.tsx` | `/` | `features/home/presentation/screens/home_screen.dart` | ✅ 已实现 |
| `/artist-rank` | `pages/artist-rank/index.tsx` | `/artists` | `features/artist_rank/presentation/screens/artist_rank_screen.dart` | ✅ 已实现 |
| `/music-recommend` | `pages/music-recommend/index.tsx` | `/music-recommend` | `features/music_recommend/presentation/screens/music_recommend_screen.dart` | ✅ 已实现 |
| `/later` | `pages/later/index.tsx` | `/later` | `features/later/presentation/screens/later_screen.dart` | ✅ 已实现 |
| `/history` | `pages/history/index.tsx` | `/history` | `features/history/presentation/screens/history_screen.dart` | ✅ 已实现 |
| `/follow` | `pages/follow-list/index.tsx` | `/follow` | `features/follow/presentation/screens/follow_list_screen.dart` | ✅ 已实现 |
| `/collection/:id` | `pages/video-collection/index.tsx` | `/favorites/:folderId` | `features/favorites/presentation/screens/folder_detail_screen.dart` | ✅ 已实现 |
| `/user/:id` | `pages/user-profile/index.tsx` | `/user/:mid` | `features/user_profile/presentation/screens/user_profile_screen.dart` | ⚠️ 缺少动态/合集Tab |
| `/settings` | `pages/settings/index.tsx` | `/settings` | `features/settings/presentation/screens/settings_screen.dart` | ✅ 已实现 |
| `/download-list` | `pages/download-list/index.tsx` | - | - | ❌ 决策：不实现 |
| `/search` | `pages/search/index.tsx` | `/search` | `features/search/presentation/screens/search_screen.dart` | ✅ 已实现 |
| `/mini-player` | `pages/mini-player/index.tsx` | `/player` | `shared/widgets/playbar/full_player_screen.dart` | ✅ 已适配移动端 |
| `/empty` | `pages/empty/index.tsx` | - | - | ❌ 无需实现 |
| `*` (404) | `pages/not-found/index.tsx` | - | - | ⚠️ 待实现 |
| - | - | `/profile` | `features/profile/presentation/screens/profile_screen.dart` | ✅ 移动端新增 |
| - | - | `/about` | `features/settings/presentation/screens/about_screen.dart` | ⚠️ 需移除Privacy/Terms |
| - | - | `/login` | `features/auth/presentation/screens/login_screen.dart` | ✅ 移动端独立页 |
| - | - | `/favorites` | `features/favorites/presentation/screens/favorites_screen.dart` | ✅ 移动端独立页 |

---

## 2. 登录/鉴权对应

| 源功能 | 源文件 | 目标文件 | 状态 |
|--------|--------|----------|------|
| 扫码登录 | `layout/navbar/login/qrcode-login.tsx` | `features/auth/presentation/widgets/qr_login_widget.dart` | ✅ 已实现 |
| 密码登录 | `layout/navbar/login/password-login.tsx` | `features/auth/presentation/widgets/password_login_widget.dart` | ⚠️ 找回密码需修复 |
| 短信登录 | `layout/navbar/login/code-login.tsx` | `features/auth/presentation/widgets/sms_login_widget.dart` | ✅ 已实现 |
| 极验验证 | `common/utils/geetest.ts` | `features/auth/presentation/widgets/geetest_dialog.dart` | ✅ 已实现 |
| 登录入口 | `layout/navbar/login/index.tsx` | `features/auth/presentation/screens/login_screen.dart` | ✅ 已实现 |
| Gaia风控 | `service/request/response-interceptors.ts` | `core/network/interceptors/gaia_vgate_interceptor.dart` | ✅ 已实现 |

### 2.1 登录拦截策略差异（决策：保持现状）

| 项目 | 策略 | 说明 |
|------|------|------|
| 源项目 | API返回-101时页面内提示 | 用户可选择是否登录 |
| 目标项目 | AuthGuard路由级拦截 | 自动跳转登录页，带redirect参数返回原页 |

---

## 3. 播放器对应

| 源功能 | 源文件 | 目标文件 | 状态 |
|--------|--------|----------|------|
| 播放队列/模式 | `store/play-list.ts` | `features/player/presentation/providers/playlist_notifier.dart` | ✅ 已实现 |
| 播放器UI | `layout/playbar/index.tsx` | `shared/widgets/playbar/mini_playbar.dart` | ✅ 已实现 |
| 全屏播放器 | `layout/playbar/center/index.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ 已实现 |
| 播放模式切换 | `layout/playbar/right/play-mode.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ 已实现 |
| 倍速控制 | `layout/playbar/right/rate.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ 已实现 |
| 音量控制 | `layout/playbar/right/volume.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ 已实现 |
| 波形可视化 | `components/audio-waveform/index.tsx` | `shared/widgets/audio_visualizer.dart` | ✅ 已实现 |
| 多P列表 | `layout/playbar/left/video-page-list/index.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ 已实现 |
| 后台播放(Electron) | `electron/main.ts` | `features/player/services/audio_service_init.dart` | ✅ 已用audio_service替代 |

---

## 4. 收藏夹/合集对应

| 源功能 | 源文件 | 目标文件 | 状态 |
|--------|--------|----------|------|
| 收藏夹列表 | `layout/side/collection/index.tsx` | `features/favorites/presentation/screens/favorites_screen.dart` | ✅ 已实现 |
| 收藏夹详情 | `pages/video-collection/favorites.tsx` | `features/favorites/presentation/screens/folder_detail_screen.dart` | ✅ 已实现 |
| 视频合集详情 | `pages/video-collection/video-series.tsx` | - | ❌ 待实现 |
| 收藏夹选择 | `components/favorites-edit-modal/index.tsx` | `features/favorites/presentation/widgets/folder_select_sheet.dart` | ✅ 已实现 |
| 创建/编辑收藏夹 | `components/favorites-edit-modal/index.tsx` | `features/favorites/presentation/widgets/folder_select_sheet.dart` | ✅ 已实现 |

---

## 5. 通用组件对应

| 源组件 | 源文件 | 目标组件 | 目标文件 | 状态 |
|--------|--------|----------|----------|------|
| MVAction菜单 | `components/mv-action/index.tsx` | - | - | ⚠️ 部分实现（收藏/下一首播放） |
| 搜索框 | `layout/navbar/search/index.tsx` | - | `features/search/presentation/screens/search_screen.dart` | ✅ 已集成到搜索页 |
| 搜索历史 | `store/search-history.ts` | - | `features/search/presentation/widgets/search_history_widget.dart` | ✅ 已实现 |
| 视频卡片 | `components/mv-card/index.tsx` | VideoCard | `shared/widgets/video_card.dart` | ✅ 已实现 |
| 用户卡片 | `pages/follow-list/user-card.tsx` | FollowingCard | `features/follow/presentation/widgets/following_card.dart` | ✅ 已实现 |
| 滚动容器 | `components/scroll-container/index.tsx` | - | Flutter原生 | ✅ 无需对应 |
| 确认对话框 | - | ConfirmDialog | `shared/widgets/confirm_dialog.dart` | ✅ 已实现 |

---

## 6. 设置项对应

| 源设置项 | 类型 | 目标设置项 | 状态 | 说明 |
|----------|------|------------|------|------|
| `audioQuality` | 通用 | `audioQuality` | ✅ 已实现 | |
| `displayMode` | 通用 | `displayMode` | ✅ 已实现 | |
| `backgroundColor` | 通用 | `backgroundColor` | ✅ 已实现 | |
| `contentBackgroundColor` | 通用 | `contentBackgroundColor` | ✅ 已实现 | |
| `primaryColor` | 通用 | `primaryColor` | ✅ 已实现 | |
| `borderRadius` | 通用 | `borderRadius` | ✅ 已实现 | |
| `hiddenMenuKeys` | 通用 | `hiddenFolderIds` | ⚠️ 部分实现 | 目标仅支持隐藏文件夹 |
| `autoStart` | 桌面 | - | ❌ 不实现 | 桌面专属 |
| `closeWindowOption` | 桌面 | - | ❌ 不实现 | 桌面专属 |
| `fontFamily` | 桌面 | - | ❌ 不实现 | 桌面专属 |
| `downloadPath` | 桌面 | - | ❌ 不实现 | 桌面专属 |
| `ffmpegPath` | 桌面 | - | ❌ 不实现 | 桌面专属 |

---

## 7. API服务对应

| 源Service | 源文件 | 目标Datasource | 目标文件 | 状态 |
|-----------|--------|----------------|----------|------|
| 登录相关 | `service/passport-*` | AuthRemoteDatasource | `features/auth/data/datasources/auth_remote_datasource.dart` | ✅ 已实现 |
| 视频信息 | `service/web-interface-view.ts` | VideoRemoteDataSource | `features/video/data/datasources/video_remote_datasource.dart` | ✅ 已实现 |
| 音频信息 | `service/audio-music-info.ts` | AudioRemoteDataSource | `features/audio/data/datasources/audio_remote_datasource.dart` | ✅ 已实现 |
| 搜索 | `service/web-interface-wbi-search.ts` | SearchRemoteDatasource | `features/search/data/datasources/search_remote_datasource.dart` | ✅ 已实现 |
| 收藏夹 | `service/fav-folder-*.ts` | FavoritesRemoteDatasource | `features/favorites/data/datasources/favorites_remote_datasource.dart` | ✅ 已实现 |
| 历史记录 | `service/web-interface-history-cursor.ts` | HistoryRemoteDataSource | `features/history/data/datasources/history_remote_datasource.dart` | ✅ 已实现 |
| 稍后再看 | `service/web-interface-history-toview.ts` | LaterRemoteDataSource | `features/later/data/datasources/later_remote_datasource.dart` | ✅ 已实现 |
| 用户空间 | `service/space-acc-info.ts` | UserProfileRemoteDatasource | `features/user_profile/data/datasources/user_profile_remote_datasource.dart` | ✅ 已实现 |
| 关注列表 | `service/relation-followings.ts` | FollowRemoteDatasource | `features/follow/data/datasources/follow_remote_datasource.dart` | ✅ 已实现 |
| 热歌榜 | `service/web-interface-popular-precious.ts` | MusicRankRemoteDataSource | `features/music_rank/data/datasources/music_rank_remote_datasource.dart` | ✅ 已实现 |
| 歌手榜 | `service/audio-rank.ts` | ArtistRankRemoteDatasource | `features/artist_rank/data/datasources/artist_rank_remote_datasource.dart` | ✅ 已实现 |
| 推荐音乐 | `service/music-recommend.ts` | MusicRecommendRemoteDatasource | `features/music_recommend/data/datasources/music_recommend_remote_datasource.dart` | ✅ 已实现 |
| Gaia风控 | `service/gaia-vgate.ts` | AuthRemoteDatasource | `features/auth/data/datasources/auth_remote_datasource.dart` | ✅ 已实现 |

### 7.1 源项目未使用的Service（无需实现）

以下Service在源项目中存在代码但未被引用，目标项目无需实现：

- `audio-rank.ts` - 未在任何页面/组件中使用
- `fav-resource-batch-del.ts` / `fav-resource-clean.ts` / `fav-resource-copy.ts` / `fav-resource-move.ts`
- `history-toview-clear.ts`
- `polymer-seasons-archives-list.ts`
- `web-interface-ranking.ts`
- `space-masterpiece.ts` / `space-navnum.ts` / `space-top-arc.ts`
- `web-bili-ticket.ts` / `web-buvid.ts`
- `web-interface-archive-desc.ts` / `web-interface-search-all.ts` / `web-interface-view-detail.ts`

**注意：** 以下Service在报告中被误标为未使用，实际上已被使用：
- `gaia-vgate-register.ts` / `gaia-vgate-validate.ts` - 在`response-interceptors.ts`中动态导入
- `user-video-archives-list.ts` - 在`video-series.tsx`中使用

---

## 8. 桌面专属功能（决策：不实现）

| 功能 | 源位置 | 移动端替代 | 状态 |
|------|--------|------------|------|
| 下载系统 | `electron/ipc/download/*` | - | ❌ 决策不实现 |
| 托盘/Tray | `electron/main.ts` | - | ❌ 桌面专属 |
| 关闭隐藏/退出 | `electron/main.ts` | - | ❌ 桌面专属 |
| 单例锁 | `electron/main.ts` | - | ❌ 桌面专属 |
| 全局快捷键 | `electron/shortcut.ts` | - | ❌ 桌面专属 |
| mini窗口 | `pages/mini-player/*` | 全屏播放器 | ✅ 已替代 |
| 自动更新 | `electron/main.ts` | App Store更新 | ✅ 平台机制 |
| 字体枚举 | `electron/ipc/channel.ts` | - | ❌ 桌面专属 |
| 后台播放 | `electron/main.ts` | audio_service | ✅ 已实现 |
| 分享 | - | share_plus | ✅ 已实现 |

---

## 9. 待处理问题清单

### 9.1 需要补齐的功能

| 问题ID | 描述 | 涉及文件 | 优先级 |
|--------|------|----------|--------|
| 3.1.C | 用户主页缺少动态Tab | `user_profile_screen.dart` | 高 |
| 3.1.C | 用户主页缺少合集Tab | `user_profile_screen.dart` | 高 |
| 3.1.D | 搜索用户点击进入用户页 | `search_screen.dart:654` | 高 |
| 3.1.D | 歌手榜点击进入用户页 | `artist_rank_screen.dart:107` | 高 |
| 3.3.B | 找回密码应打开浏览器 | `password_login_widget.dart` | 中 |

### 9.2 需要移除的功能

| 问题ID | 描述 | 涉及文件 | 优先级 |
|--------|------|----------|--------|
| 3.1.A | Downloads入口 | `profile_screen.dart:153-157` | 中 |
| 3.2.A | Hot Searches功能 | `search_screen.dart:662`, `search_remote_datasource.dart:201` | 中 |
| 3.2.B | Privacy Policy / Terms | `about_screen.dart:127-150` | 低 |
| 3.2.C | videoDetail/audioDetail路由常量 | `routes.dart:42-45,54-57` | 低 |

### 9.3 需要重构的模块边界问题

| 问题ID | 描述 | 涉及文件 | 建议 |
|--------|------|----------|------|
| 5.2.A | core依赖feature | `gaia_vgate_interceptor.dart:7-8` | 将验证逻辑暴露为接口 |
| 5.2.B | shared依赖feature | `full_player_screen.dart:6` | 将folder_select_sheet移到shared或解耦 |

---

## 10. 无问题项确认

| 问题ID | 描述 | 结论 |
|--------|------|------|
| 6.1 | switch语句编译问题 | ✅ 无问题（Dart 3+ pattern matching语法） |

---

## 11. 架构层对应

```
源项目 (React/Electron)          目标项目 (Flutter)
========================         ========================
src/pages/*                  →   lib/features/*/presentation/screens/*
src/components/*             →   lib/shared/widgets/* + lib/features/*/presentation/widgets/*
src/store/*                  →   lib/features/*/presentation/providers/*
src/service/*                →   lib/features/*/data/datasources/*
src/common/utils/*           →   lib/core/utils/*
src/common/constants/*       →   lib/core/constants/*
electron/ipc/*               →   (移动端不需要/audio_service替代)
shared/settings/*            →   lib/features/settings/domain/entities/*
```

---

## 更新历史

- 2025-12-25: 初始版本，基于MIGRATION_PARITY_REPORT.md分析
