# NXOPS-002 — Git & Version Control Lab
### NexaOps DevOps Bootcamp · Module 2 · Foundation Track

> **Scenario:** NexaOps Ltd has just hired two new developers who accidentally overwrote each other's code by emailing files back and forth. Your engineering manager has raised a ticket: the team needs to adopt Git properly, branching strategy, pull requests, commit discipline, and conflict resolution, before the next feature release. You will version-control a real Node.js web application from scratch.

---

## Table of Contents

1. [How to use this lab](#1-how-to-use-this-lab)
2. [Prerequisites](#2-prerequisites)
3. [The application — NexaOps Status Page](#3-the-application--nexaops-status-page)
4. [Task 1 — Initialise the repo & make your first commits](#4-task-1--initialise-the-repo--make-your-first-commits)
5. [Task 2 — Branching & merging](#5-task-2--branching--merging)
6. [Task 3 — Simulating a team — pull requests & code review](#6-task-3--simulating-a-team--pull-requests--code-review)
7. [Task 4 — Handling merge conflicts](#7-task-4--handling-merge-conflicts)
8. [Task 5 — Git history, inspection & undoing mistakes](#8-task-5--git-history-inspection--undoing-mistakes)
9. [Document your work — commands.md](#9-document-your-work--commandsmd)
10. [Push to GitHub](#10-push-to-github)
11. [Acceptance criteria checklist](#11-acceptance-criteria-checklist)
12. [LinkedIn post template](#12-linkedin-post-template)
13. [Interview questions — 5 scenario-based questions](#13-interview-questions--5-scenario-based-questions)
14. [Troubleshooting](#14-troubleshooting)
15. [What you learned](#15-what-you-learned)

---

## 1. How to use this lab

This lab has **5 tasks**. Each one maps directly to a real Git scenario you will face in a DevOps or Cloud Engineering role.

| Task | Topic | Interview question it prepares you for |
|---|---|---|
| Task 1 | Init, staging, committing | "Walk me through your Git workflow" |
| Task 2 | Branching & merging | "How do you manage feature branches?" |
| Task 3 | Pull requests & code review | "How does your team collaborate on code?" |
| Task 4 | Merge conflicts | "What do you do when two people edit the same file?" |
| Task 5 | History & undoing mistakes | "How do you recover from a bad commit in production?" |

**Rules for this lab:**
- Every answer goes into `commands.md` as you go, do not document from memory afterwards
- Every branch must have a meaningful name (e.g. `feature/add-services-section` not `branch1`)
- Every commit must follow conventional commit format (`feat:`, `fix:`, `docs:`, `chore:`)
- No `git push --force` on `main`, ever

---

## 2. Prerequisites

### Git installed

```bash
git --version
# Should return: git version 2.x.x
# If not: sudo apt-get install -y git
```

### Configure your Git identity (do this once)

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Set VS Code as your default editor
git config --global core.editor "code --wait"

# Set main as the default branch name
git config --global init.defaultBranch main

# Verify
git config --list
```

### GitHub account

You need a GitHub account and a Personal Access Token (PAT) for pushing.

To create a PAT:
1. Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
2. Click **Generate new token**
3. Give it a name: `nexaops-bootcamp`
4. Set expiry: 90 days
5. Tick: `repo` (full control of private repositories)
6. Click **Generate token** copy it immediately, you will not see it again

> Save your PAT somewhere safe. When Git asks for your password, paste this token.

### Node.js (for running the app locally, optional)

```bash
# Check if installed
node --version

# Install if needed
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version && npm --version
```

---

## 3. The Application — NexaOps Status Page

You will be version-controlling a simple **service status page** for NexaOps Ltd, the kind of page companies like GitHub, AWS, and Atlassian publish at `status.company.com`. It shows whether each internal service is up or down.

This is a deliberate choice: the app is simple enough that you focus on Git, not on debugging code.

### Create the project folder

```bash
mkdir -p ~/nexaops-status-page
cd ~/nexaops-status-page
```

### Create the application files

**File 1 — `index.html`** (the status page)

```bash
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>NexaOps — Service Status</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>
  <header>
    <h1>NexaOps Ltd</h1>
    <p class="subtitle">System Status</p>
  </header>

  <main>
    <div class="status-banner operational">
      <span>&#10003; All systems operational</span>
    </div>

    <section class="services">
      <h2>Services</h2>

      <div class="service">
        <span class="service-name">API Gateway</span>
        <span class="badge operational">Operational</span>
      </div>

      <div class="service">
        <span class="service-name">Authentication Service</span>
        <span class="badge operational">Operational</span>
      </div>

      <div class="service">
        <span class="service-name">Database Cluster</span>
        <span class="badge operational">Operational</span>
      </div>

      <div class="service">
        <span class="service-name">Payment Service</span>
        <span class="badge operational">Operational</span>
      </div>

      <div class="service">
        <span class="service-name">File Storage</span>
        <span class="badge operational">Operational</span>
      </div>
    </section>

    <section class="incidents">
      <h2>Recent Incidents</h2>
      <p class="no-incidents">No incidents reported in the last 30 days.</p>
    </section>
  </main>

  <footer>
    <p>Last updated: <span id="timestamp"></span></p>
    <script>
      document.getElementById('timestamp').textContent = new Date().toUTCString();
    </script>
  </footer>
</body>
</html>
EOF
```

**File 2 — `style.css`**

```bash
cat > style.css << 'EOF'
/* NexaOps Status Page — Base Styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  background: #f5f7fa;
  color: #333;
  min-height: 100vh;
}

header {
  background: #1a1a2e;
  color: white;
  padding: 2rem;
  text-align: center;
}

header h1 {
  font-size: 1.8rem;
  margin-bottom: 0.25rem;
}

.subtitle {
  color: #aaa;
  font-size: 0.9rem;
}

main {
  max-width: 700px;
  margin: 2rem auto;
  padding: 0 1rem;
}

.status-banner {
  padding: 1rem 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  font-weight: 600;
  font-size: 1rem;
}

.status-banner.operational {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.status-banner.degraded {
  background: #fff3cd;
  color: #856404;
  border: 1px solid #ffeeba;
}

.status-banner.outage {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

section {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

section h2 {
  font-size: 1rem;
  color: #555;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
}

.service {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid #f0f0f0;
}

.service:last-child {
  border-bottom: none;
}

.service-name {
  font-size: 0.95rem;
}

.badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.badge.operational {
  background: #d4edda;
  color: #155724;
}

.badge.degraded {
  background: #fff3cd;
  color: #856404;
}

.badge.outage {
  background: #f8d7da;
  color: #721c24;
}

.no-incidents {
  color: #888;
  font-size: 0.9rem;
}

footer {
  text-align: center;
  padding: 2rem;
  color: #aaa;
  font-size: 0.8rem;
}
EOF
```

**File 3 — `README.md`** (the app's own readme)

```bash
cat > README.md << 'EOF'
# NexaOps Status Page

A lightweight service status page for NexaOps Ltd. Displays real-time
operational status for all internal services.

## Running locally

Open `index.html` directly in your browser — no build step required.

## Files

- `index.html` — the status page markup
- `style.css` — all styles

## Services monitored

- API Gateway
- Authentication Service
- Database Cluster
- Payment Service
- File Storage
EOF
```

### View the app

```bash
# Open in VS Code
code .

# To view in browser: open index.html with your file explorer
# or in WSL: explorer.exe index.html
```

You now have a working status page. All 5 tasks use this same application.

---

## 4. Task 1 — Initialise the repo & make your first commits

### Scenario

The NexaOps status page exists as loose files on your laptop. Your job is to put it under version control so the team can track every change.

### Questions to answer before you look at the steps

- What command initialises a new Git repo?
- What is the difference between `git add` and `git commit`?
- What does the staging area actually do, why does it exist?
- What is the difference between `git status` and `git log`?

---

### Step 1 — Initialise the repository

```bash
cd ~/nexaops-status-page
git init
```

You should see: `Initialized empty Git repository in .../nexaops-status-page/.git/`

The `.git` folder is where Git stores everything — history, branches, config. Never delete or edit it manually.

```bash
# See the hidden .git folder
ls -la
```

---

### Step 2 — Check what Git sees

```bash
git status
```

You will see all three files listed as **Untracked files** — Git knows they exist but is not tracking them yet.

---

### Step 3 — Understand the three areas

Before you add anything, understand where files live:

```
Working Directory      Staging Area (Index)      Repository (.git)
      │                       │                         │
  Your files    ──git add──►  Snapshot ready   ──git commit──►  Saved history
  (edited)                    to commit                          (permanent)
```

- **Working directory** — your actual files as they are right now
- **Staging area** — a holding area where you choose what goes into the next commit
- **Repository** — the permanent history of all commits

---

### Step 4 — Create a .gitignore

Before your first commit, tell Git what to ignore:

```bash
cat > .gitignore << 'EOF'
# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
*.swp

# Node modules (for future use)
node_modules/

# Environment files — NEVER commit secrets
.env
*.env.local
EOF
```

---

### Step 5 — Stage your files

```bash
# Stage all files at once
git add .

# Check what is now staged
git status
```

You will see the files listed under **Changes to be committed** — they are in the staging area, ready to commit.

```bash
# See exactly what is staged (the diff)
git diff --staged
```

---

### Step 6 — Make your first commit

```bash
git commit -m "feat: initial commit — NexaOps status page

- index.html: service status page with 5 monitored services
- style.css: base styles with operational/degraded/outage states
- README.md: project overview and local setup instructions
- .gitignore: ignore OS files, editor files, node_modules, .env"
```

> **Commit message format — conventional commits:**
>
> `<type>(<scope>): <short description>`
>
> | Type | When to use |
> |---|---|
> | `feat` | Adding something new |
> | `fix` | Fixing a bug |
> | `docs` | Documentation only |
> | `style` | Formatting, no logic change |
> | `chore` | Maintenance (deps, config) |
> | `refactor` | Improving code, no behaviour change |

---

### Step 7 — Make a second commit (a deliberate change)

Now simulate making a change after the initial commit:

```bash
# Add a new service to index.html
# Open in VS Code and add this block inside the .services section,
# after the File Storage service div:

#   <div class="service">
#     <span class="service-name">Notification Service</span>
#     <span class="badge operational">Operational</span>
#   </div>
```

```bash
# Stage only the changed file (not everything)
git add index.html

# Commit with a meaningful message
git commit -m "feat(services): add Notification Service to status page"
```

---

### Step 8 — View your history

```bash
# Full log
git log

# Compact one-line view (use this most often)
git log --oneline

# Compact with branch graph
git log --oneline --graph --decorate

# See what changed in the last commit
git show HEAD
```

---

### ✅ Task 1 — Answers

**What does `git init` do?**
Creates a hidden `.git` folder in the current directory. This is the entire Git database for your project, branches, history, config, everything. Without it, Git has no knowledge of your project.

**Difference between `git add` and `git commit`?**
`git add` moves changes from your working directory into the staging area, it is a preparation step. `git commit` takes everything in the staging area and saves it permanently into the repository history. This two-step process exists so you can choose *exactly* which changes go into a commit, even if you have edited multiple files.

**Why does the staging area exist?**
It gives you precise control. Imagine you edited 5 files but only want to commit 2 of them, the staging area lets you do that. In a DevOps context this matters: you might have a config change and a code change in the same working directory but want to commit them separately with different messages.

**`git status` vs `git log`?**
`git status` shows the *current state* — what is modified, staged, or untracked right now. `git log` shows the *history* — a record of all previous commits. One is about now, one is about the past.

---

## 5. Task 2 — Branching & merging

### Scenario

Your team lead asks you to add an "Incidents" section to the status page. Company policy says: **never commit directly to `main`**. All changes go through a feature branch and a pull request.

### Questions to answer before you look at the steps

- What is a branch and why does it exist?
- What is the difference between `git merge` and `git rebase`?
- What does `HEAD` mean in Git?
- What happens to your working directory when you switch branches?

---

### Step 1 — See your current branches

```bash
git branch
```

You have one branch: `main`. The `*` shows you are currently on it.

---

### Step 2 — Create and switch to a feature branch

```bash
# Create the branch and switch to it in one command
git checkout -b feature/add-incidents-section

# Verify you are on the new branch
git branch
git status
```

The branch name follows the pattern: `type/short-description`. Common types:
- `feature/` — new functionality
- `fix/` — bug fixes
- `hotfix/` — urgent production fixes
- `chore/` — maintenance tasks
- `docs/` — documentation updates

---

### Step 3 — Make a change on your feature branch

Open `index.html` in VS Code. Find the incidents section and replace it with this:

```html
    <section class="incidents">
      <h2>Recent Incidents</h2>

      <div class="incident">
        <div class="incident-header">
          <span class="incident-title">Payment Service Latency</span>
          <span class="badge degraded">Resolved</span>
        </div>
        <p class="incident-date">2024-01-10 — 14:32 UTC</p>
        <p class="incident-detail">
          Elevated response times on the payment service due to database
          connection pool exhaustion. Resolved by increasing pool size.
        </p>
      </div>

    </section>
```

Also add these styles to `style.css`:

```css
/* Incident styles */
.incident {
  padding: 1rem 0;
  border-bottom: 1px solid #f0f0f0;
}

.incident:last-child {
  border-bottom: none;
}

.incident-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.25rem;
}

.incident-title {
  font-weight: 600;
  font-size: 0.95rem;
}

.incident-date {
  font-size: 0.8rem;
  color: #888;
  margin-bottom: 0.5rem;
}

.incident-detail {
  font-size: 0.85rem;
  color: #555;
  line-height: 1.6;
}
```

---

### Step 4 — Commit your changes on the feature branch

```bash
git add index.html style.css
git commit -m "feat(incidents): add resolved Payment Service incident to history

Adds incident history section showing the 2024-01-10 payment service
latency incident caused by database connection pool exhaustion."
```

---

### Step 5 — View the branch difference

```bash
# See commits on your feature branch that are not on main
git log main..feature/add-incidents-section --oneline

# See all branches with their latest commit
git log --oneline --graph --all --decorate
```

---

### Step 6 — Switch back to main and merge

```bash
# Go back to main
git checkout main

# Verify your changes are gone (feature branch changes stay on their branch)
cat index.html | grep "Payment Service Latency"
# Should return nothing — those changes are on the feature branch only

# Merge the feature branch into main
git merge feature/add-incidents-section

# See the result
git log --oneline
```

---

### Step 7 — Delete the feature branch (clean up)

```bash
# Once merged, delete the branch — it has served its purpose
git branch -d feature/add-incidents-section

# Confirm it is gone
git branch
```

---

### Step 8 — Create a second branch for another change

Practice again, this time make a change to the page header:

```bash
git checkout -b chore/update-page-header
```

In `index.html`, update the header section to:

```html
  <header>
    <h1>NexaOps Ltd</h1>
    <p class="subtitle">Live System Status — Updated every 60 seconds</p>
  </header>
```

```bash
git add index.html
git commit -m "chore(header): update subtitle to show refresh interval"
git checkout main
git merge chore/update-page-header
git branch -d chore/update-page-header
```

---

### ✅ Task 2 — Answers

**What is a branch and why does it exist?**
A branch is a lightweight, movable pointer to a commit. It lets you work on a change in isolation without affecting the stable code on `main`. In a team, multiple engineers can work on different features simultaneously, each on their own branch, then merge when ready.

**`git merge` vs `git rebase`?**
`git merge` creates a new "merge commit" that joins two branches, preserving the full history of both. `git rebase` rewrites the commit history by replaying your branch's commits on top of the target branch, producing a cleaner, linear history. Teams that value a clean history use rebase; teams that value full traceability use merge. In most DevOps workflows you will see both.

**What does `HEAD` mean?**
`HEAD` is a pointer to the commit you are currently on, essentially "where you are right now" in the repository. When you switch branches, `HEAD` moves to point at that branch's latest commit.

**What happens to your working directory when you switch branches?**
Git swaps out the files in your working directory to match the state of the branch you are switching to. Changes you have committed on one branch will disappear when you switch to another, they are safe on their branch, just not visible.

---

## 6. Task 3 — Simulating a team: pull requests & code review

### Scenario

At NexaOps Ltd, no code goes directly to `main`. All changes go through a **Pull Request (PR)** on GitHub so a team member can review it before it is merged. In this task you will simulate the full PR workflow.

### Questions to answer before you look at the steps

- What is the difference between `git push` and a pull request?
- What is `origin`?
- What does `git fetch` do compared to `git pull`?
- Why do teams use pull requests instead of pushing directly to main?

---

### Step 1 — Create the GitHub repo and push

1. Go to https://github.com/new
2. Repository name: `nexaops-status-page`
3. Set to **Public**
4. Do NOT initialise with README (you already have files)
5. Click **Create repository**

```bash
cd ~/nexaops-status-page

# Connect your local repo to GitHub
git remote add origin https://github.com/<YOUR_USERNAME>/nexaops-status-page.git

# Verify the remote was added
git remote -v

# Push main to GitHub
git push -u origin main
```

The `-u` flag sets `origin main` as the default upstream, after this you can just run `git push`.

---

### Step 2 — Create a feature branch and push it to GitHub

```bash
# Create a new feature branch
git checkout -b feature/add-response-time-metric

# Make a change, add a response time line to the API Gateway service
```

In `index.html`, update the API Gateway service div to:

```html
      <div class="service">
        <span class="service-name">API Gateway</span>
        <div style="display:flex; align-items:center; gap:0.75rem;">
          <span class="response-time">avg 42ms</span>
          <span class="badge operational">Operational</span>
        </div>
      </div>
```

Add to `style.css`:

```css
.response-time {
  font-size: 0.75rem;
  color: #888;
}
```

```bash
# Commit the change
git add index.html style.css
git commit -m "feat(services): add response time metric to API Gateway"

# Push the feature branch to GitHub
git push -u origin feature/add-response-time-metric
```

---

### Step 3 — Open a Pull Request on GitHub

1. Go to your repo on GitHub
2. You will see a yellow banner: **"feature/add-response-time-metric had recent pushes"** — click **Compare & pull request**
3. Fill in the PR:
   - **Title:** `feat(services): add response time metric to API Gateway`
   - **Description:** (use the template below)

```
## What does this PR do?
Adds an average response time metric (42ms) next to the API Gateway
service badge on the status page.

## Why?
Gives engineers a quick at-a-glance performance indicator without
needing to open the monitoring dashboard.

## How to test
1. Open index.html in a browser
2. Verify "avg 42ms" appears next to the API Gateway badge
3. Verify the layout does not break on mobile width

## Checklist
- [x] Tested locally in browser
- [x] No hardcoded secrets
- [x] Commit messages follow conventional commit format
```

4. Click **Create pull request**

---

### Step 4 — Review the PR (as a teammate)

Have one of your teammates review the PR on GitHub, or review it yourself by:

1. Going to the **Files changed** tab
2. Clicking the `+` icon next to a line to add a comment
3. Leaving at least one comment (even a positive one like "Looks good, what happens when the response time is high?")
4. Clicking **Review changes** → **Approve**

---

### Step 5 — Merge the PR and clean up

1. On the PR page, click **Merge pull request** → **Confirm merge**
2. Click **Delete branch** (GitHub will prompt you after merge)

```bash
# Pull the merged changes back to your local main
git checkout main
git pull origin main

# Delete the local feature branch
git branch -d feature/add-response-time-metric

# Verify your local branch list is clean
git branch
```

---

### Step 6 — Understand the full remote workflow

```bash
# See all remote branches
git branch -r

# See all branches (local and remote)
git branch -a

# Fetch changes without merging (safe, just downloads)
git fetch origin

# Pull = fetch + merge (updates your local branch)
git pull origin main
```

---

### ✅ Task 3 — Answers

**`git push` vs a pull request?**
`git push` uploads your branch to the remote (GitHub). A pull request is a GitHub feature that says "I want to merge this branch into main, can someone review it first?" Push is a Git concept; PR is a collaboration workflow built on top of Git.

**What is `origin`?**
`origin` is the default name Git gives to the remote repository you cloned from or connected to. It is just an alias for the full URL. You can rename it or have multiple remotes (e.g. `origin` for GitHub and `upstream` for a forked project's original repo).

**`git fetch` vs `git pull`?**
`git fetch` downloads new commits and branches from the remote but does NOT change your local files. It is safe to run any time. `git pull` is `git fetch` + `git merge`, it downloads and immediately merges the changes into your current branch. DevOps engineers often prefer `git fetch` first so they can inspect changes before merging.

**Why pull requests instead of pushing directly to main?**
Four reasons that matter in real teams: (1) another engineer catches bugs before they reach production, (2) it creates a discussion thread tied to each change, (3) it enforces branch protection, no force pushes or direct commits to main, (4) it produces a traceable record of why every change was made.

---

## 7. Task 4 — Handling merge conflicts

### Scenario

Two NexaOps engineers both edited `index.html` at the same time on different branches. When they try to merge, Git cannot decide which version to keep. You need to resolve the conflict.

### Questions to answer before you look at the steps

- What causes a merge conflict?
- What do the `<<<<<<<`, `=======`, and `>>>>>>>` markers mean?
- How do you mark a conflict as resolved?
- What is the difference between resolving a conflict and preventing one?

---

### Step 1 — Create two branches that will conflict

```bash
# Branch 1 — Engineer A changes the status banner
git checkout -b feature/engineer-a-banner-update
```

In `index.html`, update the status banner div:

```html
    <div class="status-banner operational">
      <span>&#10003; All systems operational — Last checked 07:00 UTC</span>
    </div>
```

```bash
git add index.html
git commit -m "feat(banner): add last-checked timestamp to status banner"
git checkout main
```

```bash
# Branch 2 — Engineer B also changes the same banner line
git checkout -b feature/engineer-b-banner-update
```

In `index.html`, update the same status banner div differently:

```html
    <div class="status-banner operational">
      <span>&#10003; All systems operational — 6 services monitored</span>
    </div>
```

```bash
git add index.html
git commit -m "feat(banner): add service count to status banner"
git checkout main
```

---

### Step 2 — Merge the first branch (succeeds)

```bash
git merge feature/engineer-a-banner-update
# This succeeds, no conflict yet
```

---

### Step 3 — Merge the second branch (conflict!)

```bash
git merge feature/engineer-b-banner-update
```

You will see:

```
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```

---

### Step 4 — Inspect the conflict

```bash
git status
# Shows: both modified: index.html

# See the conflict markers in the file
cat index.html | grep -A 5 "<<<<<<<<"
```

Open `index.html` in VS Code. You will see:

```html
<<<<<<< HEAD
      <span>&#10003; All systems operational — Last checked 07:00 UTC</span>
=======
      <span>&#10003; All systems operational — 6 services monitored</span>
>>>>>>> feature/engineer-b-banner-update
```

**What the markers mean:**
- `<<<<<<< HEAD` — start of YOUR version (the branch you are on, which has Engineer A's change)
- `=======` — the dividing line between the two versions
- `>>>>>>> feature/engineer-b-banner-update` — the incoming change you are trying to merge

---

### Step 5 — Resolve the conflict

You need to decide: keep one version, keep the other, or combine them. In this case, combining makes sense:

Delete the conflict markers and edit the line to:

```html
      <span>&#10003; All systems operational — 6 services monitored — Last checked 07:00 UTC</span>
```

Make sure you remove ALL three marker lines (`<<<<<<<`, `=======`, `>>>>>>>`).

---

### Step 6 — Mark as resolved and commit

```bash
# Stage the resolved file
git add index.html

# Check status — should show "All conflicts fixed but you are still merging"
git status

# Complete the merge with a commit
git commit -m "fix(banner): resolve merge conflict — combine timestamp and service count"
```

---

### Step 7 — Clean up

```bash
git branch -d feature/engineer-a-banner-update
git branch -d feature/engineer-b-banner-update
git log --oneline --graph
```

---

### ✅ Task 4 — Answers

**What causes a merge conflict?**
A conflict occurs when two branches have both modified the same lines of the same file, and Git cannot automatically decide which version is correct. Git can auto-merge changes to different parts of the same file, conflicts only arise when both branches touch the same lines.

**What do the conflict markers mean?**
`<<<<<<< HEAD` marks the start of your current branch's version. `=======` is the divider. `>>>>>>> branch-name` marks the end of the incoming branch's version. Everything between the markers is the content that conflicts, you delete the markers and edit the content to whatever the correct final version should be.

**How do you mark a conflict as resolved?**
After manually editing the file to remove the conflict markers and produce the correct content, you run `git add <filename>` to tell Git "I have resolved this conflict". Then `git commit` to complete the merge.

**Resolving vs preventing conflicts?**
Prevention is better: communicate with your team before editing the same files, keep branches short-lived and merge frequently, break large files into smaller ones with clear ownership. In a DevOps context, infrastructure files like `main.tf` and `values.yaml` are common conflict hotspots because multiple engineers touch them.

---

## 8. Task 5 — Git history, inspection & undoing mistakes

### Scenario

A junior developer on the NexaOps team accidentally committed a `.env` file containing an API key to the repository. You need to know how to inspect what happened and how to undo it safely.

### Questions to answer before you look at the steps

- What is the difference between `git revert` and `git reset`?
- When would you use `git stash`?
- How do you see what changed in a specific commit?
- What does `git reset --hard` do and why is it dangerous?

---

### Step 1 — Simulate the mistake: commit a sensitive file

```bash
# Create a fake .env file with fake credentials
cat > .env << 'EOF'
# NexaOps environment config
DB_HOST=prod-db.nexaops.internal
DB_PASSWORD=super_secret_password_123
API_KEY=nxa_live_sk_a1b2c3d4e5f6g7h8
STRIPE_SECRET=sk_live_AbCdEfGhIjKlMnOp
EOF

# Accidentally add and commit it
git add .env
git commit -m "chore: add environment config"
```

---

### Step 2 — Inspect the damage

```bash
# See the commit in history
git log --oneline

# See exactly what was committed
git show HEAD

# See all files tracked in the last commit
git show HEAD --name-only
```

---

### Step 3 — Undo with git revert (safe — creates a new commit)

`git revert` is the **safe, production-appropriate** way to undo a commit. It does not rewrite history, it creates a new commit that undoes the changes.

```bash
# Revert the last commit (HEAD)
git revert HEAD

# Git opens your editor for a commit message — save and close
# Or use --no-edit to accept the default message
git revert HEAD --no-edit

# View the result — you should see a new "Revert" commit
git log --oneline
```

> **Why revert and not reset?** If you have already pushed to GitHub and others have pulled your commits, resetting rewrites history that teammates have. Revert adds a new commit that undoes the change, it is safe to push.

---

### Step 4 — Make sure .env is in .gitignore

```bash
# Verify .env is listed
cat .gitignore | grep .env

# Now even if someone does git add . — .env will be ignored
echo "NEW_SECRET=another_secret" >> .env
git status
# .env should NOT appear in untracked files
```

---

### Step 5 — Practice git stash

`git stash` temporarily shelves changes you are not ready to commit, letting you switch context.

```bash
# Make a change but don't commit it
echo "/* TODO: add dark mode */" >> style.css

# Check status
git status
# You have unstaged changes

# Stash them
git stash

# Check status — working directory is clean
git status

# See your stashes
git stash list

# Get your changes back
git stash pop

# Verify the change is back
git status
```

---

### Step 6 — Inspect history like a detective

```bash
# See the full log with file names changed in each commit
git log --oneline --stat

# See changes introduced in a specific commit (replace with your hash)
git show <commit-hash>

# See who last changed each line of a file
git blame index.html

# See the difference between two commits
git diff HEAD~1 HEAD

# See difference between two branches
git diff main feature/some-branch

# Search commit messages for a keyword
git log --oneline --grep="banner"

# See all commits by a specific author
git log --oneline --author="Your Name"
```

---

### Step 7 — Understanding git reset (use carefully)

```bash
# See the difference between the three types of reset

# --soft: moves HEAD back, keeps changes staged
git reset --soft HEAD~1
# Your last commit is undone but files are staged — ready to re-commit

git commit -m "feat: re-commit after soft reset example"

# --mixed (default): moves HEAD back, unstages changes, keeps files
git reset HEAD~1
# Your last commit is undone, files are modified but not staged

git add .
git commit -m "feat: re-commit after mixed reset example"

# --hard: moves HEAD back, DISCARDS all changes — CANNOT be undone
# Only use this when you are absolutely certain you want to lose the changes
# git reset --hard HEAD~1   ← commented out intentionally — do not run carelessly
```

---

### ✅ Task 5 — Answers

**`git revert` vs `git reset`?**
`git revert` creates a new commit that undoes a previous commit, history is preserved. Safe to use on shared branches. `git reset` moves the branch pointer backwards, effectively erasing commits from history. Dangerous on shared branches because it rewrites history that teammates may have already pulled. Rule: use `revert` on `main` or any pushed branch, use `reset` only on local branches you have not shared.

**When to use `git stash`?**
When you are mid-change and need to switch branches urgently — e.g. a production hotfix comes in while you are halfway through a feature. Stash shelves your work-in-progress so your working directory is clean, then you can switch branches. `git stash pop` restores your work when you come back.

**How to see what changed in a specific commit?**
`git show <commit-hash>` — shows the full diff of what was added and removed. `git log --stat` shows a summary of which files changed and how many lines. `git blame <file>` shows which commit last touched each line.

**What does `git reset --hard` do and why is it dangerous?**
It moves HEAD to the specified commit and discards ALL changes in your working directory and staging area. Those changes are gone — no undo, no recycle bin. It is dangerous because it can permanently destroy uncommitted work and, if run on a shared branch, can cause history divergence that breaks teammates' repos.

---

## 9. Document your work — commands.md

Create `commands.md` in your repo root and fill it in as you complete each task. Use this structure:

```markdown
# NexaOps Git Lab — Commands Reference
## NXOPS-002 | Module 2: Git & Version Control

---

## Setup

| Command | What it does |
|---|---|
| `git config --global user.name "Name"` | Set your Git identity — appears in every commit |
| `git config --global user.email "email"` | Set your email — must match GitHub account |
| `git config --global core.editor "code --wait"` | Set VS Code as Git's default editor |
| `git config --list` | View all current Git configuration |

## Task 1 — Init & commits

| Command | What it does |
|---|---|
| `git init` | Initialise a new Git repo in the current directory |
| `git status` | Show current state — modified, staged, untracked files |
| `git add .` | Stage all changes in the current directory |
| `git add <file>` | Stage a specific file only |
| `git commit -m "message"` | Save staged changes to history with a message |
| `git diff --staged` | Show exactly what is staged vs last commit |
| `git log --oneline` | Show compact commit history |
| `git log --oneline --graph --decorate` | Show history with branch graph |
| `git show HEAD` | Show what changed in the last commit |

## Task 2 — Branching & merging

| Command | What it does |
|---|---|
| `git branch` | List all local branches |
| `git checkout -b feature/name` | Create and switch to a new branch |
| `git checkout main` | Switch back to main branch |
| `git merge feature/name` | Merge a branch into current branch |
| `git branch -d feature/name` | Delete a branch after merging |
| `git log --oneline --graph --all --decorate` | Show all branches in the history graph |
| `git log main..feature/name --oneline` | Show commits on feature branch not yet in main |

## Task 3 — Remotes & pull requests

| Command | What it does |
|---|---|
| `git remote add origin <url>` | Connect local repo to a GitHub remote |
| `git remote -v` | Show configured remotes |
| `git push -u origin main` | Push to GitHub and set default upstream |
| `git push` | Push current branch to its upstream remote |
| `git fetch origin` | Download remote changes without merging |
| `git pull origin main` | Download and merge remote changes |
| `git branch -r` | Show remote branches |
| `git branch -a` | Show all local and remote branches |

## Task 4 — Merge conflicts

| Command | What it does |
|---|---|
| `git merge <branch>` | Attempt to merge (may produce conflicts) |
| `git status` | Shows which files have conflicts |
| `git add <file>` | Mark conflict as resolved after editing |
| `git commit` | Complete the merge after resolving all conflicts |
| `git merge --abort` | Cancel a merge in progress and return to pre-merge state |

## Task 5 — History & undoing mistakes

| Command | What it does |
|---|---|
| `git revert HEAD` | Safely undo last commit by creating a new commit |
| `git revert <hash>` | Safely undo a specific commit |
| `git reset --soft HEAD~1` | Undo last commit, keep changes staged |
| `git reset HEAD~1` | Undo last commit, keep files modified but unstaged |
| `git reset --hard HEAD~1` | Undo last commit, DISCARD all changes permanently |
| `git stash` | Shelve current changes temporarily |
| `git stash pop` | Restore shelved changes |
| `git stash list` | Show all stashes |
| `git show <hash>` | Show what changed in a specific commit |
| `git diff HEAD~1 HEAD` | Show diff between last two commits |
| `git blame <file>` | Show who last changed each line of a file |
| `git log --grep="keyword"` | Search commit messages for a word |
```

---

## 10. Push to GitHub

### Final push of all your work

```bash
cd ~/nexaops-status-page

# Ensure everything is committed
git status

# Push to GitHub
git push origin main
```

### Repo structure at the end of this lab

```
nexaops-status-page/
├── index.html          ← status page (evolved across 5 tasks)
├── style.css           ← styles (updated in tasks 2 and 3)
├── README.md           ← app documentation
├── commands.md         ← your Git commands reference
└── .gitignore          ← ignores .env, node_modules, OS files
```

### Confirm your commit history tells a story

```bash
git log --oneline
```

You should see a clean, readable history like:

```
a3f2b1c fix(banner): resolve merge conflict — combine timestamp and service count
9d1e4a7 feat(services): add response time metric to API Gateway
c8b2d3f feat(incidents): add resolved Payment Service incident to history
4e7a1b9 chore(header): update subtitle to show refresh interval
2f9c3d1 feat(services): add Notification Service to status page
1a4b5c6 feat: initial commit — NexaOps status page
```

If your history looks like `"update"`, `"fix"`, `"asdf"` — go back and practice the conventional commit format. This history is what a recruiter or senior engineer will look at.

---

## 11. Acceptance criteria checklist

- [ ] GitHub repo `nexaops-status-page` is public with at least 6 meaningful commits
- [ ] All commits follow conventional commit format (`feat:`, `fix:`, `docs:`, `chore:`)
- [ ] Evidence of at least 2 feature branches created, merged, and deleted
- [ ] At least 1 pull request opened on GitHub with a proper description and review comment
- [ ] A merge conflict was created deliberately, resolved correctly, and the resolution is committed
- [ ] `git revert` was used to undo a commit (the `.env` accident)
- [ ] `.gitignore` correctly excludes `.env` files
- [ ] `commands.md` documents every command with a one-line explanation
- [ ] `git log --oneline` shows a clean, readable history that tells the story of the lab

---

## 12. LinkedIn post template

> For **Engineer B (lead)**. Personalise before posting.

```
Week 2 of our 3-month DevOps bootcamp — and this one hit different.

Git is something most engineers use every day, but few truly understand
until something goes wrong in production.

This week at our fictional company NexaOps Ltd, I simulated real team
Git workflows:

🌿 Branching strategy — feature branches, naming conventions, never
   committing directly to main

🔀 Pull requests — opening a PR with a proper description, leaving
   review comments, merging cleanly

⚔️  Merge conflicts — deliberately creating a conflict between two
   engineers' changes and resolving it correctly

↩️  Undoing mistakes — using git revert (safely) after "accidentally"
   committing a .env file with fake credentials

🔍 Git forensics — git blame, git log --grep, git show to investigate
   what happened and when

Every command I ran is documented in my GitHub repo (link in comments).

[tag your 2 teammates]
#DevOps #Git #GitHub #VersionControl #LearningInPublic #100DaysOfDevOps
```

---

## 13. Interview questions — 5 scenario-based questions

### Q1 — Git basics (very common)

**Scenario:** Your interviewer asks you to walk them through what happens when you run `git add .` followed by `git commit -m "message"`.

Sub-questions:
- What is the difference between the working directory, staging area, and repository?
- Why does Git have a staging area at all — why not just commit directly?
- What does the `-m` flag do? What happens if you leave it out?

**Bonus:** What is `HEAD` and where does it point after a commit?

<details>
<summary>Reveal answer</summary>

`git add .` moves all modified and new files from the working directory into the staging area. The staging area is a snapshot of what your next commit will look like — it gives you precise control over what goes in. `git commit -m "message"` takes everything in the staging area and permanently saves it to the repository as a new commit, which gets a unique SHA hash.

The staging area exists so you can group related changes into one commit even if you edited many files. For example, you might edit 5 files but only want to commit 2 of them — stage just those 2.

`-m` provides the commit message inline. Without it, Git opens your configured editor for you to write the message. `HEAD` after a commit points to the new commit you just made.

</details>

---

### Q2 — Branching (very common)

**Scenario:** A senior engineer tells you "never push directly to main." What does that mean and how do you work instead?

Sub-questions:
- How do you create a feature branch and switch to it in one command?
- What is the typical lifecycle of a feature branch at a professional company?
- What does `git branch -d` vs `git branch -D` do?

**Bonus:** What is the difference between `git merge` and `git rebase` and when would you use each?

<details>
<summary>Reveal answer</summary>

"Never push directly to main" means all changes go through a feature branch and a pull request, so another engineer can review before the code reaches the stable branch. `git checkout -b feature/my-feature` creates and switches in one step.

Lifecycle: create branch → make commits → push to remote → open PR → get reviewed → merge → delete branch.

`-d` (lowercase) only deletes if the branch is fully merged — it is safe. `-D` (uppercase) force-deletes even if unmerged — use with caution.

`git merge` preserves full history with a merge commit. `git rebase` replays commits onto the target branch producing a linear history. Use merge when you want traceability; use rebase to clean up a feature branch before merging.

</details>

---

### Q3 — Remote & collaboration (common)

**Scenario:** You cloned a repo two days ago. A teammate has since pushed 5 commits to main. How do you get their changes without losing your own work?

Sub-questions:
- What is the difference between `git fetch` and `git pull`?
- What is `origin`?
- What happens if your local main has diverged from the remote main?

**Bonus:** What does `git push -u origin main` do and what does `-u` mean?

<details>
<summary>Reveal answer</summary>

`git fetch origin` downloads the new commits from GitHub without touching your working directory or local branches — safe to run any time. Then `git merge origin/main` or `git rebase origin/main` incorporates the changes. `git pull` does both in one step.

`origin` is the alias for the remote URL you added when you ran `git remote add origin`. It is just a shorthand.

If local and remote have diverged (both have commits the other does not), a pull will create a merge commit joining them. You can avoid divergence by rebasing: `git pull --rebase origin main`.

`-u` sets the upstream tracking relationship — after running it once, you can just type `git push` and Git knows to push to `origin main`.

</details>

---

### Q4 — Merge conflicts (very common)

**Scenario:** You run `git merge feature/engineer-b-changes` and see "CONFLICT: Merge conflict in app.py". Walk me through exactly what you do next.

Sub-questions:
- What do the `<<<<<<<`, `=======`, and `>>>>>>>` markers mean?
- After editing the file to resolve the conflict, what commands do you run?
- How could this conflict have been prevented?

**Bonus:** What does `git merge --abort` do and when would you use it?

<details>
<summary>Reveal answer</summary>

`<<<<<<<` to `=======` is your current branch's version. `=======` to `>>>>>>>` is the incoming branch's version. I open the file, decide on the correct final content, remove all three marker lines, and edit to the correct version.

Then: `git add <filename>` to mark resolved, then `git commit` to complete the merge.

Prevention: communicate before editing the same files, keep branches short-lived and merge often, use file ownership conventions (one team owns one module), run `git fetch` regularly to stay aware of teammates' changes.

`git merge --abort` cancels a merge in progress and returns everything to the state before you ran `git merge`. Use it when you realise the conflict is too complex to resolve immediately and you need to discuss with your team first.

</details>

---

### Q5 — Undoing mistakes (common in senior-leaning junior interviews)

**Scenario:** A developer on your team accidentally committed a file containing an AWS secret key to the main branch and pushed it to GitHub. What do you do?

Sub-questions:
- What is the difference between `git revert` and `git reset` in this context?
- Which one is safe to use on a shared branch and why?
- What should you do about the exposed secret itself?

**Bonus:** Why is it not enough to just revert the commit — what else must you do if a secret was pushed to a public repo?

<details>
<summary>Reveal answer</summary>

I would run `git revert <commit-hash>` which creates a new commit that removes the secret file. This is safe because it does not rewrite history — it only adds a new commit, so teammates who already pulled are not affected.

`git reset --hard` would rewrite history — if I push that to a shared branch, everyone else's repo diverges, which causes serious problems.

After reverting, the secret must be rotated immediately — revoke it in AWS IAM and generate a new key. Then add the file to `.gitignore`.

The bonus answer: even after reverting, the secret still exists in the Git history. Anyone who cloned or forked before the revert still has it. You must assume the secret is compromised and rotate it regardless. GitHub also caches content and security scanners may have already found it. For full history removal you would need `git filter-branch` or BFG Repo Cleaner, but rotating the secret is the most important step.

</details>

---

## 14. Troubleshooting

**`git push` asks for a username and password**
GitHub removed password authentication. Use your Personal Access Token as the password, or set up SSH keys. For SSH: `ssh-keygen -t ed25519 -C "your@email.com"` then add the public key to GitHub under Settings → SSH Keys.

**`error: failed to push some refs to origin`**
Your local branch is behind the remote. Run `git pull origin main` first, then push again.

**`fatal: refusing to merge unrelated histories`**
Happens when you initialise a repo locally AND on GitHub separately. Fix: `git pull origin main --allow-unrelated-histories`

**`Your branch and 'origin/main' have diverged`**
Both local and remote have commits the other does not. Run `git pull --rebase origin main` to replay your local commits on top of the remote ones.

**VS Code shows merge conflict colours but I edited the file — still shows conflict**
Make sure you removed ALL three marker lines (`<<<<<<<`, `=======`, `>>>>>>>`). Even one remaining marker will prevent Git from accepting the resolution.

**`git stash pop` causes a conflict**
Your stashed changes conflict with changes made while the stash was stored. Resolve the conflict the same way as a merge conflict, then `git add` the resolved file.

**`cannot delete branch — not fully merged`**
You are trying to delete a branch with `git branch -d` that has unmerged commits. Either merge it first, or use `git branch -D` to force-delete if you are sure you do not need those commits.

---

## 15. What you learned

By completing this lab you have practised:

- **Git fundamentals** — `init`, `add`, `commit`, `status`, `log` — the daily workflow
- **Staging area discipline** — understanding why the three-area model exists and staging deliberately
- **Conventional commits** — commit messages that serve as documentation and changelog
- **Branching strategy** — creating, naming, merging, and deleting feature branches
- **Remote workflows** — connecting to GitHub, pushing branches, `fetch` vs `pull`
- **Pull requests** — opening PRs with descriptions, reviewing, merging, cleaning up
- **Merge conflict resolution** — understanding markers, resolving conflicts, prevention mindset
- **Undoing mistakes** — `revert` vs `reset` vs `stash` — and knowing which to use when
- **Git forensics** — `blame`, `show`, `diff`, `log --grep` — investigating what happened
- **Security hygiene** — never committing secrets, using `.gitignore`, rotating exposed credentials

These are the skills that separate engineers who "use Git" from engineers who *understand* Git. Every command in your `commands.md` is something you can speak to confidently in an interview because you ran it, broke it, and fixed it yourself.

---

## Ticket reference

| Field | Value |
|---|---|
| Ticket ID | NXOPS-002 |
| Module | M2 — Git & Version Control |
| Phase | 1 — Foundation |
| Assignee (lead) | Engineer B |
| Reviewers | Engineers A & C |
| Estimate | 6–8 hours |
| Prerequisite | NXOPS-001B (Linux fundamentals) |

---

*NexaOps DevOps Bootcamp · Built with [Tech World with Nana](https://www.techworld-with-nana.com/) · Facilitated by Claude*
