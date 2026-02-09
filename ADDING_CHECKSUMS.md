# Adding SHA256 Checksums to WORKSPACE

## Problem

The current WORKSPACE file is missing `sha256` checksums for `http_jar` dependencies. This causes:
1. **Security risk**: Downloads can be tampered with (MITM attacks)
2. **DEBUG warnings**: Bazel warns about missing integrity checksums
3. **Non-reproducible builds**: No verification that the same JAR is downloaded every time

## Solution

Add `sha256` checksums to all `http_jar` rules in the WORKSPACE file.

## How to Get Checksums

### Method 1: From Maven Central (when online)

```bash
# Example for junit-jupiter-api
curl -sL "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.10.1/junit-jupiter-api-5.10.1.jar.sha256"
```

Or run the provided script:
```bash
bash get_checksums.sh
```

### Method 2: Let Bazel Tell You

1. Add a dummy/incorrect `sha256` to the `http_jar` rule
2. Run `bazel build //...`
3. Bazel will fail and tell you the correct checksum

Example output:
```
Error downloading: Checksum was 1234abcd... but wanted 9999eeee...
```

Use the "Checksum was..." value in your WORKSPACE file.

### Method 3: Download and Calculate Manually

```bash
# Download the JAR
curl -LO "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.10.1/junit-jupiter-api-5.10.1.jar"

# Calculate SHA256
shasum -a 256 junit-jupiter-api-5.10.1.jar
# or on Linux:
sha256sum junit-jupiter-api-5.10.1.jar
```

## Expected Checksums for JUnit 5.10.1

When you have network access, fetch these checksums and update the WORKSPACE file:

```python
http_jar(
    name = "junit_jupiter_api",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.10.1/junit-jupiter-api-5.10.1.jar",
)

http_jar(
    name = "junit_jupiter_engine",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/5.10.1/junit-jupiter-engine-5.10.1.jar",
)

http_jar(
    name = "junit_platform_commons",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-commons/1.10.1/junit-platform-commons-1.10.1.jar",
)

http_jar(
    name = "junit_platform_engine",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-engine/1.10.1/junit-platform-engine-1.10.1.jar",
)

http_jar(
    name = "junit_platform_launcher",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-launcher/1.10.1/junit-platform-launcher-1.10.1.jar",
)

http_jar(
    name = "opentest4j",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/opentest4j/opentest4j/1.3.0/opentest4j-1.3.0.jar",
)

http_jar(
    name = "apiguardian",
    sha256 = "<CHECKSUM_HERE>",  # Fetch from Maven Central
    url = "https://repo1.maven.org/maven2/org/apiguardian/apiguardian-api/1.1.2/apiguardian-api-1.1.2.jar",
)
```

## Quick Fix (Automated)

Run this command when you have internet access:

```bash
# This will fetch all checksums and update the WORKSPACE file
bash get_checksums.sh > checksums.txt

# Then manually copy the checksums into WORKSPACE, or use this automated approach:
cat checksums.txt
```

## Why This Matters

1. **Security**: Ensures downloaded dependencies haven't been tampered with
2. **Reproducibility**: Guarantees the same binary is used across all builds
3. **Best Practice**: Required for production-grade Bazel setups
4. **Bazel Warnings**: Eliminates DEBUG warnings about missing integrity checks

## Related Files

- `WORKSPACE` - Main configuration file that needs checksums
- `get_checksums.sh` - Helper script to fetch checksums from Maven Central
- `BEST_PRACTICES_REPORT.md` - See "Priority 1" recommendations
