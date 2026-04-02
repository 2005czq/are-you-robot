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

这个项目可以直接部署为静态网站，最简单的方式就是发布到 GitHub Pages。

### 1. 先确认部署地址

GitHub Pages 常见有两种地址：

- 用户页：`https://你的用户名.github.io/`
- 仓库页：`https://你的用户名.github.io/仓库名/`

如果你是把这个项目作为普通仓库页面发布，通常是第二种，也就是带仓库名子路径。

### 2. 本地构建静态文件

如果最终访问地址是根路径，例如：`https://yourname.github.io/`

```bash
./scripts/build_web.sh
```

如果最终访问地址带仓库名，例如：`https://yourname.github.io/are-you-robot/`

```bash
./scripts/build_web.sh --base-href /are-you-robot/
```

构建完成后，静态文件会出现在：

```text
build/web
```

### 3. 上传到 GitHub

你可以任选一种做法：

- 把 `build/web` 里的内容发布到专门的 `gh-pages` 分支
- 或者把静态文件放到仓库里的某个分支/目录，再在 GitHub Pages 设置里选择来源

如果你只是想先快速上线，常见做法是：

- 代码继续放在主分支
- 把 `build/web` 产物发布到 `gh-pages` 分支
- 然后在 GitHub 仓库的 `Settings -> Pages` 里选择 `Deploy from a branch`
- Branch 选 `gh-pages`
- Folder 选 `/ (root)`

### 4. GitHub Pages 里需要设置什么

如果你用的是 `gh-pages` 分支放构建产物，GitHub 上主要就是设置发布来源。

但要注意：

- GitHub Pages 里的路径设置，只决定“网站从哪里读文件”
- Flutter Web 的 `--base-href`，决定“网页里的资源路径怎么解析”

这两个要匹配，不然首页可能能打开，但 JS、字体、图片会 404。

### 5. 一个最常见的例子

假设你的仓库叫 `are-you-robot`，页面地址会是：

```text
https://你的用户名.github.io/are-you-robot/
```

那你构建时就应该使用：

```bash
./scripts/build_web.sh --base-href /are-you-robot/
```

然后把 `build/web` 中的内容发布到 GitHub Pages 对应分支，再去 GitHub 页面里启用 Pages。

### 6. 更新网站

以后每次改完页面，重复这几个动作就行：

```bash
./scripts/build_web.sh --base-href /你的仓库名/
```

然后把新的 `build/web` 内容重新发布到 GitHub Pages。

### 7. 结论

可以理解成“先把项目代码推到 GitHub 仓库”，但还不完全等于“剩下只在 GitHub 上配路径就行”。

你还需要确保：

- Flutter Web 是按最终访问路径构建的
- GitHub Pages 选择了正确的发布分支/目录
- 发布的是 `build/web` 里的静态文件，而不是 `lib`、`assets` 这些源码目录

如果你后面想省掉手动上传 `build/web` 的步骤，可以再加一个 GitHub Actions，让每次 push 后自动构建并发布到 GitHub Pages。

## 当前题库

- 文字题：10 条
- 图片题：10 条
- 视频模式：预留入口，暂未开放

## 资源说明

图片模式中的基础占位资源来自 Pixabay 官方 CDN 示例地址，AI 风格图为基于这些样例派生出的本地占位素材，仅用于 MVP 演示。
