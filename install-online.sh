#!/bin/sh
set -eu

INSTALL_DIR="/opt/xboard-node"
CONFIG_DIR="/etc/xboard-node"
SERVICE_FILE="/etc/init.d/xboard-node"
BASE_URL="https://github.com/cedar2025/xboard-node/releases/latest/download"

[ "$(id -u)" -eq 0 ] || { echo "Error: run as root." >&2; exit 1; }

while :; do
    printf "Machine ID: "
    IFS= read -r MACHINE_ID
    [ -n "$MACHINE_ID" ] && break
    echo "Value cannot be empty."
done

while :; do
    printf "Machine Token: "
    stty -echo 2>/dev/null || true
    IFS= read -r MACHINE_TOKEN
    stty echo 2>/dev/null || true
    printf "\n"
    [ -n "$MACHINE_TOKEN" ] && break
    echo "Value cannot be empty."
done

while :; do
    printf "Xboard panel URL: "
    IFS= read -r PANEL_URL
    [ -n "$PANEL_URL" ] && break
    echo "Value cannot be empty."
done

while :; do
    printf "Disable tty1-tty4? [y/N]: "
    IFS= read -r TTY_CHOICE
    case "$TTY_CHOICE" in
        y|Y|yes|YES) DISABLE_TTY=yes; break ;;
        n|N|no|NO|'') DISABLE_TTY=no; break ;;
        *) echo "Enter y or n." ;;
    esac
done

case "$(uname -m)" in
    x86_64|amd64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

case "$MACHINE_ID" in
    *[!A-Za-z0-9_-]*|'') echo "Invalid machine ID." >&2; exit 1 ;;
esac

apk update
apk add --no-cache curl bash ca-certificates openrc
update-ca-certificates
mkdir -p "$INSTALL_DIR" "$CONFIG_DIR/instances/machine-$MACHINE_ID"
curl -fL --retry 3 -o "$INSTALL_DIR/xboard-node" "$BASE_URL/xboard-node-linux-$ARCH"
curl -fL --retry 3 -o "$INSTALL_DIR/xbctl" "$BASE_URL/xbctl-linux-$ARCH"
chmod 0755 "$INSTALL_DIR/xboard-node" "$INSTALL_DIR/xbctl"

cat >"$CONFIG_DIR/config.yml" <<EOF
instances:
  - id: machine-$MACHINE_ID
    panel:
      url: "$PANEL_URL"
    kernel:
      type: singbox
      config_dir: $CONFIG_DIR/instances/machine-$MACHINE_ID
      log_level: warn
    log:
      level: info
      output: stdout
    health_port: 65532
    machine:
      machine_id: $MACHINE_ID
      token: "$MACHINE_TOKEN"
EOF
chmod 0600 "$CONFIG_DIR/config.yml"

cat >"$SERVICE_FILE" <<'EOF'
#!/sbin/openrc-run
name="xboard-node"
description="Xboard Node Backend"
supervisor="supervise-daemon"
command="/opt/xboard-node/xboard-node"
command_args="-c /etc/xboard-node/config.yml"
pidfile="/run/${RC_SVCNAME}.pid"
output_log="/var/log/xboard-node.log"
error_log="/var/log/xboard-node.log"
respawn_delay=5
respawn_max=0

depend() {
    need net
    after firewall
}

start_pre() {
    checkpath --directory --mode 0755 /run
    checkpath --file --owner root:root --mode 0644 "${output_log}"
}
EOF
chmod 0755 "$SERVICE_FILE"
rc-update add xboard-node default 2>/dev/null || true
rc-service xboard-node restart

if [ "$DISABLE_TTY" = yes ]; then
    [ -f /etc/inittab.bak ] || cp /etc/inittab /etc/inittab.bak
    sed -i -e '/^tty1::respawn/s/^/#/' -e '/^tty2::respawn/s/^/#/' -e '/^tty3::respawn/s/^/#/' -e '/^tty4::respawn/s/^/#/' /etc/inittab
    kill -HUP 1
fi

rc-service xboard-node status
tail -n 30 /var/log/xboard-node.log 2>/dev/null || true
