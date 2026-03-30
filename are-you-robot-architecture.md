# are-you-robot 项目架构书

## 1. 文档目标

本文档面向开发人员，描述 `are-you-robot` 的技术架构、内容分发方式、数据结构、页面组织、题库工作流、缓存策略以及后续平台化扩展方向。

这份文档默认服务于两个目标：

- 保证用户安装后可以立刻游玩
- 保证题库能够以低成本、可审核、可扩展的方式持续分发

## 2. 核心架构结论

当前推荐的总体方案如下：

- 客户端：`Flutter`
- 设计系统：`Material 3` 风格，自定义主题，适配明暗模式与系统动态色
- 本地数据：`SQLite/Drift` 作为题库索引与缓存数据库
- 远端数据：`Supabase Postgres`
- 资源存储：优先 `Cloudflare R2 + CDN`，国内访问不稳定时增加国内镜像分发层
- 首发题库：应用内置一批种子题目与轻量资源
- 增量更新：通过远端题库包和资源清单拉取
- 内容生产：内部工作流服务化，但首期不对普通用户公开

## 3. 为什么不能只靠远端数据库

你提到的核心问题非常对：几百组数据怎么分发，决定了产品能不能“下载后立刻玩”。

如果应用安装后必须实时从云端拉取所有题目和图片/视频，问题会很明显：

- 首次打开等待时间长
- 国内网络环境下访问波动大
- 免费对象存储和公共仓库很容易踩 ToS 或流量限制
- 视频资源体积大，冷启动体验差

因此这里不建议做成“纯在线题库”。推荐采用：

- `内置基础题库`
- `远端增量包`
- `本地缓存索引`

也就是：

1. App 安装包里自带一批可直接游玩的内容
2. App 首次启动后后台检查是否有新题库包
3. 有网络时增量拉取更多题目和媒体资源
4. 离线时仍能玩已缓存内容

## 4. 分发策略设计

## 4.1 题库分层

建议把题库分成三层：

### 第一层：内置种子题库

作用：保证即装即玩。

建议规模：

- 文字：`20-30` 题
- 图片：`20-30` 题
- 视频：首发可不内置，或者只放 `3-5` 题演示样本

存放方式：

- `assets/bootstrap/challenges.json`
- `assets/bootstrap/media/...`

要求：

- 资源轻量
- 覆盖核心玩法
- 不依赖网络

### 第二层：远端增量题库包

作用：扩容题库，降低安装包大小。

建议形式：

- 按模式拆包：`text-pack-001.json`、`image-pack-003.json`
- 图片和视频资源使用清单文件描述
- 客户端按需下载、按版本入库

### 第三层：热更新推荐池

作用：在首页推荐或活动场景中动态下发特定题目。

适合内容：

- 新发布专题
- 节日主题
- 课堂活动指定题单

## 4.2 推荐的免费优先分发路径

你提到不想把这类数据直接放 GitHub，这个判断基本是对的。原因包括：

- GitHub Releases 和仓库本身不适合作为高频公共媒体分发 CDN
- 大量媒体文件会让仓库管理混乱
- 一旦流量上来，有被限速或体验不稳定的风险

推荐顺序如下：

### 方案 1：`Cloudflare R2 + CDN`

优点：

- 成本低
- 适合对象存储
- 公开资源分发体验比 GitHub 合适
- 资源组织灵活，适合图片/视频/清单文件

缺点：

- 对中国大陆的稳定性和速度存在波动
- 严格说不是“国内优先”方案

### 方案 2：`国内对象存储镜像 + Cloudflare R2 主桶`

这是我更推荐的长期方案。

做法：

- 主资源桶放 `R2`
- 公开分发镜像放国内对象存储或 CDN
- 客户端配置主源和备用源

优点：

- 兼顾成本与可达性
- 可以在国内网络较差时自动切换备用源

缺点：

- 运维复杂度略高

### 方案 3：首发阶段完全内置 + 后续更新包单独下载

