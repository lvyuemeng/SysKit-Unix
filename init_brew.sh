#!/bin/bash
set -euo pipefail

readonly OFFICIAL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
readonly OFFICIAL_HOST="raw.githubusercontent.com"

readonly USTC_URL="https://mirrors.ustc.edu.cn/misc/brew-install.sh"
readonly USTC_HOST="mirrors.ustc.edu.cn"

readonly PROFILE="$HOME/.profile"

# ---
ping_test() {
	local host="$1"
	# ping $host sending 3 c(packets), 1 W(timeout secs)
	# tail -1(last) line
	# awk 4th field (latency: min/avg/max/mdev)
	# cut `/` -d(delimiter), extract 2 -f(field)
	(ping -c 3 -W 1 "$host" 2>/dev/null | tail -1 | awk '{print $4}' | cut -d '/' -f 2) || echo ""
}

# ---

if command -v brew &> /dev/null; then
	echo "rage is installed"
	exit 0
fi

official_latency=$(ping_test "$OFFICIAL_HOST")
ustc_latency=$(ping_test "$USTC_HOST")

if [[ -z "$official_latency" ]] | [[ "$ustc_latency" -lt "$official_latency"]]; then
	echo "choose USTC mirror."
	export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
	export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
	export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
	export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
	install_url="$USTC_URL"
else 
	echo "choose official"
	install_url="$OFFICIAL_URL"
fi

if ! /bin/bash -c "$(curl -fsSL "$install_url")"; then
	echo "homebrew installation failed" >&2
	exit 1
fi

brew_path=$(command -v brew) || { echo "brew not found after install" >&2; exit 1; }
eval_shell="eval \"\$(${brew_path} shellenv)\""
if ! grep -qF "$eval_shell" "$PROFILE"; then
	echo -e "\n$eval_shell" >> "$PROFILE"
fi
echo "eval brew added to $PROFILE"

source "$PROFILE"