# SonarQube Quality Analysis Setup

This guide explains how to set up and run SonarQube quality analysis for the Bazel monorepo.

## What is SonarQube?

SonarQube is an open-source platform for continuous inspection of code quality. It performs automatic reviews with static analysis to detect:

- **Bugs**: Code that is demonstrably wrong
- **Vulnerabilities**: Security weaknesses
- **Code Smells**: Maintainability issues
- **Coverage**: Test coverage gaps
- **Duplications**: Copy-pasted code
- **Complexity**: Code that's hard to understand

## Quick Start

```bash
# 1. Start SonarQube server (Docker - easiest)
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

# 2. Install sonar-scanner
brew install sonar-scanner  # macOS

# 3. Configure authentication (see below for token generation)
export SONAR_TOKEN=your_token_here

# 4. Run analysis
./run_sonarqube_analysis.sh
```

## Installation Options

### Option 1: Docker (Recommended)

**Advantages**: Easy setup, no dependency conflicts, easy to remove

```bash
# Start SonarQube server
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  sonarqube:lts-community

# Wait for server to start (usually 1-2 minutes)
# Check logs: docker logs -f sonarqube

# Access UI at http://localhost:9000
# Default credentials: admin / admin (will prompt to change on first login)
```

**Stop/Start**:
```bash
docker stop sonarqube
docker start sonarqube
```

**Remove**:
```bash
docker stop sonarqube
docker rm sonarqube
```

### Option 2: SonarCloud (Cloud Service)

**Advantages**: No local installation, free for public repositories

1. Sign up at https://sonarcloud.io
2. Import your repository from GitHub/GitLab/Bitbucket
3. Get organization key and project key
4. Generate authentication token
5. Update `sonar-project.properties`:
   ```properties
   sonar.organization=your_org_key
   sonar.host.url=https://sonarcloud.io
   ```
6. Set environment variable:
   ```bash
   export SONAR_TOKEN=your_sonarcloud_token
   ```

### Option 3: Local Installation

**Advantages**: Full control, can customize

**Requirements**:
- Java 17 or higher
- At least 2GB RAM

**Steps**:
```bash
# 1. Download SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip

# 2. Extract
unzip sonarqube-10.3.0.82913.zip
cd sonarqube-10.3.0.82913

# 3. Start server
./bin/macosx-universal-64/sonar.sh start

# Or for Linux:
./bin/linux-x86-64/sonar.sh start

# 4. Access at http://localhost:9000
```

## Installing sonar-scanner CLI

The scanner is the client tool that analyzes your code and sends results to SonarQube server.

### macOS
```bash
brew install sonar-scanner

# Verify installation
sonar-scanner --version
```

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install sonar-scanner

# Or download manually:
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
```

### Manual Installation (All Platforms)
```bash
# Download from https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/

# Extract and add to PATH
export PATH=$PATH:/path/to/sonar-scanner/bin
```

## Configuration

### 1. Start SonarQube Server

```bash
# Docker (recommended)
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

# Wait for server to be ready
# Check: curl http://localhost:9000/api/system/status
```

### 2. Generate Authentication Token

1. Open http://localhost:9000 in browser
2. Login with default credentials: `admin` / `admin`
3. Change password when prompted
4. Navigate to: **User Icon (top right) → My Account → Security**
5. Under "Generate Tokens":
   - Name: `bazel-monorepo-scanner`
   - Type: `User Token`
   - Expiration: `30 days` (or as needed)
   - Click **Generate**
6. **Copy the token immediately** (you won't see it again)

### 3. Set Environment Variables

```bash
# Add to ~/.bashrc, ~/.zshrc, or run before each analysis
export SONAR_HOST_URL=http://localhost:9000
export SONAR_TOKEN=your_generated_token_here

# Verify
echo $SONAR_TOKEN
```

### 4. Configure Project (Already Done)

The project is already configured in `sonar-project.properties`:

```properties
sonar.projectKey=composite_monorepo
sonar.projectName=Bazel Monorepo
sonar.sources=low-level-1/src/main,top-level-1/src/main
sonar.tests=low-level-1/src/test,top-level-1/src/test
sonar.java.source=21
```

## Running Analysis

### Using the Script (Recommended)

```bash
./run_sonarqube_analysis.sh
```

The script will:
1. Check if sonar-scanner is installed
2. Build the project with Bazel
3. Optionally generate coverage data
4. Run SonarQube analysis
5. Display link to results dashboard

### Manual Analysis

```bash
# 1. Build project
bazel build //...

# 2. (Optional) Generate coverage
bazel coverage //... --combined_report=lcov

# 3. Run sonar-scanner
sonar-scanner \
  -Dsonar.host.url=$SONAR_HOST_URL \
  -Dsonar.token=$SONAR_TOKEN