适合最早期原型验证。

优点：

- 不依赖网络
- 最稳

缺点：

- 安装包会膨胀
- 后续更新需要重新发版，或者单独做资源更新机制

## 4.3 推荐的现实落地方案

综合免费、速度、复杂度和未来扩展，我建议：

- `MVP`：应用内置基础题库 + 远端预留更新机制
- `V1`：使用 `Cloudflare R2` 托管题库包和媒体资源
- `国内优化版`：增加国内镜像源，客户端做主备切换

也就是说，最开始不要把成败押在在线分发上，而是先确保“没网也能玩”。

## 5. 客户端启动与同步流程

## 5.1 首次安装启动流程

1. App 启动
2. 导入内置种子题库到本地数据库
3. 加载首页和模式页
4. 后台异步请求远端 `manifest.json`
5. 若发现有新题库包，则在后台下载并入库
6. 下载完成后刷新首页题目池

用户感知上应该是：

- 一打开就能玩
- 网络恢复后内容悄悄变多
- 不需要手动下载复杂资源

## 5.2 数据同步原则

- `元数据先行`：先拉题目列表和索引，再按需拉媒体
- `按模式懒加载`：进入视频模式时再优先拉视频相关资源
- `可中断可恢复`：下载任务中断后可续传或重试
- `版本化`：每个题库包都有版本号和 hash
- `不阻塞首屏`：任何同步都不能阻塞首次进入主页

## 6. 首页与二级页面信息架构

你提的这个设计很适合：进入主页按钮的某个二级页面后，上方有一个随机按钮，下方展示数据库里的具体题目，并支持“换一批”。我建议落成下面这个结构。

## 6.1 二级页面布局

- 顶部：页面标题和简介
- 中上：一个醒目的 `随机挑战` 按钮
- 中部：`10 条题目卡片`
- 底部或列表上方：`换一批` 按钮

列表分两列展示在大屏上成立，但在手机上应自动退化成单列。因此建议：

- 手机竖屏：单列卡片
- 平板和桌面：双列网格

## 6.2 列表取数逻辑

每次进入页面：

- 从本地数据库中读取对应模式、已发布、适龄的题目
- 随机抽 `10` 条显示

点击 `换一批`：

- 重新随机抽取一批未在当前批次中出现的题目

点击 `随机挑战`：

- 随机进入一个题目详情页

建议支持的过滤条件：

- `mode`
- `status = published`
- `age_range`
- `difficulty`
- `has_media_cached`

这意味着首页和二级页面主要依赖本地数据库，而不是每次去远端查库。

## 6.3 为什么首页不应直接连远端查询

- 进入页面速度会变慢
- 网络波动会影响基础体验
- 随机抽题和去重更适合本地完成
- 本地数据库便于做“换一批”“已玩过”“是否缓存完成”等状态控制

## 7. 设计系统与 Flutter 落地

## 7.1 关于你说的 MUI 风格

如果最终是 Flutter 客户端，那么严格意义上不能直接使用 Web 端的 `MUI` 组件库。

更准确的落地方式应该是：

- 使用 `Material 3`
- 自定义 color scheme、surface、shape、elevation、typography
- 做出接近 MUI 的整洁卡片感、留白和交互层次

也就是说，应该表达为：

- `MUI 风格的视觉气质`
- `Flutter Material 3 的技术实现`

## 7.2 主题建议

- 支持 `Light/Dark`
- 支持系统动态色，若平台支持则读取系统色板
- 默认使用较明快、对儿童友好的色系，而不是企业后台风格
- 卡片圆角适中，按钮强调可点击性

## 7.3 推荐组件层级

- `AppShell`
- `ModeEntryCard`
- `RandomChallengeButton`
- `ChallengeGrid`
- `ChallengeCard`
- `ResultDialog`
- `RewardOverlay`
- `HintChip`

## 8. 数据模型设计

## 8.1 推荐主表

### `challenge_sets`

