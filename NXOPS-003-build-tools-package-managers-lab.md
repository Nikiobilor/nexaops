# NXOPS-003 — Build Tools & Package Managers Lab
### NexaOps DevOps Bootcamp · Module 3 · Foundation Track

> **Scenario:** NexaOps Ltd is onboarding three new microservices written by different teams, one in Java, one in Node.js, and one in Python. As the DevOps engineer, you do not write the application code, but you are responsible for understanding how each service is built, what its dependencies are, and how to produce a deployable artifact from source. Your manager has raised a ticket: document and automate the build process for all three services before they can be containerised in Module 4.

---

## Table of Contents

1. [How to use this lab](#1-how-to-use-this-lab)
2. [Prerequisites](#2-prerequisites)
3. [The three NexaOps microservices](#3-the-three-nexaops-microservices)
4. [Task 1 — Java with Maven](#4-task-1--java-with-maven)
5. [Task 2 — Node.js with npm](#5-task-2--nodejs-with-npm)
6. [Task 3 — Python with pip](#6-task-3--python-with-pip)
7. [Task 4 — Comparing build tools across languages](#7-task-4--comparing-build-tools-across-languages)
8. [Task 5 — Automate all three builds with a shell script](#8-task-5--automate-all-three-builds-with-a-shell-script)
9. [Document your work — commands.md](#9-document-your-work--commandsmd)
10. [Push to GitHub](#10-push-to-github)
11. [Acceptance criteria checklist](#11-acceptance-criteria-checklist)
12. [LinkedIn post template](#12-linkedin-post-template)
13. [Interview questions — 5 scenario-based questions](#13-interview-questions--5-scenario-based-questions)
14. [Troubleshooting](#14-troubleshooting)
15. [What you learned](#15-what-you-learned)

---

## 1. How to use this lab

This lab has **5 tasks**. The first three each focus on one language and its build toolchain. Task 4 draws comparisons across all three. Task 5 ties everything together with automation, a DevOps mindset applied from the start.

| Task | Language | Tool | Interview topic |
|---|---|---|---|
| Task 1 | Java | Maven | "How do you build a Java app without an IDE?" |
| Task 2 | Node.js | npm | "What is the difference between dependencies and devDependencies?" |
| Task 3 | Python | pip + venv | "How do you manage Python dependencies across environments?" |
| Task 4 | All three | Comparison | "What is a build tool and why does DevOps care about them?" |
| Task 5 | All three | Bash | "How would you automate builds across multiple services?" |

**Key mindset for this module:**
As a DevOps engineer you are not expected to write application code, but you must understand how it is built. You are the person who writes the CI pipeline that runs these builds automatically. If you do not understand `mvn package` or `npm install`, you cannot write a GitHub Actions pipeline that runs them reliably.

---

## 2. Prerequisites

### Install Java (OpenJDK 17)

```bash
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk

# Verify
java -version
javac -version
```

### Install Maven

```bash
sudo apt-get install -y maven

# Verify
mvn -version
```

### Install Node.js and npm

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

### Install Python and pip

```bash
sudo apt-get install -y python3 python3-pip python3-venv

# Verify
python3 --version
pip3 --version
```

### Install tree (for viewing folder structures)

```bash
sudo apt-get install -y tree
```

### Create your lab folder

```bash
mkdir -p ~/nexaops-build-tools-lab
cd ~/nexaops-build-tools-lab
git init
git config user.name "Your Name"
git config user.email "your@email.com"
```

---

## 3. The Three NexaOps Microservices

NexaOps Ltd has three backend services. Each is a minimal but realistic application:

| Service | Language | Purpose | Build tool |
|---|---|---|---|
| `user-service` | Java | Manages user accounts — a REST API | Maven |
| `notification-service` | Node.js | Sends email/SMS alerts | npm |
| `report-service` | Python | Generates usage reports | pip + venv |

All three live in the same repository under separate folders, a common monorepo pattern at startups.

```
nexaops-build-tools-lab/
├── user-service/         ← Java / Maven
├── notification-service/ ← Node.js / npm
├── report-service/       ← Python / pip
├── build-all.sh          ← Task 5 automation script
└── commands.md           ← Your documentation
```

---

## 4. Task 1 — Java with Maven

### Scenario

The Java team handed you the source code for the `user-service`. They told you to "just run Maven to build it." You have never used Maven before. Your job is to understand what Maven does, build the service, and understand the output artifact.

### Questions to answer before you look at the steps

- What is Maven and what problem does it solve?
- What is a `pom.xml` and what does it contain?
- What is the difference between `mvn compile`, `mvn test`, and `mvn package`?
- What is a JAR file and what does it contain?
- Where does Maven download dependencies from?

---

### Step 1 — Create the Maven project structure

Maven uses a strict folder structure. Create it manually so you understand it:

```bash
mkdir -p ~/nexaops-build-tools-lab/user-service/src/main/java/com/nexaops/userservice
mkdir -p ~/nexaops-build-tools-lab/user-service/src/test/java/com/nexaops/userservice
cd ~/nexaops-build-tools-lab/user-service
tree 
```

Your structure should look like this:

```
user-service/
└── src/
    ├── main/
    │   └── java/
    │       └── com/nexaops/userservice/
    └── test/
        └── java/
            └── com/nexaops/userservice/
```

This is the **Maven Standard Directory Layout** — Maven expects code in `src/main/java` and tests in `src/test/java`. If your files are anywhere else, Maven will not find them.

---

### Step 2 — Create the pom.xml

`pom.xml` (Project Object Model) is Maven's configuration file. It defines what your project is, what it depends on, and how to build it.

```bash
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <!-- Project identity -->
  <groupId>com.nexaops</groupId>
  <artifactId>user-service</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <name>NexaOps User Service</name>
  <description>Manages user accounts for NexaOps Ltd</description>

  <!-- Java version -->
  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <!-- External dependencies -->
  <dependencies>

    <!-- JUnit 5 for testing -->
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.10.0</version>
      <scope>test</scope>
    </dependency>

    <!-- Jackson for JSON processing -->
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.15.2</version>
    </dependency>

  </dependencies>

  <build>
    <plugins>
      <!-- Surefire plugin to run JUnit 5 tests -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.1.2</version>
      </plugin>
    </plugins>
  </build>

</project>
EOF
```

---

### Step 3 — Create the Java source code

```bash
cat > src/main/java/com/nexaops/userservice/User.java << 'EOF'
package com.nexaops.userservice;

/**
 * Represents a NexaOps user account.
 */
public class User {

    private String id;
    private String name;
    private String email;
    private String role;

    public User(String id, String name, String email, String role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
    }

    public String getId()    { return id; }
    public String getName()  { return name; }
    public String getEmail() { return email; }
    public String getRole()  { return role; }

    @Override
    public String toString() {
        return String.format("User{id='%s', name='%s', email='%s', role='%s'}",
                id, name, email, role);
    }
}
EOF
```

```bash
cat > src/main/java/com/nexaops/userservice/UserService.java << 'EOF'
package com.nexaops.userservice;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Core business logic for managing NexaOps user accounts.
 */
public class UserService {

    private final List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
        System.out.println("[UserService] Added user: " + user.getName());
    }

    public Optional<User> findByEmail(String email) {
        return users.stream()
                .filter(u -> u.getEmail().equalsIgnoreCase(email))
                .findFirst();
    }

    public List<User> getAllUsers() {
        return new ArrayList<>(users);
    }

    public int getUserCount() {
        return users.size();
    }

    public static void main(String[] args) {
        System.out.println("=== NexaOps User Service v1.0.0 ===");

        UserService service = new UserService();

        service.addUser(new User("u001", "Alice Okafor",
                "alice@nexaops.com", "admin"));
        service.addUser(new User("u002", "Bob Mensah",
                "bob@nexaops.com", "engineer"));
        service.addUser(new User("u003", "Chidi Eze",
                "chidi@nexaops.com", "engineer"));

        System.out.println("\nAll users (" + service.getUserCount() + "):");
        service.getAllUsers().forEach(System.out::println);

        System.out.println("\nLookup by email:");
        service.findByEmail("bob@nexaops.com")
               .ifPresent(u -> System.out.println("Found: " + u));

        System.out.println("\nService running. Ready to accept requests.");
    }
}
EOF
```

---

### Step 4 — Create a unit test

```bash
cat > src/test/java/com/nexaops/userservice/UserServiceTest.java << 'EOF'
package com.nexaops.userservice;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class UserServiceTest {

    private UserService service;

    @BeforeEach
    void setUp() {
        service = new UserService();
        service.addUser(new User("u001", "Alice Okafor",
                "alice@nexaops.com", "admin"));
        service.addUser(new User("u002", "Bob Mensah",
                "bob@nexaops.com", "engineer"));
    }

    @Test
    void testGetUserCount() {
        assertEquals(2, service.getUserCount(),
                "Should have 2 users after setup");
    }

    @Test
    void testFindByEmailReturnsCorrectUser() {
        var user = service.findByEmail("alice@nexaops.com");
        assertTrue(user.isPresent(), "User should be found");
        assertEquals("Alice Okafor", user.get().getName());
    }

    @Test
    void testFindByEmailCaseInsensitive() {
        var user = service.findByEmail("BOB@NEXAOPS.COM");
        assertTrue(user.isPresent(), "Email lookup should be case-insensitive");
    }

    @Test
    void testFindByEmailNotFound() {
        var user = service.findByEmail("nobody@nexaops.com");
        assertFalse(user.isPresent(), "Non-existent user should not be found");
    }
}
EOF
```

---

### Step 5 — Run the Maven build lifecycle

Now run each phase and observe what happens:

```bash
cd ~/nexaops-build-tools-lab/user-service

# Phase 1: Compile source code only
mvn compile
```

Check what was created:

```bash
ls -la target/classes/com/nexaops/userservice/
# You will see .class files — compiled Java bytecode
```

```bash
# Phase 2: Compile and run tests
mvn test
```

You will see test results, all 4 tests should pass.

```bash
# Phase 3: Package into a JAR file
mvn package
```

```bash
# See what was produced
ls -lh target/
# You will see: user-service-1.0.0.jar
```

```bash
# Run the JAR file
java -cp target/user-service-1.0.0.jar com.nexaops.userservice.UserService
```

---

### Step 6 — Understand the Maven lifecycle

The Maven build lifecycle has phases that run in order. Each phase runs everything before it:

```
validate → compile → test → package → verify → install → deploy
```

| Phase | What it does |
|---|---|
| `validate` | Checks project structure is correct |
| `compile` | Compiles `src/main/java` → `.class` files in `target/classes` |
| `test` | Compiles and runs `src/test/java` |
| `package` | Bundles compiled classes into a JAR in `target/` |
| `install` | Copies the JAR to your local Maven cache (`~/.m2`) |
| `deploy` | Uploads the JAR to a remote repository (e.g. Nexus, Artifactory) |

```bash
# Skip tests if you just want a fast build (common in CI for speed)
mvn package -DskipTests

# Clean the target folder and rebuild from scratch
mvn clean package

# See where Maven stores downloaded dependencies
ls ~/.m2/repository/
```

---

### Step 7 — Understand the .m2 local repository

```bash
# See the Jackson dependency you declared in pom.xml
ls ~/.m2/repository/com/fasterxml/jackson/core/

# Maven downloads each dependency once and caches it here
# In CI/CD pipelines, this cache is often preserved between runs for speed
du -sh ~/.m2/repository/
```

---

### Step 8 — Create a .gitignore for the Java project

```bash
cat > .gitignore << 'EOF'
# Maven build output — never commit compiled artifacts
target/

# IDE files
.idea/
*.iml
.classpath
.project
.settings/

# OS files
.DS_Store
EOF
```

```bash
# Commit the Java service
cd ~/nexaops-build-tools-lab
git add user-service/
git commit -m "feat(user-service): add Java Maven service with unit tests"
```

---

### ✅ Task 1 — Answers

**What is Maven and what problem does it solve?**
Maven is a build automation tool for Java projects. Before Maven, developers had to manually download JAR files, manage classpaths, and write build scripts. Maven standardises the build process, you declare what your project needs in `pom.xml` and Maven handles downloading dependencies, compiling, testing, and packaging automatically. This matters in DevOps because your CI pipeline runs `mvn package` not a person, consistency is everything.

**What is a `pom.xml`?**
Project Object Model — the heart of every Maven project. It declares the project's identity (groupId, artifactId, version), its dependencies, the Java version, and any build plugins. Maven reads this file to know exactly how to build your project.

**`mvn compile` vs `mvn test` vs `mvn package`?**
`compile` converts source code to bytecode. `test` also compiles test code and runs it, if any test fails, the build fails. `package` does all of the above and bundles the bytecode into a deployable JAR. Each phase includes everything before it.

**What is a JAR file?**
A Java ARchive — a ZIP file containing compiled `.class` files, resources, and a manifest. It is the deployable artifact. In production, you run `java -jar app.jar`, not the source code.

**Where does Maven download dependencies from?**
Maven Central Repository by default (`https://repo.maven.apache.org/maven-central`). It downloads each dependency once and caches it in `~/.m2/repository`. In enterprise environments, teams run a private repository (Nexus, Artifactory) that proxies Maven Central and hosts internal libraries.

---

## 5. Task 2 — Node.js with npm

### Scenario

The Node.js team handed you the `notification-service`. They told you to run `npm install` and then `npm start`. You need to understand what npm does, what `package.json` controls, and the difference between production and development dependencies.

### Questions to answer before you look at the steps

- What is npm and what does it manage?
- What is `package.json` and what is `package-lock.json`?
- What is the difference between `dependencies` and `devDependencies`?
- What is `node_modules` and why should you never commit it?
- What does `npm run build` do versus `npm start`?

---

### Step 1 — Create the project structure

```bash
mkdir -p ~/nexaops-build-tools-lab/notification-service
cd ~/nexaops-build-tools-lab/notification-service
```

---

### Step 2 — Initialise the npm project

```bash
# Interactive initialisation — press Enter to accept defaults
npm init

# Or non-interactive with defaults
npm init -y
```

This creates `package.json`. Open it and look at what was generated.

Now manually update `package.json` to reflect the NexaOps service:

```bash
cat > package.json << 'EOF'
{
  "name": "nexaops-notification-service",
  "version": "1.0.0",
  "description": "Sends email and SMS notifications for NexaOps Ltd",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest --coverage",
    "build": "echo 'No transpilation needed for this service'",
    "lint": "eslint src/"
  },
  "keywords": ["nexaops", "notifications", "devops"],
  "author": "NexaOps Platform Team",
  "license": "MIT",
  "dependencies": {
    "axios": "^1.6.0",
    "dotenv": "^16.3.1",
    "express": "^4.18.2"
  },
  "devDependencies": {
    "eslint": "^8.53.0",
    "jest": "^29.7.0",
    "nodemon": "^3.0.1"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF
```

---

### Step 3 — Understand dependencies vs devDependencies

| Type | Key | When installed | Examples |
|---|---|---|---|
| Production | `dependencies` | Always — `npm install` and `npm install --production` | express, axios, dotenv |
| Development | `devDependencies` | Only on dev — `npm install` (NOT `--production`) | jest, eslint, nodemon |

```bash
# Install ALL dependencies (dev + production) — use during development
npm install

# Install ONLY production dependencies — use when building for deployment
npm install --production

# Check what was installed
ls node_modules/ | head -20

# See the dependency tree
npm list --depth=0
```

---

### Step 4 — Create the application code

```bash
mkdir -p src

cat > src/index.js << 'EOF'
/**
 * NexaOps Notification Service v1.0.0
 * Handles email and SMS alerts for the NexaOps platform.
 */

const NotificationService = require('./notificationService');

const service = new NotificationService();

// Simulate sending notifications on startup
async function main() {
  console.log('=== NexaOps Notification Service v1.0.0 ===');
  console.log('Initialising...\n');

  await service.sendEmail({
    to: 'ops-team@nexaops.com',
    subject: 'Service health check passed',
    body: 'All systems operational as of ' + new Date().toUTCString()
  });

  await service.sendSMS({
    to: '+2348012345678',
    message: 'NexaOps alert: Deployment completed successfully'
  });

  console.log('\nNotification queue processed.');
  console.log(`Total notifications sent: ${service.getSentCount()}`);
}

main().catch(console.error);
EOF
```

```bash
cat > src/notificationService.js << 'EOF'
/**
 * Core notification logic.
 * In production this would integrate with SendGrid, Twilio etc.
 * For this lab it simulates sending with console output.
 */

class NotificationService {
  constructor() {
    this.sentCount = 0;
    this.history = [];
  }

  async sendEmail({ to, subject, body }) {
    // Validate inputs
    if (!to || !subject || !body) {
      throw new Error('Email requires to, subject, and body fields');
    }

    // Simulate async network call
    await this._simulate();

    const notification = {
      type: 'email',
      to,
      subject,
      sentAt: new Date().toISOString()
    };

    this.history.push(notification);
    this.sentCount++;

    console.log(`[EMAIL] To: ${to}`);
    console.log(`        Subject: ${subject}`);
    console.log(`        Status: sent ✓`);
    return notification;
  }

  async sendSMS({ to, message }) {
    if (!to || !message) {
      throw new Error('SMS requires to and message fields');
    }

    await this._simulate();

    const notification = {
      type: 'sms',
      to,
      message,
      sentAt: new Date().toISOString()
    };

    this.history.push(notification);
    this.sentCount++;

    console.log(`[SMS]   To: ${to}`);
    console.log(`        Message: ${message}`);
    console.log(`        Status: sent ✓`);
    return notification;
  }

  getSentCount() {
    return this.sentCount;
  }

  getHistory() {
    return [...this.history];
  }

  _simulate() {
    return new Promise(resolve => setTimeout(resolve, 50));
  }
}

module.exports = NotificationService;
EOF
```

---

### Step 5 — Create a test file

```bash
cat > src/notificationService.test.js << 'EOF'
const NotificationService = require('./notificationService');

describe('NotificationService', () => {
  let service;

  beforeEach(() => {
    service = new NotificationService();
  });

  test('sendEmail increments sent count', async () => {
    await service.sendEmail({
      to: 'test@nexaops.com',
      subject: 'Test',
      body: 'Test body'
    });
    expect(service.getSentCount()).toBe(1);
  });

  test('sendSMS increments sent count', async () => {
    await service.sendSMS({
      to: '+234801234567',
      message: 'Test alert'
    });
    expect(service.getSentCount()).toBe(1);
  });

  test('sending both email and SMS counts correctly', async () => {
    await service.sendEmail({ to: 'a@b.com', subject: 'Hi', body: 'Hello' });
    await service.sendSMS({ to: '+1234', message: 'Alert' });
    expect(service.getSentCount()).toBe(2);
  });

  test('sendEmail throws if fields are missing', async () => {
    await expect(
      service.sendEmail({ to: 'a@b.com' })
    ).rejects.toThrow('Email requires to, subject, and body fields');
  });

  test('getHistory returns all sent notifications', async () => {
    await service.sendEmail({ to: 'a@b.com', subject: 'Hi', body: 'Hello' });
    const history = service.getHistory();
    expect(history).toHaveLength(1);
    expect(history[0].type).toBe('email');
  });
});
EOF
```

---

### Step 6 — Run npm scripts

```bash
cd ~/nexaops-build-tools-lab/notification-service

# Run the service
npm start

# Run the tests
npm test

# Run tests with coverage report
npm test -- --coverage
```

Observe the coverage report, it shows what percentage of your code is tested.

---

### Step 7 — Understand package-lock.json

```bash
# Compare the two files
wc -l package.json
wc -l package-lock.json

# package-lock.json is much larger — it locks every dependency
# including nested dependencies, to exact versions

# package.json says: "I need express ~4.18.2 (approximately)"
# package-lock.json says: "Install express 4.18.2 exactly, 
# which requires accepts 1.3.8, which requires mime-types 2.1.35..."

grep '"express"' package.json
grep '"express"' package-lock.json | head -5
```

**Critical rule:** Always commit `package-lock.json`. Never commit `node_modules/`.

---

### Step 8 — Create a .gitignore for Node.js

```bash
cat > .gitignore << 'EOF'
# Never commit node_modules — it can be 100MB+
# Anyone cloning runs "npm install" to recreate it
node_modules/

# Test coverage output
coverage/

# Environment files
.env
.env.local

# OS files
.DS_Store

# Logs
npm-debug.log*
EOF
```

```bash
cd ~/nexaops-build-tools-lab
git add notification-service/
git commit -m "feat(notification-service): add Node.js npm service with Jest tests"
```

---

### ✅ Task 2 — Answers

**What is npm?**
Node Package Manager — the default package manager for Node.js. It installs, updates, and removes JavaScript packages (libraries), and runs scripts defined in `package.json`. There are alternatives (yarn, pnpm) but npm ships with Node.js and is the most common.

**`package.json` vs `package-lock.json`?**
`package.json` is written by you — it declares what your project needs with version ranges (e.g. `^4.18.2` means "4.18.2 or higher compatible version"). `package-lock.json` is generated automatically by npm — it records the exact version of every package that was actually installed, including nested dependencies. This ensures every developer and every CI run installs identical versions.

**`dependencies` vs `devDependencies`?**
`dependencies` are needed at runtime in production — e.g. `express` (your web server). `devDependencies` are only needed during development — e.g. `jest` (test runner), `eslint` (linter), `nodemon` (auto-restart during development). When building a production Docker image, you run `npm install --production` to exclude dev tools and keep the image lean.

**Why never commit `node_modules/`?**
It can contain tens of thousands of files and be hundreds of megabytes. It is always reproducible from `package-lock.json` by running `npm install`. Committing it bloats your repo, slows clones, and creates noise in diffs.

**`npm run build` vs `npm start`?**
`npm start` runs the application. `npm run build` runs whatever build command you defined in the `scripts.build` field — for TypeScript projects this would be the TypeScript compiler (`tsc`), for React it would be `webpack` or `vite`. For plain Node.js like this lab, no build step is needed. In a CI pipeline you always run `npm run build` before `npm start` for compiled languages.

---

## 6. Task 3 — Python with pip

### Scenario

The data team handed you the `report-service` written in Python. They told you to "set up a virtual environment and install the requirements." You need to understand Python dependency management, virtual environments, and how to produce a distributable package.

### Questions to answer before you look at the steps

- What is pip and what does it manage?
- What is a virtual environment and why is it essential?
- What is `requirements.txt` and how is it generated?
- What is the difference between `requirements.txt` and `requirements-dev.txt`?
- What does `pip freeze` do?

---

### Step 1 — Create the project structure

```bash
mkdir -p ~/nexaops-build-tools-lab/report-service/src
mkdir -p ~/nexaops-build-tools-lab/report-service/tests
cd ~/nexaops-build-tools-lab/report-service
```

---

### Step 2 — Create and activate a virtual environment

Without a virtual environment, pip installs packages globally, this causes version conflicts between projects on the same machine.

```bash
# Create a virtual environment called "venv" in the project folder
python3 -m venv venv

# See what was created
ls venv/
# bin/ (executables), lib/ (packages), include/ (headers)

# Activate the virtual environment
source venv/bin/activate

# Your prompt changes to show (venv) — you are now isolated
# Check which Python is being used
which python3
# Should show: .../report-service/venv/bin/python3

# Check pip version inside the venv
pip --version
```

> **Important:** Every time you open a new terminal to work on this project, run `source venv/bin/activate` first.

---

### Step 3 — Install dependencies

```bash
# Make sure venv is active (you should see (venv) in your prompt)

# Install production dependencies
pip install requests==2.31.0
pip install tabulate==0.9.0
pip install python-dateutil==2.8.2

# Install development/testing dependencies
pip install pytest==7.4.3
pip install pytest-cov==4.1.0

# See what is installed
pip list
```

---

### Step 4 — Generate requirements files

```bash
# Freeze ALL installed packages (prod + dev) to a file
pip freeze > requirements-dev.txt

# View it
cat requirements-dev.txt
```

Now create a production-only requirements file manually:

```bash
cat > requirements.txt << 'EOF'
requests==2.31.0
tabulate==0.9.0
python-dateutil==2.8.2
EOF
```

```bash
# In a clean environment (like CI or Docker), this is how you install from it:
pip install -r requirements.txt
```

---

### Step 5 — Create the application code

```bash
cat > src/report_service.py << 'EOF'
"""
NexaOps Report Service v1.0.0
Generates usage reports for NexaOps Ltd services.
"""

from datetime import datetime, timedelta
from tabulate import tabulate


class ReportService:
    """Generates usage and incident reports for NexaOps services."""

    def __init__(self):
        self.services = [
            "API Gateway",
            "Authentication Service",
            "Database Cluster",
            "Payment Service",
            "File Storage",
            "Notification Service",
        ]

    def generate_uptime_report(self) -> dict:
        """Generate a mock uptime report for all services."""
        import random
        random.seed(42)  # Fixed seed for reproducible output in tests

        report = {
            "generated_at": datetime.utcnow().isoformat() + "Z",
            "period": "Last 30 days",
            "services": []
        }

        for service in self.services:
            uptime = round(random.uniform(99.1, 99.99), 2)
            incidents = random.randint(0, 3)
            report["services"].append({
                "name": service,
                "uptime_percent": uptime,
                "incidents": incidents,
                "status": "healthy" if uptime >= 99.5 else "degraded"
            })

        return report

    def format_report_table(self, report: dict) -> str:
        """Format the report as a readable table."""
        headers = ["Service", "Uptime %", "Incidents", "Status"]
        rows = [
            [
                s["name"],
                f"{s['uptime_percent']}%",
                s["incidents"],
                s["status"].upper()
            ]
            for s in report["services"]
        ]
        table = tabulate(rows, headers=headers, tablefmt="grid")
        return f"\nNexaOps Uptime Report — {report['period']}\n{table}\n"

    def get_service_count(self) -> int:
        return len(self.services)

    def get_healthy_services(self, report: dict) -> list:
        return [s for s in report["services"] if s["status"] == "healthy"]


if __name__ == "__main__":
    print("=== NexaOps Report Service v1.0.0 ===")
    service = ReportService()
    report = service.generate_uptime_report()
    print(service.format_report_table(report))
    healthy = service.get_healthy_services(report)
    print(f"Healthy services: {len(healthy)} / {service.get_service_count()}")
EOF
```

---

### Step 6 — Create tests

```bash
cat > tests/test_report_service.py << 'EOF'
"""Tests for NexaOps Report Service."""

import pytest
from src.report_service import ReportService


class TestReportService:

    def setup_method(self):
        """Create a fresh service instance before each test."""
        self.service = ReportService()

    def test_service_count(self):
        assert self.service.get_service_count() == 6

    def test_uptime_report_structure(self):
        report = self.service.generate_uptime_report()
        assert "generated_at" in report
        assert "period" in report
        assert "services" in report
        assert len(report["services"]) == 6

    def test_each_service_has_required_fields(self):
        report = self.service.generate_uptime_report()
        for s in report["services"]:
            assert "name" in s
            assert "uptime_percent" in s
            assert "incidents" in s
            assert "status" in s

    def test_uptime_values_are_valid_percentages(self):
        report = self.service.generate_uptime_report()
        for s in report["services"]:
            assert 0 <= s["uptime_percent"] <= 100

    def test_format_report_returns_string(self):
        report = self.service.generate_uptime_report()
        formatted = self.service.format_report_table(report)
        assert isinstance(formatted, str)
        assert "NexaOps Uptime Report" in formatted

    def test_get_healthy_services_returns_list(self):
        report = self.service.generate_uptime_report()
        healthy = self.service.get_healthy_services(report)
        assert isinstance(healthy, list)
        for s in healthy:
            assert s["status"] == "healthy"
EOF
```

---

### Step 7 — Run the service and tests

```bash
cd ~/nexaops-build-tools-lab/report-service

# Make sure venv is active
source venv/bin/activate

# Run the service
python3 src/report_service.py

# Run tests
python3 -m pytest tests/ -v

# Run tests with coverage report
python3 -m pytest tests/ -v --cov=src --cov-report=term-missing
```

---

### Step 8 — Create a setup.py (Python package definition)

`setup.py` is how Python projects are distributed — equivalent to `pom.xml` for Java or `package.json` for Node.js.

```bash
cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="nexaops-report-service",
    version="1.0.0",
    description="Generates usage reports for NexaOps Ltd",
    author="NexaOps Platform Team",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.9",
    install_requires=[
        "requests>=2.31.0",
        "tabulate>=0.9.0",
        "python-dateutil>=2.8.2",
    ],
)
EOF
```

```bash
# Build a distributable package (creates dist/ folder)
pip install build
python3 -m build

ls dist/
# nexaops_report_service-1.0.0.tar.gz  ← source distribution
# nexaops_report_service-1.0.0.whl     ← wheel (binary distribution)
```

---

### Step 9 — Create a .gitignore for Python

```bash
cat > .gitignore << 'EOF'
# Virtual environment — never commit this
venv/
.venv/
env/

# Build output
dist/
build/
*.egg-info/

# Python cache files
__pycache__/
*.pyc
*.pyo

# Test coverage
.coverage
htmlcov/

# Environment files
.env

# OS files
.DS_Store
EOF
```

```bash
# Deactivate the virtual environment
deactivate

cd ~/nexaops-build-tools-lab
git add report-service/
git commit -m "feat(report-service): add Python pip service with pytest tests"
```

---

### ✅ Task 3 — Answers

**What is pip?**
pip (Package Installer for Python) is Python's package manager. It downloads and installs packages from PyPI (Python Package Index) — the Python equivalent of npm's registry or Maven Central. You use it to add, update, or remove libraries your code depends on.

**What is a virtual environment and why is it essential?**
A virtual environment is an isolated Python installation scoped to a single project. Without it, all Python packages install globally, if Project A needs `requests==2.28` and Project B needs `requests==2.31`, they conflict and one of them breaks. A virtual environment gives each project its own private `site-packages` folder. In DevOps, Docker handles this isolation at the container level, but locally and in CI you use virtual environments.

**What is `requirements.txt` and how is it generated?**
A plain text file listing every dependency and its exact version. Generated by running `pip freeze > requirements.txt` inside an active virtual environment. Anyone cloning the project runs `pip install -r requirements.txt` to install the exact same versions. It is the Python equivalent of `package-lock.json`.

**`requirements.txt` vs `requirements-dev.txt`?**
`requirements.txt` contains only what the app needs to run in production. `requirements-dev.txt` includes everything — production dependencies plus testing tools (`pytest`), linters (`flake8`), formatters (`black`). In Docker builds you use `requirements.txt`; developers use `requirements-dev.txt`.

**What does `pip freeze` do?**
Lists every installed package in the active virtual environment with its exact version, in a format that can be piped directly into a `requirements.txt` file. It captures the entire dependency tree, not just what you installed directly, but also the packages those packages depend on.

---

## 7. Task 4 — Comparing build tools across languages

### Scenario

Your manager asks you to present a one-page comparison of the three build tools you just worked with. This will be used to onboard the next batch of junior engineers.

### Side-by-side comparison

Run these commands to see the parallels:

```bash
# Where is the project config defined?
cat ~/nexaops-build-tools-lab/user-service/pom.xml | grep -A2 "<version>"
cat ~/nexaops-build-tools-lab/notification-service/package.json | grep "version"
cat ~/nexaops-build-tools-lab/report-service/setup.py | grep "version"

# Where are dependencies declared?
cat ~/nexaops-build-tools-lab/user-service/pom.xml | grep -A3 "<dependency>"
cat ~/nexaops-build-tools-lab/notification-service/package.json | grep -A5 '"dependencies"'
cat ~/nexaops-build-tools-lab/report-service/requirements.txt

# Where is the build output?
ls ~/nexaops-build-tools-lab/user-service/target/
ls ~/nexaops-build-tools-lab/notification-service/node_modules/ | head -5
ls ~/nexaops-build-tools-lab/report-service/dist/ 2>/dev/null || echo "Run python3 -m build first"
```

### The comparison table

| Concept | Java / Maven | Node.js / npm | Python / pip |
|---|---|---|---|
| Config file | `pom.xml` | `package.json` | `setup.py` / `pyproject.toml` |
| Lock file | `pom.xml` (versions pinned) | `package-lock.json` | `requirements.txt` |
| Dependency registry | Maven Central | npmjs.com | PyPI (pypi.org) |
| Local cache | `~/.m2/repository` | `node_modules/` | `venv/lib/` |
| Install command | `mvn install` | `npm install` | `pip install -r requirements.txt` |
| Build command | `mvn package` | `npm run build` | `python3 -m build` |
| Run tests | `mvn test` | `npm test` | `pytest` |
| Output artifact | `.jar` file | `.js` files / bundles | `.whl` / `.tar.gz` |
| Skip tests | `mvn package -DskipTests` | `npm test -- --passWithNoTests` | `pytest --ignore=tests/` |
| Clean build | `mvn clean package` | `rm -rf node_modules && npm install` | `rm -rf venv && python3 -m venv venv` |
| What NOT to commit | `target/` | `node_modules/` | `venv/`, `dist/`, `__pycache__/` |

### Why does this matter for DevOps?

In a CI/CD pipeline (which you will build in Module 5), you write steps like:

```yaml
# Java service
- run: mvn clean package -DskipTests

# Node.js service
- run: npm ci
- run: npm test

# Python service
- run: pip install -r requirements.txt
- run: pytest tests/
```

You cannot write these steps if you do not understand what they do. A DevOps engineer who understands build tools can debug a failing CI pipeline. One who does not is stuck waiting for a developer to fix it.

Note: `npm ci` vs `npm install` — `npm ci` is the CI-safe version. It deletes `node_modules` and reinstalls from `package-lock.json` exactly. Use it in pipelines; use `npm install` locally.

---

## 8. Task 5 — Automate all three builds with a shell script

### Scenario

You need to write a script that builds all three NexaOps services in one command. This simulates what a CI/CD system does — it does not know or care about the specifics of each service, it just runs each build in sequence and reports pass or fail.

### Step 1 — Create the build script

```bash
cat > ~/nexaops-build-tools-lab/build-all.sh << 'EOF'
#!/usr/bin/env bash
# =============================================================================
# NexaOps Build Script — builds all three microservices
# Ticket: NXOPS-003 | Module 3: Build Tools & Package Managers
# Usage: ./build-all.sh [--skip-tests]
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# ── Config ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_TESTS=false
PASS_COUNT=0
FAIL_COUNT=0
START_TIME=$(date +%s)

# ── Argument parsing ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --skip-tests) SKIP_TESTS=true ;;
    --help|-h)
      echo "Usage: $0 [--skip-tests]"
      echo "  --skip-tests   Build without running tests (faster)"
      exit 0
      ;;
  esac
done

# ── Helper functions ──────────────────────────────────────────────────────────
log_step() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  $1${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

pass() {
  echo -e "${GREEN}  ✔ $1${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo -e "${RED}  ✘ $1${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

# ── Build functions ───────────────────────────────────────────────────────────

build_java() {
  log_step "Building user-service (Java / Maven)"
  cd "${SCRIPT_DIR}/user-service"

  if [[ "${SKIP_TESTS}" == true ]]; then
    echo -e "${YELLOW}  Skipping tests (--skip-tests flag set)${NC}"
    if mvn clean package -DskipTests -q; then
      pass "user-service built successfully"
      echo "  Artifact: $(ls -lh target/*.jar | awk '{print $5, $9}')"
    else
      fail "user-service build failed"
    fi
  else
    if mvn clean package -q; then
      pass "user-service built and tested successfully"
      echo "  Artifact: $(ls -lh target/*.jar | awk '{print $5, $9}')"
    else
      fail "user-service build/test failed"
    fi
  fi
}

build_nodejs() {
  log_step "Building notification-service (Node.js / npm)"
  cd "${SCRIPT_DIR}/notification-service"

  echo "  Installing dependencies..."
  if npm ci --silent; then
    pass "npm dependencies installed"
  else
    fail "npm install failed"
    return
  fi

  if [[ "${SKIP_TESTS}" == false ]]; then
    echo "  Running tests..."
    if npm test -- --silent 2>/dev/null; then
      pass "notification-service tests passed"
    else
      fail "notification-service tests failed"
    fi
  else
    echo -e "${YELLOW}  Skipping tests (--skip-tests flag set)${NC}"
    pass "notification-service dependencies installed (no tests run)"
  fi
}

build_python() {
  log_step "Building report-service (Python / pip)"
  cd "${SCRIPT_DIR}/report-service"

  echo "  Creating virtual environment..."
  python3 -m venv venv
  # shellcheck disable=SC1091
  source venv/bin/activate

  echo "  Installing dependencies..."
  if pip install -r requirements.txt -q; then
    pass "pip dependencies installed"
  else
    fail "pip install failed"
    deactivate
    return
  fi

  if [[ "${SKIP_TESTS}" == false ]]; then
    pip install pytest pytest-cov -q
    echo "  Running tests..."
    if python3 -m pytest tests/ -q; then
      pass "report-service tests passed"
    else
      fail "report-service tests failed"
    fi
  else
    echo -e "${YELLOW}  Skipping tests (--skip-tests flag set)${NC}"
    pass "report-service dependencies installed (no tests run)"
  fi

  deactivate
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}NexaOps Build Pipeline${NC}"
  echo -e "Running at: $(date '+%Y-%m-%d %H:%M:%S UTC')"
  if [[ "${SKIP_TESTS}" == true ]]; then
    echo -e "${YELLOW}Mode: build only (tests skipped)${NC}"
  else
    echo "Mode: build + test"
  fi

  build_java
  build_nodejs
  build_python

  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))

  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  Build Summary${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${GREEN}PASSED: ${PASS_COUNT}${NC}   ${RED}FAILED: ${FAIL_COUNT}${NC}   Time: ${DURATION}s"
  echo ""

  if [[ ${FAIL_COUNT} -gt 0 ]]; then
    echo -e "${RED}Build pipeline failed. See errors above.${NC}"
    exit 1
  else
    echo -e "${GREEN}All services built successfully.${NC}"
    exit 0
  fi
}

main "$@"
EOF

chmod +x ~/nexaops-build-tools-lab/build-all.sh
```

### Step 2 — Run the build script

```bash
cd ~/nexaops-build-tools-lab

# Full build with tests
./build-all.sh

# Build only (no tests — faster, useful for quick iteration)
./build-all.sh --skip-tests

# Help flag
./build-all.sh --help
```

### Step 3 — Commit the script

```bash
git add build-all.sh
git commit -m "feat(ci): add build-all.sh to automate all three service builds

Builds user-service (Maven), notification-service (npm),
and report-service (pip) in sequence.
Supports --skip-tests flag for faster builds.
Ticket: NXOPS-003"
```

---

## 9. Document your work — commands.md

```markdown
# NexaOps Build Tools Lab — Commands Reference
## NXOPS-003 | Module 3: Build Tools & Package Managers

---

## Setup

| Command | What it does |
|---|---|
| `sudo apt-get install -y openjdk-17-jdk` | Install Java 17 |
| `sudo apt-get install -y maven` | Install Maven build tool |
| `sudo apt-get install -y nodejs` | Install Node.js runtime |
| `sudo apt-get install -y python3-pip python3-venv` | Install Python pip and venv |

## Task 1 — Java / Maven

| Command | What it does |
|---|---|
| `mvn compile` | Compile source code to .class bytecode |
| `mvn test` | Compile and run all unit tests |
| `mvn package` | Compile, test, and bundle into a JAR file |
| `mvn clean package` | Delete target/ and rebuild from scratch |
| `mvn package -DskipTests` | Build without running tests |
| `mvn install` | Build and copy JAR to local ~/.m2 cache |
| `java -cp target/app.jar com.nexaops.Main` | Run a class from the JAR |

## Task 2 — Node.js / npm

| Command | What it does |
|---|---|
| `npm init -y` | Initialise package.json with defaults |
| `npm install` | Install all dependencies (prod + dev) |
| `npm install --production` | Install only production dependencies |
| `npm ci` | Clean install from package-lock.json — use in CI |
| `npm start` | Run the start script from package.json |
| `npm test` | Run the test script from package.json |
| `npm run <script>` | Run any named script from package.json |
| `npm list --depth=0` | Show installed top-level packages |

## Task 3 — Python / pip

| Command | What it does |
|---|---|
| `python3 -m venv venv` | Create an isolated virtual environment |
| `source venv/bin/activate` | Activate the virtual environment |
| `deactivate` | Exit the virtual environment |
| `pip install requests==2.31.0` | Install a specific version of a package |
| `pip install -r requirements.txt` | Install all packages from requirements file |
| `pip freeze > requirements.txt` | Save all installed packages to a file |
| `pip list` | Show all installed packages |
| `python3 -m pytest tests/ -v` | Run tests verbosely |
| `python3 -m build` | Build a distributable .whl and .tar.gz package |

## Task 5 — Automation

| Command | What it does |
|---|---|
| `./build-all.sh` | Build and test all three services |
| `./build-all.sh --skip-tests` | Build all services without running tests |
```

---

## 10. Push to GitHub

```bash
cd ~/nexaops-build-tools-lab

# Final status check
git status

# View your commit history
git log --oneline

# Create repo on GitHub: nexaops-build-tools-lab (public)
git remote add origin https://github.com/<YOUR_USERNAME>/nexaops-build-tools-lab.git
git branch -M main
git push -u origin main
```

Your final repo structure:

```
nexaops-build-tools-lab/
├── user-service/               ← Java / Maven
│   ├── pom.xml
│   ├── src/main/java/...
│   ├── src/test/java/...
│   └── .gitignore
├── notification-service/       ← Node.js / npm
│   ├── package.json
│   ├── package-lock.json
│   ├── src/
│   └── .gitignore
├── report-service/             ← Python / pip
│   ├── requirements.txt
│   ├── requirements-dev.txt
│   ├── setup.py
│   ├── src/
│   ├── tests/
│   └── .gitignore
├── build-all.sh                ← automation script
└── commands.md
```

---

## 11. Acceptance criteria checklist

- [ ] `user-service` builds with `mvn clean package` and all 4 tests pass
- [ ] `notification-service` installs with `npm ci` and all 5 Jest tests pass
- [ ] `report-service` installs with `pip install -r requirements.txt` and all 6 pytest tests pass
- [ ] `build-all.sh` runs successfully and prints a build summary
- [ ] `build-all.sh --skip-tests` runs without errors
- [ ] No build artifacts committed — `target/`, `node_modules/`, `venv/`, `dist/`, `__pycache__/` all in `.gitignore`
- [ ] `package-lock.json` IS committed (unlike `node_modules/`)
- [ ] `requirements.txt` IS committed (unlike `venv/`)
- [ ] `commands.md` documents every command with an explanation
- [ ] GitHub repo `nexaops-build-tools-lab` is public with meaningful commit history

---

## 12. LinkedIn post template

> For **Engineer C (lead)**. Personalise before posting.

```
Week 3 of our DevOps bootcamp — and this one changed how I think about code.

As DevOps engineers, we don't write the app — but we own how it gets built.
This week I worked with all three major build toolchains in one lab:

☕ Java + Maven — pom.xml, mvn clean package, JAR artifacts, ~/.m2 cache
📦 Node.js + npm — package.json, npm ci, dependencies vs devDependencies
🐍 Python + pip — virtual environments, requirements.txt, pip freeze, .whl packages

And then tied it all together with a bash script (build-all.sh) that builds
and tests all three services in one command — simulating what a CI pipeline does.

Key insight: you can't write a reliable CI/CD pipeline if you don't understand
what mvn package, npm ci, and pip install -r requirements.txt actually do.

Repo link in comments.

[tag your 2 teammates]
#DevOps #CloudEngineering #Java #Maven #NodeJS #npm #Python #pip
#LearningInPublic #100DaysOfDevOps
```

---

## 13. Interview questions — 5 scenario-based questions

### Q1 — Build tools basics (very common)

**Scenario:** A developer says "just build my app." You look at the repo and see a `pom.xml`. What does that tell you, and what command do you run?

Sub-questions:
- What language and build tool does `pom.xml` indicate?
- What single command compiles the code, runs tests, AND produces a deployable artifact?
- What folder is the artifact in after a successful build?

**Bonus:** What is the Maven build lifecycle and what phase runs before `package`?

<details>
<summary>Reveal answer</summary>

`pom.xml` tells you this is a Java project using Maven. The command is `mvn clean package` — `clean` removes any previous build output, `package` compiles, tests, and produces the JAR. The artifact lands in `target/` with a name like `appname-1.0.0.jar`.

The Maven lifecycle phases in order: `validate → compile → test → package → verify → install → deploy`. Running `package` automatically runs everything before it including `compile` and `test`. If any test fails, the build fails.
</details>

---

### Q2 — npm and dependencies (very common)

**Scenario:** You are writing a Dockerfile for a Node.js service. The developer says "make sure it has all the dependencies." You look at `package.json` and see both `dependencies` and `devDependencies`. Which do you install in the Docker image?

Sub-questions:
- What is the difference between `dependencies` and `devDependencies`?
- Which npm command should you use in a Docker build or CI pipeline instead of `npm install`?
- Why should you never commit `node_modules/` to Git?

**Bonus:** What does `package-lock.json` do and what breaks if you delete it?

<details>
<summary>Reveal answer</summary>

In a production Docker image, install only `dependencies` using `npm install --production` or `npm ci --only=production`. `devDependencies` like jest, eslint, and nodemon are not needed at runtime and add unnecessary size to the image.

Use `npm ci` (not `npm install`) in Docker builds and CI pipelines — it does a clean install from `package-lock.json` exactly, ensuring reproducible builds. `npm install` may update versions within ranges.

`node_modules/` can contain 50,000+ files and be 200MB+. It is always reproducible from `package-lock.json` so it should never be in Git.

Deleting `package-lock.json` means npm resolves dependency versions fresh on next install — different machines at different times may get different versions, breaking the "works on my machine" guarantee.
</details>

---

### Q3 — Python virtual environments (common)

**Scenario:** A junior engineer runs `pip install flask` on the team server and breaks another Python application that was running there. What went wrong and how do you prevent it?

Sub-questions:
- What is a virtual environment and why does it solve this problem?
- What are the commands to create, activate, and deactivate a virtual environment?
- What should be committed to Git — `venv/` or `requirements.txt`?

**Bonus:** What is the difference between `pip install -r requirements.txt` and `pip install -r requirements-dev.txt`?

<details>
<summary>Reveal answer</summary>

The engineer installed Flask globally, overwriting or conflicting with a version that the other app depended on. Virtual environments solve this by giving each project a completely isolated Python installation with its own packages.

Create: `python3 -m venv venv`. Activate: `source venv/bin/activate`. Deactivate: `deactivate`. When active, `pip install` only affects that project's environment.

Commit `requirements.txt`, never `venv/`. The venv directory contains compiled binaries that are OS-specific and can be 100MB+. Anyone cloning the repo recreates it with `python3 -m venv venv && pip install -r requirements.txt`.

`requirements.txt` has only production packages. `requirements-dev.txt` has everything including test tools. In production and Docker builds you use `requirements.txt`; developers working locally use `requirements-dev.txt`.
</details>

---

### Q4 — Artifacts and what NOT to commit (very common)

**Scenario:** A new team member commits the `target/` folder from a Maven build to the GitHub repo. Why is this a problem?

Sub-questions:
- What is a build artifact and why should it not be in source control?
- Name the build output folder for all three tools in this lab and confirm all three are in `.gitignore`.
- What is the correct way to share build artifacts between teams?

**Bonus:** What files SHOULD be committed for each build tool, and why?

<details>
<summary>Reveal answer</summary>

Build artifacts are generated output — they are always reproducible from source code. Committing them causes: (1) repo bloat — JARs can be 50MB+, (2) false history — the artifact changes every build even when source has not, (3) security risk — compiled artifacts can contain embedded config or secrets, (4) conflicts — binary files cannot be diff'd or merged.

Build output folders to gitignore: `target/` (Maven), `node_modules/` and `dist/` (npm), `venv/`, `dist/`, `build/`, `__pycache__/` (Python).

Artifacts are shared via artifact repositories: Nexus or Artifactory for JAR files, npm registry for npm packages, PyPI or a private package server for Python wheels. In CI/CD, artifacts are uploaded as pipeline artifacts or to S3, not to Git.

Files to commit: `pom.xml` (Maven), `package.json` and `package-lock.json` (npm), `requirements.txt` and `setup.py` (Python). These are the recipes that reproduce the build.
</details>

---

### Q5 — CI pipeline thinking (common for DevOps roles)

**Scenario:** You need to write a CI pipeline that builds all three NexaOps services when code is pushed to main. What commands go in each service's build step?

Sub-questions:
- Write the build commands for each service (Java, Node.js, Python)
- What is the difference between `npm install` and `npm ci` in a pipeline?
- How do you make the pipeline fail fast if one service's tests fail?

**Bonus:** Why might you want to run `mvn package -DskipTests` in some pipeline stages but not others?

<details>
<summary>Reveal answer</summary>

Java step: `mvn clean package` — clean removes stale artifacts, package compiles tests and produces the JAR.

Node.js step: `npm ci` then `npm test` — `npm ci` does a reproducible clean install from the lock file, which is essential in CI where the environment is fresh each time.

Python step: `pip install -r requirements.txt` then `python3 -m pytest tests/`.

`npm install` vs `npm ci`: `npm install` may modify `package-lock.json` if it finds better resolutions, and skips the clean step. `npm ci` always deletes `node_modules` first and installs exactly what is in `package-lock.json`. Use `npm ci` in pipelines — it is faster, stricter, and reproducible.

The pipeline fails fast naturally if you use `set -e` or the CI system's default behaviour — a non-zero exit code from `mvn package` (which exits non-zero when tests fail) stops the pipeline. You can also add `--fail-fast` flags.

`-DskipTests` is used in multi-stage pipelines where tests run in a dedicated stage. For example: build stage (`mvn package -DskipTests`) produces the artifact fast, test stage (`mvn test`) runs tests in parallel, deploy stage uses the artifact from the build stage. This parallelises the pipeline.
</details>

---

## 14. Troubleshooting

**`mvn: command not found`**
Run `sudo apt-get install -y maven`. Verify with `mvn -version`.

**`java.lang.UnsupportedClassVersionError` when running the JAR**
Your runtime Java version is lower than the version used to compile. Check `java -version` and `javac -version` — they should both show Java 17. If not: `sudo apt-get install -y openjdk-17-jdk` then `sudo update-alternatives --config java`.

**`npm ci` fails with `npm ERR! Missing: ...`**
Your `package-lock.json` is out of sync with `package.json`. Run `npm install` locally to regenerate the lock file, commit it, then retry `npm ci`.

**`ModuleNotFoundError` in Python**
Your virtual environment is not active. Run `source venv/bin/activate` and try again. Check it is active by running `which python3` — it should point inside your `venv/` folder.

**`pip install` installs globally even with venv**
The venv is not activated. `source venv/bin/activate` — note the `source` keyword is required (not just `./venv/bin/activate`).

**`build-all.sh` fails with permission denied**
Run `chmod +x build-all.sh` to make it executable.

**Maven downloads dependencies every time in CI**
Configure caching in your CI pipeline to cache `~/.m2/repository`. Without this, Maven re-downloads all dependencies on every pipeline run — slow and wasteful.

**Python `dist/` folder not created**
You need the `build` package: `pip install build` then `python3 -m build`.

---

## 15. What you learned

By completing this lab you have practised:

- **Maven** — `pom.xml` structure, the build lifecycle, compiling/testing/packaging Java, JAR artifacts, the `~/.m2` cache
- **npm** — `package.json` scripts, `dependencies` vs `devDependencies`, `npm ci` vs `npm install`, `package-lock.json`, why `node_modules/` is never committed
- **pip + venv** — virtual environment isolation, `requirements.txt`, `pip freeze`, distributable Python packages with `setup.py`
- **Cross-tool thinking** — mapping equivalent concepts across all three ecosystems (config file, lock file, registry, cache, artifact)
- **What NOT to commit** — `target/`, `node_modules/`, `venv/`, `__pycache__/` and why each one belongs in `.gitignore`
- **Automation mindset** — wrapping three different build systems into one shell script that any CI tool can invoke
- **CI pipeline literacy** — understanding what `mvn clean package`, `npm ci`, and `pip install -r requirements.txt` actually do so you can write reliable pipelines in Module 5

---

## Ticket reference

| Field | Value |
|---|---|
| Ticket ID | NXOPS-003 |
| Module | M3 — Build Tools & Package Managers |
| Phase | 1 — Foundation |
| Assignee (lead) | Engineer C |
| Reviewers | Engineers A & B |
| Estimate | 8–10 hours |
| Prerequisite | NXOPS-001B (Linux), NXOPS-002 (Git) |
| Next module | NXOPS-004 — Docker & Containerisation |

---

*NexaOps DevOps Bootcamp · Built with [Tech World with Nana](https://www.techworld-with-nana.com/) · Facilitated by Claude*
