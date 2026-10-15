# Custom-Lynis-Security-Audit-Scripts

**Firewall Configuration Audit and SSH Protocol Security Audit**

## 1. Project Overview

This project enhances the Linux security auditing capabilities of **Lynis** by introducing two custom Bash scripts. These scripts perform additional security checks on a Fedora Linux system and display the results using PASS, WARNING, and FAIL messages.

The project focuses on two important areas of Linux security:

- **Firewall Security Audit (`CUS-1001`)** — Examines Firewalld configuration, firewall zones, allowed services, open ports, forwarding, and listening network ports.
- **SSH Security Audit (`CUS-1002`)** — Examines OpenSSH installation, service status, authentication settings, access-control directives, and SSH host keys.

The scripts are intended for educational purposes and help users understand Linux system hardening and security auditing.

## 2. Objectives

- Extend Lynis with custom security checks.
- Automate basic firewall and SSH configuration auditing.
- Identify potentially insecure configurations.
- Display clear and readable audit results.
- Summarize the number of passed checks, warnings, and failures.
- Gain practical experience with Bash scripting and Linux security tools.

## 3. Technologies Used

| Technology | Purpose |
|---|---|
| Fedora Linux | Operating system used for testing |
| Lynis | Linux security auditing framework |
| Bash | Scripting language |
| Firewalld | Firewall management |
| OpenSSH | Secure remote access |
| `systemctl` | Service status and startup checks |
| `firewall-cmd` | Firewalld configuration inspection |
| `ss` | Network socket and listening-port inspection |
| `nft` | Checking the availability of the nftables command |

## 4. Repository Structure

```text
custom-lynis-security-audit/
│
├── README.md
├── firewall_audit.sh
└── ssh_audit.sh
```

- `README.md` — Project overview, requirements, installation, and usage instructions.
- `firewall_audit.sh` — Custom Firewall Audit script (`CUS-1001`).
- `ssh_audit.sh` — Custom SSH Security Audit script (`CUS-1002`).

## 5. Enhancement 1: Firewall Configuration Audit

**Test ID:** `CUS-1001`

### Features

The Firewall Audit script performs the following checks:

1. Checks whether the `firewall-cmd` command is available.
2. Checks whether the Firewalld service exists.
3. Verifies whether Firewalld is enabled at boot.
4. Checks whether Firewalld is currently running.
5. Displays the active and default firewall zones.
6. Lists permitted firewall services.
7. Lists explicitly configured open ports.
8. Displays rich rules, if configured.
9. Checks masquerading and forwarding.
10. Displays listening TCP and UDP ports.
11. Checks for listening ports associated with FTP, Telnet, and TFTP.
12. Checks whether the `nft` command is available.
13. Prints a final audit summary.

### Sample output

```text
############################################
# CUSTOM LYNIS TEST : FIREWALL AUDIT
# TEST ID : CUS-1001
############################################

Passed   : 9
Warnings : 1
Failed   : 0

Finished Firewall Audit
```

*The sample represents the recorded audit summary. Actual results depend on the system configuration.*

## 6. Enhancement 2: SSH Protocol Security Audit

**Test ID:** `CUS-1002`

### Features

The SSH Audit script performs the following checks:

1. Checks whether the OpenSSH server package is installed.
2. Checks whether the `sshd` service exists.
3. Verifies whether the SSH service is running.
4. Checks whether SSH is enabled at boot.
5. Examines the configured SSH port.
6. Checks `PermitRootLogin`.
7. Checks `PasswordAuthentication`.
8. Checks `PubkeyAuthentication`.
9. Checks `PermitEmptyPasswords`.
10. Reviews `MaxAuthTries` and `LoginGraceTime`.
11. Examines `ClientAliveInterval` and `ClientAliveCountMax`.
12. Checks `X11Forwarding`.
13. Checks the presence of `AllowUsers`, `AllowGroups`, `DenyUsers`, and `DenyGroups`.
14. Examines the SSH protocol directive.
15. Checks for SSH host keys.
16. Prints a final audit summary.

### Sample output

```text
############################################
# CUSTOM LYNIS TEST : SSH AUDIT
# TEST ID : CUS-1002
############################################

Passed   : 3
Warnings : 8
Failed   : 0

Finished SSH Audit
```

*The sample represents the recorded audit summary. Actual results depend on the system configuration.*

## 7. Requirements

Before running the scripts, ensure that the following are available on your system:

- Fedora Linux or a compatible Linux distribution.
- Bash shell.
- Lynis, if integrating the scripts into Lynis.
- Firewalld and its `firewall-cmd` utility for firewall checks.
- OpenSSH server package for SSH checks.
- `systemctl`, `grep`, `awk`, and other standard command-line utilities.
- `ss` for listening-port checks.
- `nft` for checking nftables command availability.

