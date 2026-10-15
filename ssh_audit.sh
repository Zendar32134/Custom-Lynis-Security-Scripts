#
# Custom Lynis SSH Audit
#

TEST_ID="CUS-1002"

CONFIG="/etc/ssh/sshd_config"

PASS=0
WARN=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

warn() {
    echo "[WARNING] $1"
    WARN=$((WARN+1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

section() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_value() {

    local KEY="$1"

    if [ ! -f "$CONFIG" ]; then
        echo ""
        return
    fi

    grep -Ei "^[[:space:]]*$KEY" "$CONFIG" | tail -n1 | awk '{print $2}'
}

echo
echo "############################################"
echo "# CUSTOM LYNIS TEST : SSH AUDIT"
echo "# TEST ID : $TEST_ID"
echo "############################################"

section "SSH Protocol Security Audit"

if rpm -q openssh-server >/dev/null 2>&1; then
    pass "OpenSSH Server installed."
else
    fail "OpenSSH Server not installed."
fi

if systemctl list-unit-files | grep -q '^sshd.service'; then
    pass "sshd service exists."
else
    fail "sshd service missing."
fi

if systemctl is-active sshd >/dev/null 2>&1; then
    pass "sshd service running."
else
    warn "sshd service not running."
fi

if systemctl is-enabled sshd >/dev/null 2>&1; then
    pass "sshd enabled at boot."
else
    warn "sshd not enabled at boot."
fi

section "SSH Port"

PORT=$(get_value Port)

if [ -z "$PORT" ]; then
    PORT=22
fi

echo "Listening Port : $PORT"

section "SSH Configuration"

PARAMETERS=(
PermitRootLogin
PasswordAuthentication
PubkeyAuthentication
PermitEmptyPasswords
MaxAuthTries
LoginGraceTime
ClientAliveInterval
ClientAliveCountMax
X11Forwarding
AllowUsers
AllowGroups
DenyUsers
DenyGroups
)

for ITEM in "${PARAMETERS[@]}"
do
    VALUE=$(get_value "$ITEM")

    if [ -z "$VALUE" ]; then
        echo "$ITEM : Default"
    else
        echo "$ITEM : $VALUE"
    fi
done

section "SSH Protocol"

PROTO=$(get_value Protocol)

if [ -z "$PROTO" ]; then
    pass "Protocol Version 2 (Default)"
else
    echo "Protocol : $PROTO"
fi

section "SSH Host Keys"

if ls /etc/ssh/ssh_host_*_key.pub >/dev/null 2>&1; then
    ls /etc/ssh/ssh_host_*_key.pub
else
    warn "SSH Host Keys not found."
fi

section "Security Evaluation"

ROOT=$(get_value PermitRootLogin)
PASSAUTH=$(get_value PasswordAuthentication)
EMPTY=$(get_value PermitEmptyPasswords)
PUBKEY=$(get_value PubkeyAuthentication)
X11=$(get_value X11Forwarding)

[ "$ROOT" = "no" ] && pass "Root login disabled." || warn "Root login enabled."

[ "$PASSAUTH" = "no" ] && pass "Password authentication disabled." || warn "Password authentication enabled."

[ "$PUBKEY" = "yes" ] && pass "Public key authentication enabled." || warn "Public key authentication disabled."

[ "$EMPTY" = "no" ] && pass "Empty passwords disabled." || warn "Empty passwords permitted."

[ "$X11" = "no" ] && pass "X11 forwarding disabled." || warn "X11 forwarding enabled."

section "Audit Summary"

echo "Passed   : $PASS"
echo "Warnings : $WARN"
echo "Failed   : $FAIL"

echo
echo "Finished SSH Audit"
echo
