# are-you-robot

一个面向孩子的图灵测试小游戏 MVP，基于 Flutter 构建。

当前版本已经包含：

- 首页与模式入口
- 文字挑战模式
- 图片挑战模式
- 本地预置题库
- Pixabay 占位图片资源
- 随机挑战、六题列表、换一批、答题反馈

## 本地运行

如果本机已经安装 Flutter：

```bash
flutter pub get
flutter run
```

如果本机没有把 Flutter 加到 `PATH`，这个仓库提供了一个本地包装脚本：

```bash
./scripts/flutterw --version
./scripts/build_web.sh
python3 -m http.server 7357 --directory build/web
```

然后打开：

```text
http://127.0.0.1:7357
```

每次改完 UI，如果你是用 `python3 -m http.server` 预览，都需要重新执行一次：

```bash
./scripts/build_web.sh
```

## 部署到 GitHub Pages

这个仓库已经包含 GitHub Actions 工作流，会在每次 push 到 `main` 后自动构建并发布到 GitHub Pages。

当前目标地址是：

```text
https://2005czq.github.io/are-you-robot/
```

工作流文件在：

```text
.github/workflows/deploy-pages.yml
```

### 1. 首次启用

把代码推到 GitHub 后，到仓库页面打开：

- `Settings -> Pages`
- `Build and deployment -> Source`
- 选择 `GitHub Actions`

保存后，之后每次 push 到 `main`，GitHub 都会自动执行构建和部署。

### 2. 这个仓库的发布路径

因为这个项目会发布到仓库子路径而不是根路径，所以工作流里已经固定使用：

```bash
flutter build web --release --base-href /are-you-robot/
```

这样生成出的静态资源路径会和 `https://2005czq.github.io/are-you-robot/` 匹配。

### 3. 更新网站

以后每次改完代码，只需要：

```bash
git add .
git commit -m "Update site"
git push origin main
```

然后等待 GitHub Actions 跑完，页面就会自动更新。

### 4. 本地预览

如果你想先在本地确认网页效果，可以继续使用：

```bash
./scripts/build_web.sh --base-href /are-you-robot/
python3 -m http.server 7357 --directory build/web
```

然后打开：

```text
http://127.0.0.1:7357/are-you-robot/
```

### 5. 自定义域名说明

这个仓库目前不会写入 `CNAME`，也不会覆盖你博客根站点的域名配置。

如果你的自定义域名 `zihim.me` 已经绑定在博客仓库或根站点上，这个项目仓库可以不管它，继续按 GitHub 默认二级地址发布即可。

## GitHub Actions 构建产物

仓库还包含一个额外的构建工作流：

```text
.github/workflows/build-artifacts.yml
```

它会在每次 push 到 `main` 后自动构建并上传：

- Windows 发布包
- Android APK

构建完成后，你可以到 GitHub 仓库的 `Actions` 页面，打开对应的 workflow run，在页面底部的 `Artifacts` 区域下载：

- `are-you-robot-windows-release`
- `are-you-robot-android-apk`

说明：

- Windows 产物是一个完整运行目录，不是单个 exe，下载后需要把整个目录一起解压使用
- Android 产物当前是仓库默认配置下生成的 release apk，适合测试分发；如果后面要正式上架应用商店，还需要补签名配置和正式包名

## 当前题库

- 文字题：10 条
- 图片题：10 条
- 视频模式：预留入口，暂未开放

## 资源说明

图片模式中的基础占位资源来自 Pixabay 官方 CDN 示例地址，AI 风格图为基于这些样例派生出的本地占位素材，仅用于 MVP 演示。