- `id`
- `mode`
- `title`
- `prompt`
- `description`
- `difficulty`
- `age_min`
- `age_max`
- `status`
- `correct_option_id`
- `pack_version`
- `is_builtin`
- `published_at`
- `created_at`
- `updated_at`

### `challenge_options`

- `id`
- `challenge_set_id`
- `option_key`
- `source_type`
- `content_text`
- `media_asset_id`
- `sort_order`

### `media_assets`

- `id`
- `media_type`
- `storage_key`
- `public_url`
- `thumbnail_url`
- `width`
- `height`
- `duration_ms`
- `checksum`
- `origin_type`
- `license_type`
- `cache_policy`

### `challenge_packs`

- `id`
- `pack_code`
- `mode`
- `version`
- `manifest_url`
- `min_app_version`
- `is_required`
- `status`

### `play_sessions`

- `id`
- `device_id`
- `mode`
- `started_at`
- `ended_at`
- `score`
- `accuracy`

### `play_records`

- `id`
- `session_id`
- `challenge_set_id`
- `selected_option_id`
- `is_correct`
- `time_spent_ms`
- `hint_used`

## 8.2 本地缓存表

客户端建议额外维护几张本地表：

### `downloaded_packs`

- `pack_code`
- `version`
- `download_status`
- `downloaded_at`

### `cached_media`

- `media_asset_id`
- `local_path`
- `cache_status`
- `last_accessed_at`

### `user_progress`

- `challenge_set_id`
- `played_count`
- `last_played_at`
- `best_result`

## 9. 远端 manifest 设计

为了支持低成本增量更新，建议远端维护一个统一清单文件，例如：

```json
{
  "schema_version": 1,
  "generated_at": "2026-03-30T12:00:00Z",
  "packs": [
    {
      "pack_code": "text-basic-001",
      "mode": "text",
      "version": 3,
      "url": "https://cdn.example.com/packs/text-basic-001-v3.json",
      "checksum": "sha256:...",
      "required_assets": []
    },
    {
      "pack_code": "image-basic-001",
      "mode": "image",
      "version": 2,
      "url": "https://cdn.example.com/packs/image-basic-001-v2.json",
      "checksum": "sha256:...",
      "required_assets": [
        "img_001",
        "img_002"
      ]
    }
  ]
}
```

客户端流程：

- 先拉 manifest
- 比较本地 pack 版本
- 只下载新版本 pack
- 将 pack 中的题目与资源索引入库

## 10. 内容生产工作流架构

## 10.1 工作流阶段

建议拆成四个阶段：

1. `素材输入`
2. `AI 生成`
3. `人工审核`
4. `打包发布`

### 文字模式

- 输入：问题 + 真人回答
- 处理：提取风格特征，生成相似风格 AI 回答
- 输出：对比题、解释文案、难度标记

### 图片模式

- 输入：真实照片
- 处理：视觉描述、提示词重构、生成相似图
- 输出：对比图、解释文案、审核记录

### 视频模式

- 输入：真实短视频
- 处理：关键帧分析、动作描述、视频生成
- 输出：对比视频、解释文案、审核记录

## 10.2 为什么建议“底层共用，前台不完全开放”

你担心如果只给游玩权限，未来再把工作流拆出来会麻烦，这个顾虑是合理的。因此架构上我建议：

- 一开始就把内容生产工作流做成独立服务层
- 但产品权限上先区分 `游客/玩家` 和 `创作者/审核员`

这样做的好处：

- 后端不用重构两套系统
- 后续若要开放创作者沙盒，只是加权限和配额控制
- 普通玩家不会直接碰到高成本、高风险的上传与生成入口

## 10.3 推荐权限层级

### `guest`

- 只可游玩
- 只可查看公开题目

### `creator`

- 可上传输入素材
- 可触发有限次数的生成任务
- 生成结果默认不公开

### `reviewer`

- 可审核内容
- 可发布 pack

### `admin`

- 可管理模型配置、题库、分发源、配额

## 10.4 为什么不建议首发就开放全量沙盒

