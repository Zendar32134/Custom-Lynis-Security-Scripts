
#!/bin/bash

################################################################################
# Custom Firewall Security Audit
# Test ID: CUST-1010
# Platform: Fedora Linux
################################################################################

PASS=0
WARN=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

warn() {
    echo "[WARNING] $1"
    WARN=$((WARN + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
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
echo "# CUSTOM FIREWALL SECURITY AUDIT"
echo "# TEST ID : CUST-1010"
echo "############################################"

section "Firewall Command Check"

if command_exists firewall-cmd; then
    pass "firewall-cmd command is available."
else
    fail "firewall-cmd command is missing."
fi

section "Firewalld Service Check"

if systemctl list-unit-files --no-legend |
    grep -q '^firewalld\.service'; then
    pass "Firewalld service exists."
else
    fail "Firewalld service not found."
fi

if systemctl is-active --quiet firewalld; then
    pass "Firewalld service is running."
else
    warn "Firewalld service is not running."
fi

if systemctl is-enabled --quiet firewalld; then
    pass "Firewalld is enabled at boot."
else
    warn "Firewalld is not enabled at boot."
fi

if command_exists firewall-cmd; then

    section "Firewall Zones"

    ZONE=$(firewall-cmd --get-active-zones 2>/dev/null |
        head -n 1)

    if [ -n "$ZONE" ]; then
        echo "Active Zone : $ZONE"
    else
        warn "No active firewall zone detected."
    fi

    DEFAULT_ZONE=$(firewall-cmd --get-default-zone 2>/dev/null)

    if [ -n "$DEFAULT_ZONE" ]; then
        echo "Default Zone : $DEFAULT_ZONE"
    fi

    section "Enabled Services"

    firewall-cmd --list-services 2>/dev/null

    section "Open Ports"

    firewall-cmd --list-ports 2>/dev/null

    section "Rich Rules"

    RULES=$(firewall-cmd --list-rich-rules 2>/dev/null)

    if [ -z "$RULES" ]; then
        pass "No rich rules configured."
    else
        echo "$RULES"
    fi

    section "Masquerading"

    if firewall-cmd --query-masquerade >/dev/null 2>&1; then
        warn "Masquerading is enabled."
    else
        pass "Masquerading is disabled."
    fi

    section "Forwarding"

    if firewall-cmd --query-forward >/dev/null 2>&1; then
        warn "Forwarding is enabled."
    else
        pass "Forwarding is disabled."
    fi

fi

section "Listening TCP/UDP Ports"

if command_exists ss; then
    ss -tuln
else
    warn "ss command is not available."
fi

section "Firewall Backend"

if command_exists nft; then
    pass "nftables command is available."
else
    warn "nft command is not available."
fi

section "Audit Summary"

echo "Passed   : $PASS"
echo "Warnings : $WARN"
echo "Failed   : $FAIL"

echo
echo "Finished Firewall Security Audit"
