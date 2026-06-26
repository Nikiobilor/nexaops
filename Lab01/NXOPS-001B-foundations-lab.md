# NXOPS-001B — Linux Fundamentals Lab
### NexaOps DevOps Bootcamp · Module 1 · Foundations Track

> **Scenario:** It is your first day at NexaOps Ltd. Your team lead has given you access to a Linux server where the company's application runs. Before you can work on anything, you need to prove you can find your way around, manage files and permissions, investigate running processes, write a basic script, and read application logs like a real engineer.

---

## Table of Contents

1. [How to use this lab](#1-how-to-use-this-lab)
2. [Prerequisites](#2-prerequisites)
3. [Set up your working folder](#3-set-up-your-working-folder)
4. [Task 1 — Linux navigation & files](#4-task-1--linux-navigation--files)
5. [Task 2 — File permissions](#5-task-2--file-permissions)
6. [Task 3 — Process management](#6-task-3--process-management)
7. [Task 4 — Shell scripting basics](#7-task-4--shell-scripting-basics)
8. [Task 5 — Pipes, grep & redirection](#8-task-5--pipes-grep--redirection)
9. [Document your work — commands.md](#9-document-your-work--commandsmd)
10. [Push to GitHub](#10-push-to-github)
11. [Acceptance criteria checklist](#11-acceptance-criteria-checklist)
12. [LinkedIn post template](#12-linkedin-post-template)
13. [Troubleshooting](#13-troubleshooting)
14. [What you learned](#14-what-you-learned)

---

## 1. How to use this lab

This lab has **5 tasks**. Each task maps directly to a real interview question topic for junior DevOps / Cloud Engineer roles. Work through them in order — they build on each other.

| Task | Topic | Interview question it prepares you for |
|---|---|---|
| Task 1 | Navigation & files | "How do you find your way around a Linux server?" |
| Task 2 | File permissions | "A script won't run — how do you fix it?" |
| Task 3 | Process management | "How do you investigate a slow server?" |
| Task 4 | Shell scripting | "Write a script that checks if a file exists" |
| Task 5 | Pipes, grep & redirection | "How do you extract errors from a log file?" |

**For each task:**
1. Read the scenario
2. Try to answer the questions yourself before looking at the answers
3. Run every command in your WSL terminal
4. Write each command and a one-line explanation into `commands.md`

---

## 2. Prerequisites

### WSL2 (Windows users only)

If you are on Windows, you need WSL2 (Windows Subsystem for Linux) to run a Linux terminal.

1. Open **PowerShell as Administrator**
2. Run: `wsl --install`
3. Restart your computer when prompted
4. After restart, Ubuntu opens and asks for a username and password — set these up

> Already on Linux or macOS? Skip this step — open your terminal directly.

### VS Code (recommended)

Download from https://code.visualstudio.com and install the **WSL** extension so you can edit files inside your Linux environment.

### Verify you are ready

Open your Ubuntu/Linux terminal and run:

```bash
# Check you are in Linux
uname -a

# Check git is installed
git --version

# Check your username
whoami
```

---

## 3. Set up your working folder

All your work for this lab lives in one folder. Run these commands now:

```bash
# Create the project folder
mkdir -p ~/nexaops-linux-lab
cd ~/nexaops-linux-lab

# Create the subfolders and files you will need
mkdir -p docs/screenshots
touch commands.md
touch deploy.sh
touch check_log.sh

# Verify the structure
ls -la
```

Open this folder in VS Code:

```bash
code .
```

> Every command you run from this point onwards should be documented in `commands.md` as you go.

---

## 4. Task 1 — Linux navigation & files

### Scenario

You log into the NexaOps server for the first time. You need to find your way around before you can do anything else.

### Questions to answer

> Try each one yourself before reading the answer below.

- How do you find out which directory you are currently in?
- How do you list all files including hidden ones?
- How do you move into a directory called `logs`?
- How do you go back to your home directory from anywhere?

### Step-by-step

**Step 1 — Find your current location**

```bash
pwd
```

`pwd` stands for *print working directory*. It always tells you the full path of where you are, e.g. `/home/yourname`.

---

**Step 2 — List files including hidden ones**

```bash
# Plain list — no hidden files, no details
ls

# Show hidden files (files starting with a dot)
ls -a

# Show hidden files AND full details (permissions, owner, size, date)
ls -la
```

Hidden files start with a dot, like `.bashrc` and `.profile`. You will not see them with plain `ls`. DevOps engineers use `ls -la` most often because permissions matter on every server.

---

**Step 3 — Create a folder structure and practice navigating**

```bash
# Create a logs folder inside your project
mkdir logs

# Move into it
cd logs

# Check where you are
pwd

# Go back up one level
cd ..

# Go back to your home directory from anywhere
cd ~

# Go back to your project folder
cd ~/nexaops-linux-lab
```

---

**Step 4 — Create your test files**

```bash
# Create 3 files at once
touch app.log deploy.sh config.env

# Verify they were created
ls -la
```

---

**Step 5 — Install tree and view the structure**

```bash
# Install tree (only needed once)
sudo apt-get install -y tree

# View your project structure
tree .
```

Your output should look like this:

```
.
├── app.log
├── check_log.sh
├── commands.md
├── config.env
├── deploy.sh
├── docs
│   └── screenshots
└── logs
```

---

### Bonus question

> What is the difference between `ls`, `ls -a`, and `ls -la`? When would a DevOps engineer use each one?

**Answer:**

| Command | What it shows | When to use it |
|---|---|---|
| `ls` | Files and folders only, no hidden, no details | Quick glance at a directory |
| `ls -a` | Everything including hidden files | When checking for config files like `.env` or `.bashrc` |
| `ls -la` | Hidden files AND full details (permissions, owner, size, date) | Almost always — permissions matter on every server |

---

## 5. Task 2 — File permissions

### Scenario

Your team lead reports that `deploy.sh` throws a `Permission denied` error when the team tries to run it. You need to investigate and fix it.

### Questions to answer

- What command shows you the permissions of a file?
- How do you make a file executable?
- What does `chmod 755 deploy.sh` mean in plain English?
- What is the difference between `chmod +x` and `chmod 755`?

### Step-by-step

**Step 1 — Check the current permissions**

```bash
ls -l deploy.sh
```

You will see something like:

```
-rw-r--r-- 1 yourname yourname 0 Jan 15 07:00 deploy.sh
```

The first column `-rw-r--r--` tells you the permissions. Right now nobody can execute this file, which is why it throws `Permission denied`.

---

**Step 2 — Understand what you are reading**

```
- rw- r-- r--
│ │   │   │
│ │   │   └── Others: read only
│ │   └────── Group: read only
│ └────────── Owner: read and write (no execute)
└──────────── File type: - means regular file, d means directory
```

---

**Step 3 — Add execute permission**

```bash
# Add execute for everyone
chmod +x deploy.sh

# Check the result
ls -l deploy.sh
```

You should now see `-rwxr-xr-x` — the `x` bits have been added.

---

**Step 4 — Set permissions precisely with chmod 755**

```bash
chmod 755 deploy.sh
ls -l deploy.sh
```

**What 755 means in plain English:**

Each digit is the sum of: read (4) + write (2) + execute (1)

| Digit | Who | Value | Permissions |
|---|---|---|---|
| 7 | Owner | 4+2+1 | Read, write, and execute |
| 5 | Group | 4+0+1 | Read and execute only |
| 5 | Others | 4+0+1 | Read and execute only |

So: the owner has full control, everyone else can read and run the file but not modify it.

---

**Step 5 — Add content to deploy.sh and run it**

```bash
# Add a line to the script
echo 'echo "NexaOps deploy script running"' > deploy.sh

# Run it
./deploy.sh
```

You should see:

```
NexaOps deploy script running
```

---

**Step 6 — Take a screenshot**

Run `ls -la` and take a screenshot showing the `-rwxr-xr-x` permissions on `deploy.sh`. Save it as `docs/screenshots/permissions.png` — this is one of your acceptance criteria deliverables.

---

### Bonus question

> A file shows `-rw-r--r--`. Who can read it, write to it, and execute it?

**Answer:**

| Who | Read | Write | Execute |
|---|---|---|---|
| Owner | Yes | Yes | No |
| Group | Yes | No | No |
| Others | Yes | No | No |

Nobody can execute this file. This is exactly why `deploy.sh` was throwing `Permission denied`. Fix: `chmod +x deploy.sh` or `chmod 755 deploy.sh`.

---

## 6. Task 3 — Process management

### Scenario

The NexaOps app is responding slowly. Your manager asks you to log in and check what is happening on the server.

### Questions to answer

- How do you see which process is using the most CPU?
- How do you find the PID of a specific process?
- How do you stop a process safely?
- When would you use `kill -9` and why is it a last resort?

### Step-by-step

**Step 1 — View running processes with top**

```bash
top
```

`top` shows a live, updating view of all running processes. The top rows show overall CPU and memory usage. The list below is sorted by CPU usage by default.

Useful keys inside `top`:

| Key | Action |
|---|---|
| `P` | Sort by CPU usage |
| `M` | Sort by memory usage |
| `k` | Kill a process (enter PID when prompted) |
| `q` | Quit top |

---

**Step 2 — Use htop for a cleaner view (optional but recommended)**

```bash
# Install htop
sudo apt-get install -y htop

# Run it
htop
```

`htop` shows colour-coded bars for CPU and memory and is easier to read than `top`.

---

**Step 3 — List all processes with ps**

```bash
# Show all running processes with details
ps aux

# Count how many processes are running
ps aux | wc -l
```

The columns in `ps aux` output:

| Column | Meaning |
|---|---|
| USER | Who owns the process |
| PID | Process ID |
| %CPU | CPU usage |
| %MEM | Memory usage |
| COMMAND | The command that started the process |

---

**Step 4 — Find the PID of a specific process**

```bash
# Find your current bash session PID
echo $$

# Find a process by name (e.g. bash)
pgrep bash

# Find with full details
ps aux | grep bash
```

---

**Step 5 — Understand kill signals**

```bash
# Safe stop — sends SIGTERM (asks process to stop cleanly)
kill <PID>

# Force stop — sends SIGKILL (OS terminates immediately, no cleanup)
kill -9 <PID>

# Kill by name instead of PID
pkill bash
```

> Never use `kill -9` as your first option. Always try `kill <PID>` first and only escalate to `kill -9` if the process is completely frozen and not responding.

---

### Bonus question

> What is the difference between `kill`, `kill -9`, and `pkill`?

**Answer:**

| Command | Signal | Behaviour |
|---|---|---|
| `kill <PID>` | SIGTERM (15) | Politely asks the process to stop. The process can clean up open files and connections first. |
| `kill -9 <PID>` | SIGKILL (9) | Forces the OS to terminate the process immediately. Cannot be caught or ignored. May leave lock files behind. |
| `pkill <name>` | SIGTERM (15) | Kills by process name instead of PID. Useful when you do not know the PID. |

---

## 7. Task 4 — Shell scripting basics

### Scenario

Your team wants to automate a morning check: verify that the application log file exists before the app starts. If it does not exist, create it.

### Questions to answer

- What does `#!/usr/bin/env bash` mean at the top of a script?
- How do you check if a file exists in bash?
- How do you make the script executable and run it?
- What does `set -e` do?

### Step-by-step

**Step 1 — Open check_log.sh in VS Code**

Click `check_log.sh` in the VS Code sidebar, or run:

```bash
code check_log.sh
```

---

**Step 2 — Write the script**

Paste this into `check_log.sh`:

```bash
#!/usr/bin/env bash
set -e

# NexaOps log file check
# Checks if app.log exists. Creates it if not.

LOG_FILE="app.log"

if [ -f "$LOG_FILE" ]; then
  echo "File exists: $LOG_FILE"
else
  touch "$LOG_FILE"
  echo "File created: $LOG_FILE"
fi
```

---

**Step 3 — Understand what each line does**

| Line | What it does |
|---|---|
| `#!/usr/bin/env bash` | Shebang — tells the OS to use bash to run this script |
| `set -e` | Exit immediately if any command fails |
| `LOG_FILE="app.log"` | Stores the filename in a variable so you only write it once |
| `[ -f "$LOG_FILE" ]` | Checks if the path exists and is a regular file |
| `touch "$LOG_FILE"` | Creates an empty file if it does not exist |

---

**Step 4 — Make it executable and run it**

```bash
# Make executable
chmod +x check_log.sh

# Run it (app.log should already exist from Task 1)
./check_log.sh

# Delete app.log and run again to test the other branch
rm app.log
./check_log.sh

# Run it a third time — should say "File exists" again
./check_log.sh
```

You should see:

```
File exists: app.log
File created: app.log
File exists: app.log
```

---

**Step 5 — What is set -e doing?**

Without `set -e`, if a command in your script fails, the script keeps running. This can cause serious problems in automation — imagine a deploy script that keeps running after it fails to connect to the database.

Test it:

```bash
# Remove set -e and add a bad command
bash -c 'badcommand; echo "This line still runs without set -e"'

# Add set -e and see the difference
bash -c 'set -e; badcommand; echo "This line never runs with set -e"'
```

---

### Bonus question

> What is the difference between `#!/bin/bash` and `#!/usr/bin/env bash`?

**Answer:**

| Shebang | How it works | Problem |
|---|---|---|
| `#!/bin/bash` | Hardcodes the exact path to bash | Fails if bash is installed elsewhere (some Docker containers, macOS with Homebrew) |
| `#!/usr/bin/env bash` | Searches for bash in the system PATH | More portable — works across different Linux distributions and macOS |

**Use `#!/usr/bin/env bash` in all your professional scripts.**

---

## 8. Task 5 — Pipes, grep & redirection

### Scenario

Something went wrong overnight. Your manager asks you to check the application logs and send a summary of all errors — without opening the file in any editor.

### Questions to answer

- How do you search for a word in a log file?
- How do you count how many times a word appears?
- How do you save results to a new file without opening an editor?
- What does the pipe `|` character do?

### Step-by-step

**Step 1 — Populate app.log with realistic test data**

```bash
cat > app.log << 'EOF'
2024-01-15 07:00:01 INFO  App started successfully
2024-01-15 07:01:03 INFO  Connected to database
2024-01-15 07:02:11 WARN  Response time above threshold: 850ms
2024-01-15 07:03:44 ERROR Failed to write to disk: permission denied
2024-01-15 07:04:02 INFO  Retry attempt 1 of 3
2024-01-15 07:04:30 INFO  Retry attempt 2 of 3
2024-01-15 07:05:18 ERROR Database connection lost: timeout after 30s
2024-01-15 07:06:30 ERROR Timeout on payment service: no response
2024-01-15 07:07:01 WARN  Falling back to cached data
2024-01-15 07:07:45 INFO  Service partially recovered
2024-01-15 07:08:12 INFO  All systems nominal
EOF
```

Verify it was created:

```bash
cat app.log
```

---

**Step 2 — Search for ERROR lines**

```bash
grep "ERROR" app.log
```

You should see 3 lines — all the ones containing the word ERROR.

---

**Step 3 — Count how many ERROR lines exist**

```bash
# Method 1 — using the -c flag (count directly)
grep -c "ERROR" app.log

# Method 2 — pipe to wc -l (count lines)
grep "ERROR" app.log | wc -l
```

Both give the same result: `3`. The `-c` method is simpler. The pipe method is more flexible because you can chain more commands after it.

---

**Step 4 — Save ERROR lines to a file**

```bash
# Save to error_report.txt (overwrites if it exists)
grep "ERROR" app.log > error_report.txt

# Verify the file was created
cat error_report.txt

# Append more lines to an existing file (does not overwrite)
grep "WARN" app.log >> error_report.txt

# Count lines in error_report.txt
wc -l error_report.txt
```

The difference between `>` and `>>`:

| Operator | Behaviour |
|---|---|
| `>` | Redirects output to a file. Creates the file if it does not exist. **Overwrites** if it does. |
| `>>` | Redirects output to a file. Creates the file if it does not exist. **Appends** to it if it does. |

---

**Step 5 — Search and exclude at the same time**

```bash
# Find ERROR lines that do NOT contain the word "timeout"
grep "ERROR" app.log | grep -v "timeout"
```

`-v` inverts the match — it keeps lines that do NOT contain the word.

---

**Step 6 — Combine everything in one pipeline**

```bash
# Count errors, show them, and save the report in one go
grep "ERROR" app.log | tee error_report.txt | wc -l
```

`tee` is a special command that sends output to both a file AND the terminal at the same time.

---

### Bonus question

> Explain step by step what this does: `cat app.log | grep "ERROR" | wc -l`

**Answer:**

```
cat app.log          →  reads the whole file and sends every line to stdout
     |               →  pipe: takes stdout from the left and feeds it as input to the right
grep "ERROR"         →  filters lines, keeping only those containing "ERROR"
     |               →  pipe: passes the filtered lines forward
wc -l                →  counts the number of lines and prints a single number
```

The more efficient version of the same command:

```bash
grep -c "ERROR" app.log
```

Using `cat` just to feed a file into `grep` is unnecessary — `grep` can read files directly. This is known as a **useless cat** in Unix culture.

---

## 9. Document your work — commands.md

Every command you ran during this lab should be documented in `commands.md`. This file is both your evidence and your personal reference sheet.

Here is the format to follow:

```markdown
# NexaOps Linux Lab — Commands Reference
## NXOPS-001B | Module 1 Foundations

---

## Task 1 — Navigation & files

| Command | What it does |
|---|---|
| `pwd` | Print current working directory |
| `ls -la` | List all files including hidden, with full details |
| `cd logs` | Move into the logs directory |
| `cd ..` | Go up one directory level |
| `cd ~` | Go to home directory from anywhere |
| `mkdir nexaops` | Create a directory called nexaops |
| `touch app.log` | Create an empty file called app.log |
| `tree .` | Show folder structure visually |

## Task 2 — Permissions

| Command | What it does |
|---|---|
| `ls -l deploy.sh` | Show permissions of deploy.sh |
| `chmod +x deploy.sh` | Add execute permission to deploy.sh |
| `chmod 755 deploy.sh` | Set permissions to rwxr-xr-x exactly |
| `./deploy.sh` | Run the deploy script |

## Task 3 — Processes

| Command | What it does |
|---|---|
| `top` | Live view of running processes sorted by CPU |
| `htop` | Cleaner colour version of top |
| `ps aux` | List all running processes with details |
| `ps aux | wc -l` | Count total number of running processes |
| `echo $$` | Print PID of current bash session |
| `pgrep bash` | Find PID of processes named bash |
| `kill <PID>` | Send SIGTERM — politely stop a process |
| `kill -9 <PID>` | Send SIGKILL — force stop a process immediately |
| `pkill <name>` | Kill a process by name |

## Task 4 — Shell scripting

| Command | What it does |
|---|---|
| `chmod +x check_log.sh` | Make check_log.sh executable |
| `./check_log.sh` | Run the check_log script |
| `bash -x check_log.sh` | Run in debug mode — prints every command as it executes |

## Task 5 — Pipes, grep & redirection

| Command | What it does |
|---|---|
| `grep "ERROR" app.log` | Print all lines containing ERROR |
| `grep -c "ERROR" app.log` | Count lines containing ERROR |
| `grep "ERROR" app.log > error_report.txt` | Save ERROR lines to a file |
| `grep "ERROR" app.log >> error_report.txt` | Append ERROR lines to a file |
| `grep -v "timeout" app.log` | Show lines that do NOT contain timeout |
| `cat app.log | grep "ERROR" | wc -l` | Count ERROR lines via pipeline |
| `wc -l error_report.txt` | Count lines in error_report.txt |
```

---

## 10. Push to GitHub

### Create the repo

1. Go to https://github.com/new
2. Repository name: `nexaops-linux-lab`
3. Set to **Public**
4. Do NOT tick "Add a README" — you already have files
5. Click **Create repository**

### Add a .gitignore

```bash
cat > .gitignore << 'EOF'
# Ignore generated files — these are created by running the lab commands
error_report.txt
*.log

# OS files
.DS_Store
Thumbs.db

# VS Code
.vscode/
EOF
```

> Note: we ignore `error_report.txt` and `*.log` from git — your README should explain how to regenerate them. Anyone cloning the repo should be able to reproduce these files by running the commands themselves.

### Initialise and push

```bash
cd ~/nexaops-linux-lab

# Initialise git
git init

# Set your identity
git config user.name "Your Name"
git config user.email "your@email.com"

# Stage all files
git add .

# First commit
git commit -m "feat(m1b): complete Linux fundamentals lab NXOPS-001B

- commands.md: documented all commands across 5 tasks with explanations
- deploy.sh: demonstrates chmod 755 permissions
- check_log.sh: bash script checking for app.log existence
- docs/screenshots: permissions and healthcheck terminal output
Ticket: NXOPS-001B"

# Connect to GitHub (replace with your repo URL)
git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/nexaops-linux-lab.git

# Push
git branch -M main
git push -u origin main
```

### Commit discipline

Use conventional commit messages throughout this bootcamp:

| Prefix | When to use it |
|---|---|
| `feat:` | Adding something new |
| `fix:` | Fixing a bug or error |
| `docs:` | Updating documentation or README |
| `chore:` | Maintenance tasks (updating .gitignore etc.) |
| `refactor:` | Improving code without changing behaviour |

Example: `git commit -m "docs: add permissions screenshot to README"`

---

## 11. Acceptance criteria checklist

Before marking this lab complete, verify every item below:

- [ ] `commands.md` documents every command run, with a one-line explanation for each
- [ ] `check_log.sh` exists, is executable (`-rwxr-xr-x`), and works correctly when `app.log` exists and when it does not
- [ ] A screenshot showing `ls -la` with `-rwxr-xr-x` permissions on your script is saved in `docs/screenshots/`
- [ ] `error_report.txt` can be generated by running `grep "ERROR" app.log > error_report.txt`
- [ ] All files are committed to a public GitHub repo named `nexaops-linux-lab` with meaningful commit messages
- [ ] A `README.md` explains what the repo is, what each file does, and how to reproduce the lab

---

## 12. LinkedIn post template

> This is for **Engineer A (lead)** only. Personalise it — do not copy it word for word.

```
Week 1 of our 3-month DevOps bootcamp — and it starts with Linux fundamentals.

As junior DevOps engineers, we often jump to the flashy tools (Kubernetes,
Terraform, CI/CD) without truly mastering the foundation everything else runs on.

This week I simulated my first day on a Linux server at a fictional company called
NexaOps Ltd and completed 5 real tasks:

• Navigated the server file system and documented key directories
• Fixed file permissions so a deployment script could actually run
• Investigated CPU and memory usage using top and ps
• Wrote my first shell script to automate a log file check
• Used grep and pipes to extract errors from application logs

Every command I ran is documented in my GitHub repo (link in comments).

[tag your 2 teammates]
#DevOps #Linux #Bash #LearningInPublic #100DaysOfDevOps #CloudEngineering
```

---

## 13. Troubleshooting

**`Permission denied` when running a script**
The script is not executable. Run `chmod +x <script-name>.sh` then try again.

**`command not found: tree`**
Install it: `sudo apt-get install -y tree`

**`command not found: htop`**
Install it: `sudo apt-get install -y htop`

**`code .` does nothing or errors in WSL**
In VS Code, press `Ctrl+Shift+P` → type **Shell Command: Install 'code' command in PATH** → press Enter. Restart your terminal.

**`cat app.log` shows the file is empty**
You may have run `touch app.log` which creates an empty file. Populate it using the heredoc command in Task 5 Step 1.

**`grep` returns no results**
Check the word you are searching for matches exactly what is in the file. Linux is case-sensitive — `ERROR` and `error` are different. Use `grep -i "error" app.log` for a case-insensitive search.

**`git push` asks for a password**
GitHub no longer accepts passwords for git operations. You need a Personal Access Token (PAT). Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Generate new token. Use the token as your password when prompted.

---

## 14. What you learned

By completing this lab you have practised:

- **Navigation** — `pwd`, `cd`, `ls -la`, `mkdir`, `touch`, `tree`
- **File permissions** — reading `rwx` notation, `chmod +x`, `chmod 755`, understanding the owner/group/others model
- **Process management** — `top`, `htop`, `ps aux`, `pgrep`, `kill`, `kill -9`, `pkill`
- **Shell scripting** — shebang lines, `set -e`, `if/else` conditionals, `-f` file test, variables
- **Text processing** — `grep`, `grep -c`, `grep -v`, `wc -l`, `cat`, `tee`, `>` and `>>` redirection, pipes `|`
- **Git discipline** — conventional commits, `.gitignore`, public repos as portfolio evidence

These are the exact skills that come up in junior DevOps and Cloud Engineer interviews. Every command in your `commands.md` is something you can speak to confidently in an interview because you actually ran it.

---

## Ticket reference

| Field | Value |
|---|---|
| Ticket ID | NXOPS-001B |
| Module | M1 — Linux & Shell Scripting |
| Track | Foundations (beginner) |
| Phase | 1 — Foundation |
| Assignee (lead) | Engineer A |
| Reviewers | Engineers B & C |
| Estimate | 4–6 hours |
| Companion ticket | NXOPS-001 (advanced scripting lab) |

---

*NexaOps DevOps Bootcamp · Built with [Tech World with Nana](https://www.techworld-with-nana.com/) · Facilitated by Claude*
