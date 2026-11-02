# Ghidra Docker

**English** | [中文](#中文)

Ghidra container images on multiple mainstream Linux distributions. All
distributions share the same `Dockerfile.ghidra`; upgrading Ghidra usually
only requires adjusting build arguments.

## Support Matrix

| Target | Base image | Image tag |
| --- | --- | --- |
| `debian` | Debian 13 | `debian-12.2` |
| `ubuntu` | Ubuntu 24.04 | `ubuntu-12.2` |
| `fedora` | Fedora 44 | `fedora-12.2` |
| `rocky` | Rocky Linux 9 | `rocky-12.2` |
| `almalinux` | AlmaLinux 9 | `almalinux-12.2` |
| `opensuse` | openSUSE Tumbleweed | `opensuse-12.2` |

Images are published to [Docker Hub: sort/ghidra](https://hub.docker.com/r/sort/ghidra);
the full image name is `docker.io/sort/ghidra`.

Pull the image for the distribution you need:

```sh
docker pull sort/ghidra:ubuntu-12.2
docker pull sort/ghidra:debian-12.2
docker pull sort/ghidra:fedora-12.2
docker pull sort/ghidra:rocky-12.2
docker pull sort/ghidra:almalinux-12.2
docker pull sort/ghidra:opensuse-12.2
```

## Building

Build a single distribution:

```sh
docker buildx bake debian
```

Build all distributions:

```sh
docker buildx bake
```

Override the image name and Ghidra version:

```sh
REGISTRY=docker.io \
IMAGE_NAME=example/ghidra \
GHIDRA_VERSION=12.2 \
GHIDRA_RELEASE_DATE=20261016 \
docker buildx bake
```

You can also build the Dockerfile directly:

```sh
docker build \
  --file Dockerfile.ghidra \
  --build-arg BASE_IMAGE=ubuntu:24.04 \
  --build-arg GHIDRA_VERSION=12.2 \
  --build-arg GHIDRA_RELEASE_DATE=20261016 \
  --tag example/ghidra:ubuntu-12.2 \
  .
```

Available build arguments:

| Argument | Default | Purpose |
| --- | --- | --- |
| `BASE_IMAGE` | `debian:13` | Select the base distribution image |
| `GHIDRA_VERSION` | `12.2` | Ghidra version |
| `GHIDRA_RELEASE_DATE` | `20261016` | Date in the official ZIP filename |
| `GHIDRA_SHA256` | empty | Optional SHA-256 of the official ZIP |

Distribution versions are selected by overriding `BASE_IMAGE`. As long as the
base image uses APT, DNF, or Zypper and provides OpenJDK 21, the same
Dockerfile can be reused.

## Publishing to Docker Hub via GitHub Actions

`.github/workflows/build-images.yml` runs when image configuration changes on
the `main` branch and also supports manual dispatch. The workflow builds all
distributions in a six-job matrix and pushes the tags defined in Bake directly
to Docker Hub.

Configure the following in the GitHub repository:

1. `Settings → Secrets and variables → Actions → Variables`: add
   `DOCKERHUB_USERNAME` with your Docker Hub username or organization name.
2. `Settings → Secrets and variables → Actions → Secrets`: add
   `DOCKERHUB_TOKEN` with a Docker Hub Personal Access Token that has
   Read & Write permission on the target repository.
3. Make sure the account has write access to
   [Docker Hub: sort/ghidra](https://hub.docker.com/r/sort/ghidra).

After a Ghidra version bump PR is merged, the workflow automatically
publishes six new `<distro>-<ghidra-version>` tags. Each distribution uses
its own GitHub Actions BuildKit cache.

## Running

The default entrypoint is the official Ghidra launcher
`/opt/ghidra/ghidraRun`. To run the GUI, provide the container with the host
display environment, for example Linux X11.

The image sets both `GHIDRA_INSTALL_DIR=/opt/ghidra` and the compatibility
variable `GHIDRA_HOME=/opt/ghidra`.

```sh
docker run --rm \
  --env DISPLAY \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  --volume "$PWD:/workspace" \
  sort/ghidra:debian-12.2
```

For headless analysis, override the entrypoint:

```sh
docker run --rm \
  --entrypoint /opt/ghidra/support/analyzeHeadless \
  --volume "$PWD:/workspace" \
  sort/ghidra:debian-12.2 \
  /workspace/projects example -import /workspace/example.bin
```

## Automated Ghidra Release Check

`.github/workflows/check-ghidra-release.yml` queries the official Ghidra
repository for the latest release every Monday. When a new version is
detected, it extracts the version and release date from the official asset
name, updates the Dockerfile and Bake defaults, and opens a PR. The
repository must allow GitHub Actions to create pull requests:

`Settings → Actions → General → Workflow permissions → Allow GitHub Actions
to create and approve pull requests`.

Release source: [NationalSecurityAgency/ghidra Releases](https://github.com/NationalSecurityAgency/ghidra/releases).

---

<a id="中文"></a>

# Ghidra Docker（中文）

[English](#ghidra-docker) | **中文**

基于多个主流 Linux 发行版的 Ghidra 镜像。所有发行版
共享同一个 `Dockerfile.ghidra`，Ghidra 升级通常只需调整构建参数。

## 支持矩阵

| 构建目标 | 基础镜像 | 镜像标签 |
| --- | --- | --- |
| `debian` | Debian 13 | `debian-12.2` |
| `ubuntu` | Ubuntu 24.04 | `ubuntu-12.2` |
| `fedora` | Fedora 44 | `fedora-12.2` |
| `rocky` | Rocky Linux 9 | `rocky-12.2` |
| `almalinux` | AlmaLinux 9 | `almalinux-12.2` |
| `opensuse` | openSUSE Tumbleweed | `opensuse-12.2` |

镜像发布在 [Docker Hub：sort/ghidra](https://hub.docker.com/r/sort/ghidra)，
完整镜像名为 `docker.io/sort/ghidra`。

拉取所需发行版镜像：

```sh
docker pull sort/ghidra:ubuntu-12.2
docker pull sort/ghidra:debian-12.2
docker pull sort/ghidra:fedora-12.2
docker pull sort/ghidra:rocky-12.2
docker pull sort/ghidra:almalinux-12.2
docker pull sort/ghidra:opensuse-12.2
```

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
GHIDRA_VERSION=12.2 \
GHIDRA_RELEASE_DATE=20261016 \
docker buildx bake
```

也可以直接构建 Dockerfile：

```sh
docker build \
  --file Dockerfile.ghidra \
  --build-arg BASE_IMAGE=ubuntu:24.04 \
  --build-arg GHIDRA_VERSION=12.2 \
  --build-arg GHIDRA_RELEASE_DATE=20261016 \
  --tag example/ghidra:ubuntu-12.2 \
  .
```

可用参数包括：

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| `BASE_IMAGE` | `debian:13` | 选择基础发行版镜像 |
| `GHIDRA_VERSION` | `12.2` | Ghidra 版本 |
| `GHIDRA_RELEASE_DATE` | `20261016` | 官方 ZIP 文件名中的日期 |
| `GHIDRA_SHA256` | 空 | 可选的官方 ZIP SHA-256 |

发行版版本直接通过 `BASE_IMAGE` 覆盖；只要基础镜像使用 APT、DNF 或 Zypper
并提供 OpenJDK 21，即可复用同一个 Dockerfile。

## GitHub Actions 发布到 Docker Hub

`.github/workflows/build-images.yml` 在 `main` 分支的镜像配置发生变化时运行，
也支持手动触发。工作流使用六任务矩阵并行构建各发行版，通过 Bake 中的标签
直接推送到 Docker Hub。

在 GitHub 仓库中配置：

1. `Settings → Secrets and variables → Actions → Variables` 新增
   `DOCKERHUB_USERNAME`，值为 Docker Hub 用户名或组织名。
2. `Settings → Secrets and variables → Actions → Secrets` 新增
   `DOCKERHUB_TOKEN`，值为具有目标仓库 Read & Write 权限的 Docker Hub
   Personal Access Token。
3. 确保该账户对
   [Docker Hub：sort/ghidra](https://hub.docker.com/r/sort/ghidra)
   仓库具有写入权限。

合并 Ghidra 版本更新 PR 后，工作流会自动发布六个新的
`<发行版>-<Ghidra版本>` 标签。各发行版使用独立的 GitHub Actions BuildKit
缓存。

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
  sort/ghidra:debian-12.2
```

执行无头分析时覆盖入口：

```sh
docker run --rm \
  --entrypoint /opt/ghidra/support/analyzeHeadless \
  --volume "$PWD:/workspace" \
  sort/ghidra:debian-12.2 \
  /workspace/projects example -import /workspace/example.bin
```

## 自动检查 Ghidra Release

`.github/workflows/check-ghidra-release.yml` 每周一查询 Ghidra 官方仓库的最新
Release。检测到新版本后，会从官方资产名提取版本和发布日期，更新 Dockerfile
及 Bake 默认值并创建 PR。仓库需要允许 GitHub Actions 创建 Pull Request：

`Settings → Actions → General → Workflow permissions → Allow GitHub Actions to
create and approve pull requests`。

发布来源：[NationalSecurityAgency/ghidra Releases](https://github.com/NationalSecurityAgency/ghidra/releases)。