- 成本不可控，尤其是图片和视频生成
- 审核压力很大
- 容易被滥用上传不合规内容
- 产品主线会从“儿童科普体验”偏移成“通用 AI 工具”

所以更稳的路径是：

- 先共用底层架构
- 后续在创作者模式下逐步开放

## 11. 免费部署与国内可用性建议

## 11.1 免费优先原则

免费方案只能优先解决 MVP，不可能一次性把“高速、稳定、视频大流量、国内外都快”全部解决。

所以需要优先级：

1. 即装即玩
2. 轻量增量更新
3. 低成本对象存储
4. 国内体验逐步优化

## 11.2 推荐部署组合

### 开发期

- `Supabase`：存元数据
- `R2`：存 pack 和媒体
- `Flutter assets`：存种子题库

### 国内优化期

- 增加国内镜像桶或 CDN 回源
- manifest 里记录多个 base URL
- 客户端按地区或测速选择源

## 11.3 资源路径建议

```text
/manifest/production.json
/packs/text/text-basic-001-v3.json
/packs/image/image-basic-001-v2.json
/media/images/2026/03/img_001.webp
/media/videos/2026/03/vid_014.mp4
/media/thumbs/2026/03/vid_014.jpg
```

## 12. Flutter 工程建议

## 12.1 目录结构

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  features/
    home/
    intro/
    challenge/
    results/
    packs/
    settings/
  data/
    local/
    remote/
    repositories/
    models/
  services/
    sync/
    storage/
    analytics/
  shared/
    widgets/
    utils/
assets/
  bootstrap/
  animations/
  images/
```

## 12.2 状态管理建议

- `Riverpod` 适合当前项目
- 将页面状态、同步状态、下载状态、题目池状态拆开管理
- 随机抽题逻辑放在 repository 或 service 层，而不是 UI 层

## 12.3 关键仓储接口

### `ChallengeRepository`

- `getRandomChallenge(mode)`
- `getChallengeBatch(mode, limit)`
- `refreshChallengeBatch(mode)`
- `markPlayed(challengeId)`

### `PackRepository`

- `loadBootstrapPacks()`
- `syncManifest()`
- `downloadPack(packCode)`
- `applyPack(packCode)`

### `MediaRepository`

- `prefetchForChallenge(challengeId)`
- `resolvePlayableMedia(mediaAssetId)`

## 13. MVP 范围建议

建议把 MVP 控制在下面这些范围内：

- `文字模式`
- `图片模式`
- `内置种子题库`
- `首页模式入口`
- `二级页面随机按钮 + 十题列表 + 换一批`
- `基础奖励动画`
- `本地进度记录`

暂不进入 MVP 的内容：

- 用户上传沙盒
- 视频大规模分发
- 复杂账号体系
- 在线多人或排行榜

## 14. 开发优先级

### P0

- Flutter 壳子与主题系统
- 本地数据库模型
- 内置题库导入
- 二级页面随机抽题与换一批
- 挑战详情与结果反馈

### P1

- manifest 拉取
- pack 增量更新
- 资源缓存策略
- 题目解释与提示卡

### P2

- 国内镜像源
- 视频模式
- 创作者权限与生成工作流

## 15. 最终建议

关于你问的两个关键问题，我的明确判断是：

### 关于数据分发

不要依赖 GitHub 作为正式题库和媒体分发渠道。最稳妥的办法是：

- App 内置一批基础题目，保证即装即玩
- 远端通过 `manifest + pack` 机制做增量更新
- 资源存储优先用 `R2`，后续再加国内镜像

### 关于是否给用户开放工作流

底层架构建议从第一天就按“游玩系统 + 内容生产系统”共用能力来设计；但产品层不建议首发就向所有用户开放工作流沙盒。更合适的方式是：

- 首发先开放游玩
- 后续在 `creator` 或活动模式中逐步开放受限沙盒

这样你既不会把架构做死，也不会把首发复杂度和风险拉得过高。