```

### With Coverage Integration

To include test coverage in the analysis:

1. Generate coverage data:
   ```bash
   bazel coverage //... --combined_report=lcov
   ```

2. Update `sonar-project.properties` to uncomment:
   ```properties
   sonar.coverage.jacoco.xmlReportPaths=bazel-out/_coverage/_coverage_report.dat
   sonar.java.coveragePlugin=jacoco
   ```

3. Run analysis:
   ```bash
   ./run_sonarqube_analysis.sh
   ```

## Viewing Results

### Access Dashboard

After analysis completes, open:
```
http://localhost:9000/dashboard?id=composite_monorepo
```

### Understanding the Dashboard

#### Overview Tab
- **Quality Gate Status**: Pass/Fail based on configured thresholds
- **Bugs**: Logic errors that could cause runtime failures
- **Vulnerabilities**: Security issues
- **Code Smells**: Maintainability issues
- **Coverage**: Test coverage percentage
- **Duplications**: Percentage of duplicated code

#### Issues Tab
- Browse all detected issues
- Filter by severity: Blocker, Critical, Major, Minor, Info
- Filter by type: Bug, Vulnerability, Code Smell
- Assign issues to team members

#### Measures Tab
- Detailed metrics:
  - **Reliability**: Bug count and rating (A-E)
  - **Security**: Vulnerability count and rating (A-E)
  - **Maintainability**: Code smell count and rating (A-E)
  - **Coverage**: Line coverage, branch coverage
  - **Duplications**: Duplicated blocks and lines
  - **Size**: Lines of code, statements, files

#### Code Tab
- Browse source code with inline issues
- See which lines have issues
- View technical debt (time to fix issues)

## Quality Metrics Explained

### Bug
Code that is demonstrably wrong or highly likely to yield unexpected behavior.

**Example**: Null pointer dereference, resource leak, logic error

**Severity Levels**:
- **Blocker**: Bug with high probability to crash in production
- **Critical**: Bug with low probability to crash or security flaw
- **Major**: Bug with low impact on productivity

### Vulnerability
A point in code that's open to attack.

**Example**: SQL injection, XSS, hardcoded credentials

**OWASP Top 10** coverage included.

### Code Smell
Maintainability issue that increases technical debt.

**Example**:
- Overly complex methods
- Duplicated code
- Long parameter lists
- Inconsistent naming

**Technical Debt**: Estimated time to fix all code smells

### Coverage
Percentage of code executed by tests.

**Metrics**:
- **Line Coverage**: % of executable lines covered
- **Branch Coverage**: % of branches (if/else) covered
- **Condition Coverage**: % of boolean conditions tested

### Duplication
Identical or very similar code blocks.

**Why it matters**: Changes must be made in multiple places, increasing bug risk.

### Complexity
Cyclomatic complexity - number of paths through code.

**Thresholds**:
- 1-10: Simple, easy to test
- 11-20: Moderate complexity
- 21-50: Complex, hard to test
- 50+: Unmaintainable

## Quality Gates

Quality Gates define pass/fail conditions for your code.

### Default Quality Gate

SonarQube's built-in "Sonar way" gate fails if:
- Coverage < 80%
- Duplications > 3%
- Maintainability rating < A
- Reliability rating < A
- Security rating < A

### Custom Quality Gate

Create custom gates in SonarQube UI:
1. **Quality Gates → Create**
2. Set conditions like:
   - New bugs > 0
   - New vulnerabilities > 0
   - Coverage on new code < 90%
3. Assign to project

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/sonarqube.yml`:

```yaml
name: SonarQube Analysis

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  sonarqube:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for better analysis

      - name: Set up Java 21
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '21'

      - name: Install Bazel
        uses: bazelbuild/setup-bazelisk@v2

      - name: Build with Bazel
        run: bazel build //...

      - name: Generate coverage
        run: bazel coverage //... --combined_report=lcov

      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}

      - name: SonarQube Quality Gate
        uses: sonarsource/sonarqube-quality-gate-action@master
        timeout-minutes: 5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**Setup**:
1. Add repository secrets in GitHub: Settings → Secrets → Actions
   - `SONAR_TOKEN`: Your SonarQube token
   - `SONAR_HOST_URL`: `http://your-sonarqube-server:9000` or `https://sonarcloud.io`

### GitLab CI

Create `.gitlab-ci.yml`:

```yaml
sonarqube:
  image: openjdk:21-jdk
  stage: test
  script:
    - apt-get update && apt-get install -y wget unzip
    - wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
    - unzip sonar-scanner-cli-5.0.1.3006-linux.zip
    - export PATH=$PATH:$(pwd)/sonar-scanner-5.0.1.3006-linux/bin
    - bazel build //...
    - bazel coverage //... --combined_report=lcov
    - sonar-scanner
  variables:
    SONAR_TOKEN: $SONAR_TOKEN
    SONAR_HOST_URL: $SONAR_HOST_URL
  only:
    - main
    - merge_requests
```

## Expected Results for This Repository

Based on the current codebase, you should see:

### Quality Metrics
- **Bugs**: 0 (simple code, no logic errors)
- **Vulnerabilities**: 0 (no security issues)
- **Code Smells**: 0-2 (minor issues possible)
  - Possible: System.out usage instead of logger
  - Possible: Public main methods
- **Coverage**: 100% (all code tested)
- **Duplications**: 0% (no duplicated code)
- **Lines of Code**: ~20-25 lines

