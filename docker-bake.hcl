variable "REGISTRY" {
  default = "docker.io"
}

variable "IMAGE_NAME" {
  default = "chennqqi/ghidra"
}

variable "GHIDRA_VERSION" {
  default = "12.1.2"
}

variable "GHIDRA_RELEASE_DATE" {
  default = "20260605"
}

variable "GHIDRA_SHA256" {
  default = ""
}

group "default" {
  targets = ["debian", "ubuntu", "fedora", "rocky", "almalinux", "opensuse"]
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile.ghidra"
  args = {
    GHIDRA_VERSION      = GHIDRA_VERSION
    GHIDRA_RELEASE_DATE = GHIDRA_RELEASE_DATE
    GHIDRA_SHA256       = GHIDRA_SHA256
  }
}

target "debian" {
  inherits = ["_common"]
  args = { BASE_IMAGE = "debian:13" }
  tags = ["${REGISTRY}/${IMAGE_NAME}:debian-${GHIDRA_VERSION}"]
}

target "ubuntu" {
  inherits = ["_common"]
  args = { BASE_IMAGE = "ubuntu:24.04" }
  tags = ["${REGISTRY}/${IMAGE_NAME}:ubuntu-${GHIDRA_VERSION}"]
}

target "fedora" {
  inherits = ["_common"]
  args = { BASE_IMAGE = "fedora:44" }
  tags = ["${REGISTRY}/${IMAGE_NAME}:fedora-${GHIDRA_VERSION}"]
}

target "rocky" {
  inherits = ["_common"]
  args = { BASE_IMAGE = "rockylinux/rockylinux:9" }
  tags = ["${REGISTRY}/${IMAGE_NAME}:rocky-${GHIDRA_VERSION}"]
}

target "almalinux" {
  inherits = ["_common"]
  args = { BASE_IMAGE = "almalinux:9" }
  tags = ["${REGISTRY}/${IMAGE_NAME}:almalinux-${GHIDRA_VERSION}"]
}

target "opensuse" {
  inherits = ["_common"]
  args = { BASE_IMAGE = "opensuse/tumbleweed:latest" }
  tags = ["${REGISTRY}/${IMAGE_NAME}:opensuse-${GHIDRA_VERSION}"]
}
