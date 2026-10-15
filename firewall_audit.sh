#
# Custom Lynis Firewall Audit
#

TEST_ID="CUS-1001"

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

echo
echo "############################################"
echo "# CUSTOM LYNIS TEST : FIREWALL AUDIT"
echo "# TEST ID : $TEST_ID"
echo "############################################"

section "Firewall Configuration Audit"

if ! command_exists firewall-cmd; then
    fail "firewall-cmd command not found."
    return
fi

pass "firewall-cmd command found."

if systemctl list-unit-files | grep -q '^firewalld.service'; then
    pass "Firewalld service exists."
else
    fail "Firewalld service missing."
fi

if systemctl is-enabled firewalld >/dev/null 2>&1; then
    pass "Firewalld enabled."
else
    warn "Firewalld not enabled."
fi

if systemctl is-active firewalld >/dev/null 2>&1; then
    pass "Firewalld running."
else
    fail "Firewalld not running."
fi

section "Firewall Zones"

ACTIVE_ZONE=$(firewall-cmd --get-active-zones 2>/dev/null | head -n1)

if [ -n "$ACTIVE_ZONE" ]; then
    pass "Active Zone : $ACTIVE_ZONE"
else
    warn "No active zone."
fi

DEFAULT_ZONE=$(firewall-cmd --get-default-zone 2>/dev/null)

if [ -n "$DEFAULT_ZONE" ]; then
    echo "Default Zone : $DEFAULT_ZONE"
else
    warn "Default zone unavailable."
fi

section "Enabled Services"

SERVICES=$(firewall-cmd --list-services 2>/dev/null)

if [ -n "$SERVICES" ]; then
    echo "$SERVICES"
else
    pass "No enabled services."
fi

section "Open Ports"

PORTS=$(firewall-cmd --list-ports 2>/dev/null)

if [ -n "$PORTS" ]; then
    echo "$PORTS"
else
    pass "No custom ports."
fi

section "Rich Rules"

RULES=$(firewall-cmd --list-rich-rules 2>/dev/null)

if [ -n "$RULES" ]; then
    echo "$RULES"
else
    pass "No rich rules."
fi

section "Masquerading"

if firewall-cmd --query-masquerade >/dev/null 2>&1; then
    warn "Masquerading enabled."
else
    pass "Masquerading disabled."
fi

section "Forwarding"

if firewall-cmd --query-forward >/dev/null 2>&1; then
    warn "Forwarding enabled."
else
    pass "Forwarding disabled."
fi

section "Listening TCP/UDP Ports"

if command_exists ss; then
    ss -tuln
else
    warn "'ss' command unavailable."
fi

section "Dangerous Ports"

DANGEROUS_PORTS=(21 23 69)
FOUND=0

for PORT in "${DANGEROUS_PORTS[@]}"
do
    if echo "$PORTS" | grep -qw "${PORT}/tcp"; then
        warn "Dangerous TCP Port : $PORT"
        FOUND=1
    fi

    if echo "$PORTS" | grep -qw "${PORT}/udp"; then
        warn "Dangerous UDP Port : $PORT"
        FOUND=1
    fi
done

if [ "$FOUND" -eq 0 ]; then
    pass "No dangerous ports detected."
fi

section "Firewall Backend"

if command_exists nft; then
    pass "nftables available."
else
    warn "nft command missing."
fi

section "Audit Summary"

echo "Passed   : $PASS"
echo "Warnings : $WARN"
echo "Failed   : $FAIL"

echo
echo "Finished Firewall Audit"
echo