### Ratings
- **Maintainability**: A (excellent)
- **Reliability**: A (no bugs)
- **Security**: A (no vulnerabilities)

### Quality Gate
- ✅ Should PASS all conditions

## Troubleshooting

### Issue: "sonar-scanner: command not found"
**Solution**: Install sonar-scanner (see Installation section)

### Issue: "SonarQube server cannot be reached"
**Problem**: Server not running or wrong URL

**Solution**:
```bash
# Check if server is running
curl http://localhost:9000/api/system/status

# Should return: {"status":"UP"}

# If using Docker, check container:
docker ps | grep sonarqube

# If stopped, start it:
docker start sonarqube
```

### Issue: "Unauthorized: You're not authorized to run analysis"
**Problem**: Invalid or missing authentication token

**Solution**:
1. Generate new token in SonarQube UI
2. Set environment variable:
   ```bash
   export SONAR_TOKEN=your_new_token
   ```
3. Re-run analysis

### Issue: "Project not found"
**Problem**: Project doesn't exist in SonarQube

**Solution**: SonarQube auto-creates projects on first analysis. If using SonarCloud, create project first in UI.

### Issue: "Java sources not found"
**Problem**: Incorrect source paths in sonar-project.properties

**Solution**: Verify paths in `sonar-project.properties`:
```bash
# List source files
ls -R low-level-1/src/main/java/
ls -R top-level-1/src/main/java/
```

### Issue: "Coverage report not found"
**Problem**: Coverage data not generated or wrong path

**Solution**:
1. Generate coverage first:
   ```bash
   bazel coverage //... --combined_report=lcov
   ```
2. Verify file exists:
   ```bash
   ls -la bazel-out/_coverage/_coverage_report.dat
   ```
3. Update path in `sonar-project.properties`

### Issue: "Shallow clone detected"
**Problem**: Git history needed for better analysis

**Solution**:
```bash
# For CI/CD, use full clone:
git clone --depth=full <repo-url>

# Or in GitHub Actions:
- uses: actions/checkout@v3
  with:
    fetch-depth: 0
```

### Issue: Docker container keeps restarting
**Problem**: Not enough memory allocated to Docker

**Solution**:
1. Increase Docker memory: Docker Desktop → Settings → Resources → Memory (4GB+)
2. Or use environment variable:
   ```bash
   docker run -d \
     --name sonarqube \
     -p 9000:9000 \
     -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
     sonarqube:lts-community
   ```

## Advanced Configuration

### Exclude Files from Analysis

Add to `sonar-project.properties`:
```properties
# Exclude generated files
sonar.exclusions=**/bazel-**/**,**/*.bzl,**/BUILD,**/WORKSPACE

# Exclude test utilities
sonar.test.exclusions=**/*Test.java,**/test/**/*Helper.java
```

### Set Custom Quality Gate

In SonarQube UI:
1. **Quality Gates → Create**
2. Name: `Bazel Monorepo Gate`
3. Add conditions:
   - Overall Coverage: < 80% → Fail
   - New Bugs: > 0 → Fail
   - New Vulnerabilities: > 0 → Fail
4. **Projects → composite_monorepo → Project Settings → Quality Gate**
5. Select `Bazel Monorepo Gate`

### Branch Analysis

Analyze feature branches:
```bash
sonar-scanner \
  -Dsonar.branch.name=feature/my-feature \
  -Dsonar.token=$SONAR_TOKEN
```

**Note**: Branch analysis requires SonarQube Developer Edition or SonarCloud

### Pull Request Analysis

Analyze PRs before merging:
```bash
sonar-scanner \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature/my-feature \
  -Dsonar.pullrequest.base=main \
  -Dsonar.token=$SONAR_TOKEN
```

## Best Practices

1. **Run analysis on every commit** (via CI/CD)
2. **Fix bugs and vulnerabilities immediately**
3. **Track technical debt** - allocate time to reduce code smells
4. **Monitor coverage trends** - don't let it drop
5. **Use Quality Gates** - block merges that fail quality standards
6. **Review new issues** - address them before they accumulate
7. **Keep rules up-to-date** - enable new rules as SonarQube evolves

## Resources

- **SonarQube Documentation**: https://docs.sonarqube.org/latest/
- **SonarQube Rules**: https://rules.sonarsource.com/java/
- **SonarCloud**: https://sonarcloud.io/
- **Scanner Documentation**: https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/

## Next Steps

1. Start SonarQube server (Docker recommended)
2. Install sonar-scanner CLI
3. Generate authentication token
4. Run `./run_sonarqube_analysis.sh`
5. Review results at http://localhost:9000
6. Set up CI/CD integration for automatic analysis
7. Configure custom quality gates based on team standards

## Summary

SonarQube provides comprehensive code quality analysis including:
- Static code analysis for bugs and vulnerabilities
- Code coverage integration
- Technical debt tracking
- Quality gates for CI/CD
- Trend analysis over time

For this Bazel monorepo, SonarQube should confirm the excellent code quality already demonstrated by 100% test coverage and adherence to best practices.
