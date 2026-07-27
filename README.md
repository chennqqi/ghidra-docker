# Ghidra Docker

基于多个主流 Linux 发行版的 Ghidra 镜像。所有发行版
共享同一个 `Dockerfile.ghidra`，Ghidra 升级通常只需调整构建参数。

## 支持矩阵

| 构建目标 | 基础镜像 | 镜像标签 |
| --- | --- | --- |
| `debian` | Debian 13 | `debian-12.1.2` |
| `ubuntu` | Ubuntu 24.04 | `ubuntu-12.1.2` |
| `fedora` | Fedora 44 | `fedora-12.1.2` |
| `rocky` | Rocky Linux 9 | `rocky-12.1.2` |
| `almalinux` | AlmaLinux 9 | `almalinux-12.1.2` |
| `opensuse` | openSUSE Tumbleweed | `opensuse-12.1.2` |

镜像名默认为 `docker.io/chennqqi/ghidra`，可通过 Bake 变量覆盖。

## 构建

构建单个发行版：

```sh
docker buildx bake debian
```

构建全部发行版：

```sh
docker buildx bake
```

覆盖镜像名和 Ghidra 版本：

```sh
REGISTRY=docker.io \
IMAGE_NAME=example/ghidra \
GHIDRA_VERSION=12.1.2 \
GHIDRA_RELEASE_DATE=20260605 \
docker buildx bake
```

也可以直接构建 Dockerfile：

```sh
docker build \
  --file Dockerfile.ghidra \
  --build-arg BASE_IMAGE=ubuntu:24.04 \
  --build-arg GHIDRA_VERSION=12.1.2 \
  --build-arg GHIDRA_RELEASE_DATE=20260605 \
  --tag example/ghidra:ubuntu-12.1.2 \
  .
```

可用参数包括：

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| `BASE_IMAGE` | `debian:13` | 选择基础发行版镜像 |
| `GHIDRA_VERSION` | `12.1.2` | Ghidra 版本 |
| `GHIDRA_RELEASE_DATE` | `20260605` | 官方 ZIP 文件名中的日期 |
| `GHIDRA_SHA256` | 空 | 可选的官方 ZIP SHA-256 |

发行版版本直接通过 `BASE_IMAGE` 覆盖；只要基础镜像使用 APT、DNF 或 Zypper
并提供 OpenJDK 21，即可复用同一个 Dockerfile。

## Docker Hub 自动构建

在 Docker Hub 仓库的 Build configurations 中为每个目标建立一条规则。所有
规则使用仓库根目录作为 Build context，Dockerfile path 均为
`Dockerfile.ghidra`。仓库内的 `hooks/build` 会根据目标 Docker tag 自动提取
发行版和 Ghidra 版本，因此分别设置：

| Docker tag | 对应发行版 |
| --- | --- |
| `debian-12.1.2` | Debian |
| `ubuntu-12.1.2` | Ubuntu |
| `fedora-12.1.2` | Fedora |
| `rocky-12.1.2` | Rocky Linux |
| `almalinux-12.1.2` | AlmaLinux |
| `opensuse-12.1.2` | openSUSE |

在 Build environment variables 中设置 `GHIDRA_RELEASE_DATE=20260605`，可选
设置 `GHIDRA_SHA256`。`GHIDRA_VERSION` 默认直接取
Docker tag 中系统名后的部分；如果显式设置，它必须与 tag 一致。Docker Hub
连接 GitHub 后，提交或合并版本更新 PR 即可触发这些构建。若希望保留旧版本，
新增对应标签的规则，不要覆盖已有版本标签。

Docker Hub 已宣布 Automated Builds 将于 2027-04-01 完全退役。当前连接可以
继续使用，但应在退役前迁移到 GitHub Actions Buildx 并推送至 Docker Hub。

## 运行

默认入口是 Ghidra 官方启动命令 `/opt/ghidra/ghidraRun`。运行 GUI 时需要向
容器提供宿主机图形显示环境，例如 Linux X11：

镜像同时设置 `GHIDRA_INSTALL_DIR=/opt/ghidra` 和兼容变量
`GHIDRA_HOME=/opt/ghidra`。

```sh
docker run --rm \
  --env DISPLAY \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  --volume "$PWD:/workspace" \
  docker.io/chennqqi/ghidra:debian-12.1.2
```

执行无头分析时覆盖入口：

```sh
docker run --rm \
  --entrypoint /opt/ghidra/support/analyzeHeadless \
  --volume "$PWD:/workspace" \
  docker.io/chennqqi/ghidra:debian-12.1.2 \
  /workspace/projects example -import /workspace/example.bin
```

## 自动检查 Ghidra Release

`.github/workflows/check-ghidra-release.yml` 每周一查询 Ghidra 官方仓库的最新
Release。检测到新版本后，会从官方资产名提取版本和发布日期，更新 Dockerfile
及 Bake 默认值并创建 PR。仓库需要允许 GitHub Actions 创建 Pull Request：

`Settings → Actions → General → Workflow permissions → Allow GitHub Actions to
create and approve pull requests`。

发布来源：[NationalSecurityAgency/ghidra Releases](https://github.com/NationalSecurityAgency/ghidra/releases)。
