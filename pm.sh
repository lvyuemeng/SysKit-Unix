#!/bin/bash
set -euo pipefail

detect_distro() {
  [ -f "/etc/os-release" ] && . /etc/os-release
  echo "${ID:-unknown}"
}

DISTRO=$(detect_distro)

command_exists() {
  command -v "$1" &>/dev/null
}

# ---

install_package() {
  local name="$1"

  case "$DISTRO" in
  ubuntu | debian)
    sudo apt update -qq && sudo apt install -y "$name"
    ;;
  fedora | centos | rhel | almalinux | rocky)
    sudo dnf install -y "$name"
    ;;
  arch | manjaro)
    sudo pacman -Sy --noconfirm "$name"
    ;;
  opensuse-leap | opensuse-tumbleweed)
    sudo zypper install -y "$name"
    ;;
  *)
    echo "Unsupported distribution for install: $DISTRO." >&2
    return 1
    ;;
  esac
  return 0
}

uninstall_package() {
  local name="$1"
  case "$DISTRO" in
  ubuntu | debian)
    sudo apt remove -y "$name"
    ;;
  fedora | centos | rhel | almalinux | rocky)
    sudo dnf remove -y "$name"
    ;;
  arch | manjaro)
    sudo pacman -R --noconfirm "$name"
    ;;
  opensuse-leap | opensuse-tumbleweed)
    sudo zypper remove -y "$name"
    ;;
  *)
    echo "Unsupported distribution for uninstall: $DISTRO." >&2
    return 1
    ;;
  esac

  return 0
}

# Update system packages
update() {
  case "$DISTRO" in
  ubuntu | debian)
    sudo apt update -qq && sudo apt upgrade -y
    ;;
  fedora | centos | rhel | almalinux | rocky)
    sudo dnf update -y
    ;;
  arch | manjaro)
    sudo pacman -Syu --noconfirm
    ;;
  opensuse-leap | opensuse-tumbleweed)
    sudo zypper refresh && sudo zypper update -y
    ;;
  *)
    echo "Unsupported distribution for update: $DISTRO." >&2
    return 1
    ;;
  esac

  return 0
}
