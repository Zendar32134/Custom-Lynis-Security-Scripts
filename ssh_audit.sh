
#!/bin/bash

################################################################################
# Custom SSH Security Audit
# Test ID: CUST-1020
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

echo
echo "############################################"
echo "# CUSTOM SSH SECURITY AUDIT"
echo "# TEST ID : CUST-1020"
echo "############################################"

section "OpenSSH Installation Check"

if rpm -q openssh-server >/dev/null 2>&1; then
    pass "OpenSSH server is installed."
else
    fail "OpenSSH server is not installed."
fi

section "SSH Service Check"

if systemctl list-unit-files --no-legend |
    grep -q '^sshd\.service'; then
    pass "sshd service exists."
else
    fail "sshd service not found."
fi

if systemctl is-active --quiet sshd; then
    pass "SSH service is running."
else
    warn "SSH service is not running."
fi

if systemctl is-enabled --quiet sshd; then
    pass "SSH service is enabled at boot."
else
    warn "SSH service is not enabled at boot."
fi

section "SSH Configuration Audit"

if command -v sshd >/dev/null 2>&1; then

    # Read the effective SSH configuration.
    SSH_CONFIG=$(sshd -T 2>/dev/null)

    if [ -n "$SSH_CONFIG" ]; then

        pass "Effective SSH configuration is readable."

        # Check root login
        if echo "$SSH_CONFIG" |
            grep -q '^permitrootlogin no$'; then
            pass "Root login is disabled."
        else
            warn "Root login is not disabled."
        fi

        # Check password authentication
        if echo "$SSH_CONFIG" |
            grep -q '^passwordauthentication no$'; then
            pass "Password authentication is disabled."
        else
            warn "Password authentication is enabled."
        fi

        # Check public key authentication
        if echo "$SSH_CONFIG" |
            grep -q '^pubkeyauthentication yes$'; then
            pass "Public-key authentication is enabled."
        else
            warn "Public-key authentication is not enabled."
        fi

        # Check empty passwords
        if echo "$SSH_CONFIG" |
            grep -q '^permitemptypasswords no$'; then
            pass "Empty passwords are disabled."
        else
            warn "Empty passwords are not disabled."
        fi

        # Display configured SSH port
        SSH_PORT=$(echo "$SSH_CONFIG" |
            awk '$1 == "port" {print $2; exit}')

        echo "Configured SSH Port : ${SSH_PORT:-Unknown}"

        # Check maximum authentication attempts
        MAX_AUTH=$(echo "$SSH_CONFIG" |
            awk '$1 == "maxauthtries" {print $2; exit}')

        if [ -n "$MAX_AUTH" ] && [ "$MAX_AUTH" -le 4 ]; then
            pass "Maximum authentication attempts: $MAX_AUTH"
        else
            warn "Maximum authentication attempts require review."
        fi

    else
        warn "Unable to read effective SSH configuration."
        echo "Check sshd configuration and host keys."
    fi

else
    fail "sshd command is not available."
fi

section "SSH Host Keys"

if compgen -G '/etc/ssh/ssh_host_*_key' >/dev/null; then
    pass "SSH host keys are available."
else
    warn "SSH host keys were not found."
fi

section "Audit Summary"

echo "Passed   : $PASS"
echo "Warnings : $WARN"
echo "Failed   : $FAIL"

echo
echo "Finished SSH Security Audit"