Some checks may produce warnings when the corresponding software or service is not installed or configured.

## 8. Installation and Usage

### Step 1: Clone the repository

Replace `YOUR_USERNAME` with your GitHub username.

```bash
git clone https://github.com/YOUR_USERNAME/custom-lynis-security-audit.git
cd custom-lynis-security-audit
```

### Step 2: Give execution permission

```bash
chmod +x firewall_audit.sh ssh_audit.sh
```

### Step 3: Run the Firewall Audit

```bash
sudo bash firewall_audit.sh
```

### Step 4: Run the SSH Audit

```bash
sudo bash ssh_audit.sh
```

Review the PASS, WARNING, and FAIL messages. Some configuration details may require elevated privileges to inspect accurately.

## 9. Integrating the Scripts with Lynis

The scripts can be integrated into the Lynis custom-test mechanism, subject to the Lynis version and packaging configuration.

On the tested Fedora setup, the custom test file was:

```text
/usr/share/lynis/include/tests_custom
```

### Integration steps

1. Back up the relevant Lynis configuration or include file before editing.
2. Open the custom test file:

   ```bash
   sudo nano /usr/share/lynis/include/tests_custom
   ```

3. Add the contents of both audit scripts to the file.
4. Save the changes.
5. Run a Lynis system audit:

   ```bash
   sudo lynis audit system
   ```

6. Search the output for the banners `CUS-1001` and `CUS-1002`.

**Important:** Check how your installed Lynis version loads custom tests before modifying other include files. On the tested setup, the custom tests were already being loaded automatically. Manually sourcing the same file a second time caused duplicate execution. Ensure each test is loaded only once.

For a more maintainable implementation, keep the standalone scripts in the repository and adapt them to the custom-test loading mechanism used by your Lynis installation.

## 10. Understanding the Audit Results

The scripts use three result categories:

- **PASS:** A check completed successfully according to the script's criteria.
- **WARNING:** A setting may require review or additional context.
- **FAIL:** A required command, package, service, or security condition did not meet the script's criteria.

The counters summarize the checks performed by the scripts.

A warning does not automatically mean that a system is vulnerable. For example, an inactive SSH server can be appropriate on a desktop computer that does not need remote administration. Likewise, forwarding or masquerading may be necessary on systems acting as routers.

Review each finding according to the intended role of the machine.

## 11. Security Considerations and Limitations

- These scripts are lightweight auditing tools, not replacements for a full Lynis audit or a professional security assessment.
- A configured firewall port is not necessarily reachable from the internet; network interfaces, routing, upstream firewalls, and other controls also affect accessibility.
- Checking for the `nft` command confirms its availability, not that the firewall is correctly configured.
- SSH settings may be affected by included configuration files and directive precedence. A more comprehensive audit should inspect the effective SSH configuration.
- The dangerous-port check is a basic pattern-based check and should be reviewed before relying on it in production.
- The scripts primarily report findings; they do not automatically change firewall rules or SSH configuration.

**Recommendation:** Review the scripts before executing them on production systems, and test configuration changes in a controlled environment.

## 12. Learning Outcomes

This project provides practical experience in:

- Linux security auditing.
- Bash scripting and function creation.
- Conditional statements and command exit statuses.
- Firewall configuration and network-port inspection.
- SSH authentication and access-control settings.
- Lynis custom-test integration.
- Interpreting security warnings and audit summaries.
- Documenting and managing security scripts using GitHub.

## 13. Future Enhancements

Potential improvements include:

1. Validate effective SSH settings using `sshd -T`.
2. Improve detection of risky ports using structured port parsing.
3. Generate timestamped audit reports.
4. Export results in JSON or CSV format.
5. Add severity levels and remediation recommendations.
6. Integrate the scripts into automated security assessment workflows.
7. Add test cases to validate the scripts against different configurations.
8. Improve portability across Linux distributions.

## 14. Conclusion

The Custom Lynis Security Audit project extends basic Linux security checks with dedicated firewall and SSH audits. The Firewall Audit examines firewall status and network configuration, while the SSH Audit reviews important remote-access security settings.

These scripts demonstrate how Bash automation can support system hardening, improve the visibility of security configurations, and produce structured audit summaries.

The project is intended as an educational enhancement to Lynis and can serve as a starting point for more comprehensive Linux security auditing tools.


**Project:** Custom Lynis Security Audit Scripts  
**Test IDs:** `CUS-1001`, `CUS-1002`  
**Platform:** Fedora Linux
