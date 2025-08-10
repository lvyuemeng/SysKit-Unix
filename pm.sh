#!/bin/bash

HOMEBREW_IN_DEBIAN="true"

detect_distro() {
  [ -f "/etc/os-release" ] && . /etc/os-release
  echo "${ID:-unknown}"
}

DISTRO=$(detect_distro)

command_exists() {
  command -v "$1" &>/dev/null
}

install_homebrew() {
  if command_exists brew; then
    echo "homebrew installed."
    return 0
  fi

  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
  export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
  export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"

  /bin/bash -c "$(curl -fsSL https://mirrors.ustc.edu.cn/misc/brew-install.sh)"

  echo "Configuring brew in shell environment..."
  # Handle different potential brew locations
  if [[ -d ~/.linuxbrew ]]; then
    eval "$(~/.linuxbrew/bin/brew shellenv)"
  elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  return 0
}

install_package() {
  local package_name="$1"
  local use_homebrew="${2:-false}" # debian-like

  echo "Install '$package_name'..."

  case "$DISTRO" in
  ubuntu | debian)
    if [[ "$use_homebrew" == "true" ]]; then
      install_homebrew || {
        echo "Homebrew setup failed, falling back to apt."
        use_homebrew="false"
      }
      if brew install "$package_name"; then
        return 0
      else
        echo "Homebrew install failed or not used. Falling back to apt."
      fi
    fi
    sudo apt update && sudo apt install -y "$package_name"
    ;;
  fedora | centos | rhel | almalinux | rocky)
    sudo dnf install -y "$package_name"
    ;;
  arch | manjaro)
    sudo pacman -Sy --noconfirm "$package_name"
    ;;
  opensuse-leap | opensuse-tumbleweed)
    sudo zypper install -y "$package_name"
    ;;
  *)
    echo "Unsupported distribution for install: $DISTRO." >&2
    return 1
    ;;
  esac
  return 0
}

uninstall_package() {
  local package_name="$1"
  local use_homebrew="${2:-false}" # debian-like

  echo "Uninstalling '$package_name'..."

  case "$DISTRO" in
  ubuntu | debian)
    if [[ "$use_homebrew" == "true" ]] && command_exists brew; then
      if brew uninstall "$package_name"; then
        echo "'$package_name' uninstalled via Homebrew."
        return 0
      else
        echo "Homebrew uninstall failed. Falling back to apt."
      fi
    fi
    sudo apt remove -y "$package_name"
    ;;
  fedora | centos | rhel | almalinux | rocky)
    sudo dnf remove -y "$package_name"
    ;;
  arch | manjaro)
    sudo pacman -R --noconfirm "$package_name"
    ;;
  opensuse-leap | opensuse-tumbleweed)
    sudo zypper remove -y "$package_name"
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
  echo "Updating..."

  case "$DISTRO" in
  ubuntu | debian)
    sudo apt update && sudo apt upgrade -y
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

  # Explicitly update Homebrew if installed
  if command_exists brew; then
    echo "Updating Homebrew packages..."
    brew update && brew upgrade
    [ $? -eq 0 ] && echo "Homebrew packages updated." || echo "Error updating Homebrew packages." >&2
  fi
  return 0
}
