![GitHub commit activity](https://img.shields.io/github/commit-activity/y/mgmodell/CoLab?style=flat-square)
![GitHub language count](https://img.shields.io/github/languages/count/mgmodell/CoLab)
[![CodeQL](https://github.com/mgmodell/CoLab/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/mgmodell/CoLab/actions/workflows/github-code-scanning/codeql)[![Dependabot Updates](https://github.com/mgmodell/CoLab/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/mgmodell/CoLab/actions/workflows/dependabot/dependabot-updates)

# README #

The CoLab system provides instructor support for collaborative learning
groups. In its current state, it deploys successfully to Heroku with
Amazon SES & S3 (using ActiveStorage), Scheduler and JAWS Maria DB add-ons with a libVips
buildpack. It should run in a paid dyno with SSL enabled or a configuration
change would be required.

## What is this repository for? ##

The CoLab system which is based upon and supports the continued
research of Micah Gideon Modell, Ph.D.

## How do I get set up? ##

CoLab uses [Podman](https://podman.io/) containers for all development and testing. The entire
toolchain runs inside containers managed by [devContainers](https://containers.dev/) and
[VS Code](https://code.visualstudio.com/), so your host machine needs only a small set of tools
installed. Development is supported on **macOS**, **Linux**, and **Windows** (via WSL2).

---

### Prerequisites

#### All platforms

| Tool | Notes |
|------|-------|
| [Podman Desktop](https://podman-desktop.io/) | Includes `podman`, `podman compose`, and the Podman Machine (VM) backend. Required on macOS and Windows; on Linux you can install `podman` and `podman-compose` via your package manager instead. |
| [VS Code](https://code.visualstudio.com/) | With the **[Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)** extension (`ms-vscode-remote.remote-containers`) installed. |
| [Git](https://git-scm.com/) | To clone the repository. |

> **Memory**: Podman Machine needs at least 8 GB of RAM. Configure it with:
> ```
> podman machine set -m 8192
> ```

#### Windows-only additional requirements

1. **WSL2** — required by Podman Desktop. Enable it in PowerShell (as Administrator) and then reboot:
   ```powershell
   wsl --install
   ```
2. **Configure VS Code to use Podman** — add the following to your VS Code user settings (`File → Preferences → Settings`, search for `dockerPath`):
   ```json
   "dev.containers.dockerPath": "podman"
   ```
   Alternatively, set the `DOCKER_HOST` environment variable to the Podman socket before launching VS Code.

#### macOS-only note

Podman Desktop installs a Podman Machine automatically. No extra steps are needed beyond installing Podman Desktop and VS Code. See the [macOS rootless Podman — extra step](#macos-rootless-podman--extra-step) section below for instructions on making the bind-mounted source tree writable.

---

### Step 1 — Clone the repository

(**Recommended**) First, [set up SSH keys on GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

Open a terminal (on Windows, use **PowerShell** or **Windows Terminal**) and run:

```bash
# Using SSH (recommended)
git clone git@github.com:mgmodell/CoLab.git

# Or using HTTPS
git clone https://github.com/mgmodell/CoLab.git
```

Navigate into the project directory:
```bash
cd CoLab
```

---

### Step 2 — Build the container images

The container images must be built before opening the devcontainer in VS Code.

#### macOS / Linux (bash)
```bash
./buildContainers.sh -b
```

To build only the dev containers (faster, skips the test container):
```bash
./buildContainers.sh -d
```

Run `./buildContainers.sh -h` for a full list of options.

#### Windows (PowerShell)
```powershell
.\buildContainers.ps1 -Both
```

To build only the dev containers:
```powershell
.\buildContainers.ps1 -DevOnly
```

Run `.\buildContainers.ps1 -Help` for a full list of options.

> **Note**: The build uses the project root as the build context (required for `COPY` instructions inside the Dockerfiles). Run the script from the project root directory.

---

### Step 3 — (Optional) Configure environment variables

Copy `.env.example` to `.env` and fill in any values you need:

```bash
cp .env.example .env
```

The `.env` file is gitignored. Add any environment variables you need here; see `.env.example` for the available options.

---

### Step 4 — Open the devcontainer in VS Code

1. Open VS Code in the project directory:
   ```bash
   code .
   ```
2. VS Code will detect the devcontainer configuration and show a notification: **"Reopen in Container"**. Click it.
   - If the notification doesn't appear, open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run **"Dev Containers: Reopen in Container"**.
3. VS Code will start all services (`db`, `redis`, `browser`, `moodle`, `selenium`) and attach to the `app` container.
4. On first open, `postCreateCommand` runs automatically to install the Ruby/Node toolchain via `mise` and install all gems. This takes a few minutes.

#### Linux rootless Podman — extra step

On Linux with rootless Podman, the bind-mounted source tree needs `userns_mode: keep-id` so that container file writes are owned by your host user. Enable it by referencing the provided override in `.devcontainer/devcontainer.json`:

```json
"dockerComposeFile": [
  "../containers/dev_env/docker-compose.yml",
  "../containers/dev_env/docker-compose.rootless.yml"
]
```

> **Windows**: do **not** add the rootless override. On Windows/WSL2 it causes an *"unsupported UNC path"* error when Podman tries to forward the WSLg Wayland socket into the container.

#### macOS rootless Podman — extra step

On macOS, Podman shares the host filesystem into its Linux VM via virtiofs, which passes macOS file ownership (UID 501 / GID 20 for the first macOS user) directly into the container. The default container user `colab` has UID 1000 and therefore cannot write to those files.

A macOS-specific compose override rebuilds the dev-server image so that the `colab` user inside the container has UID 501, matching the macOS host user. Enable it by referencing it in `.devcontainer/devcontainer.json`:

```json
"dockerComposeFile": [
  "../containers/dev_env/docker-compose.yml",
  "../containers/dev_env/docker-compose.macos.yml"
]
```

After adding the override, run **"Dev Containers: Rebuild and Reopen in Container"** (Command Palette: `Cmd+Shift+P`) so the image is rebuilt with the correct UID.

> **Linux / Windows**: do **not** add the macOS override. It hardcodes a macOS-specific UID that will break file ownership on other platforms.

The following ports are forwarded automatically to your host machine:

| Port | Service |
|------|---------|
| 3000 | Rails development server |
| 3035 | Shakapacker (JavaScript) dev server |
| 4444 | Selenium WebDriver |
| 6080 | VNC browser (noVNC web UI) |
| 8080 | Moodle LMS |

---

### Step 5 — Set up the development database

Inside the VS Code terminal (which runs inside the devcontainer), prepare the database:

```bash
./dev_serv.sh -p
```

To load a pre-existing database snapshot (if you have one in `db/dev_db.sql`), run this from a terminal **on your host machine** (not inside VS Code):

```bash
./mng_db.sh -j
```

---

### Step 6 — Create a test user and start the server

These commands run **inside the devcontainer** (use the VS Code integrated terminal):

```bash
# Create a test user with your email address and password 'password'
./dev_serv.sh -e "haccess[yourEmail@something.com]"

# Start the Rails development server
./dev_serv.sh -s
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

You can also view the integrated VNC browser at [http://localhost:6080](http://localhost:6080), or connect a native VNC client to [vnc://localhost:5909](vnc://localhost:5909) (password: `password`).

> **Note**: `dev_serv.sh` is designed to run **inside the devcontainer**. It checks for the container environment and will print a warning if run on the host directly.

Run `./dev_serv.sh -h` inside the devcontainer to see all available options.

---

### Running the full test suite

`run_tests.sh` orchestrates the Cucumber test container and must be run from a terminal **outside VS Code** (on your host machine, or in WSL2):

```bash
# First-time: initialise the test database
./run_tests.sh -c

# Run all tests (rerun only failures from the previous run if any exist)
./run_tests.sh -r

# Show failures from the previous run without re-running
./run_tests.sh -s
```

Run `./run_tests.sh -h` for a full list of options.

### Database management

`mng_db.sh` manages database snapshots. Run it from your host machine (not inside the devcontainer). No host MySQL client is required — it uses `podman compose exec` internally, so the DB container must be running:

```bash
./mng_db.sh -j   # Load the dev DB snapshot (db/dev_db.sql)
./mng_db.sh -d   # Dump the current dev DB to db/dev_db.sql
./mng_db.sh -h   # Show all options
```

The script resolves all file and compose paths from its own location, so it works correctly regardless of which directory you invoke it from.

---

# Contribution instructions #
1. Review the issues
1. Find one that interests you
1. Assign it to yourself
1. Start working in your own branch
    * `git branch <enter_new_branch_name>`
    * `git checkout <enter_new_branch_name>`
1. Create what you need (inside the devcontainer terminal)
    * Run `./dev_serv.sh -e "haccess[yourEmail@something.com]"`
    * Run `./dev_serv.sh -e "examples[yourEmail@something.com]"`
1. Open [the test server](http://localhost:3000)
1. Play with it to understand the problem
1. Start writing tests
1. Check in your code
    * `git add <file name>`
    * ``git commit -m `<meaningful message>` ``
    * `git push`

## LTI 1.3 Integration

CoLab supports LTI 1.3 for single sign-on, roster provisioning, and grade sync with
Moodle, Canvas, Blackboard, Brightspace, and other compliant LMS platforms.

See [doc/LTI_INTEGRATION.md](doc/LTI_INTEGRATION.md) for step-by-step connection
instructions.

### Who do I talk to? ###

* @micah_gideon
* Ask on [Slack](https://mountsaintmarycollege.slack.com/archives/G01269L9DAT)

## Contributors
My wife, Misun, and my two children have been instrumental in making this possible by putting up with me throughout.
