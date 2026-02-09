# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do not open a public issue.** Instead, email the maintainers directly or use GitHub's private vulnerability reporting feature:

1. Go to the **Security** tab of this repository
2. Click **Report a vulnerability**
3. Provide a description of the issue, steps to reproduce, and any potential impact

We will acknowledge receipt within 48 hours and aim to provide a fix or mitigation within 7 days for critical issues.

## Supported Versions

| Version | Supported |
|---------|-----------|
| main    | Yes       |

## Dependency Security

External dependencies are pinned with SHA256 checksums in `MODULE.bazel` to prevent supply chain attacks. When updating dependencies, always verify checksums from the official source (Maven Central).
