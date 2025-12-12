import os
import json
import shutil
from pathlib import Path
from datetime import datetime

# --- Configuration ---
HOME = Path.home()
VAULT_ROOT = HOME / "Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab"
SOURCE_ROOT = HOME / "Dev/org"

# Mapping: Vault Folder -> Source Repo Name
PROJECTS = {
    "11_Rhinoceros_Music": "rhinoceros-music",
    "12_Rhinocrash": "rhinocrash",
    "13_Rhncrs_V1": "rhncrsv1",
    "14_Infrastructure": "infrastructure",
    "15_Infra_Swarm": "infrastructure-swarm"
}

TODAY = datetime.now().strftime("%Y-%m-%d")

# --- Templates ---
TEMPLATES = {
    "Architecture": """---
type: architecture
project: {project_name}
tags: [#{project_tag}, #type/architecture]
created: {date}
updated: {date}
---

# Architecture: {project_title}

## Overview
{overview}

## Tech Stack
{tech_stack}

## Components
- **Core:**
- **Services:**

## Data Flow
(Describe how data moves through the system)
""",
    "API": """---
type: api
project: {project_name}
tags: [#{project_tag}, #type/api]
created: {date}
updated: {date}
---

# API Documentation: {project_title}

## Endpoints

### `GET /`
- **Description:** Health check or root endpoint.
- **Response:** `200 OK`

## Data Models
(Define JSON schemas here)
""",
    "Deployment": """---
type: deployment
project: {project_name}
tags: [#{project_tag}, #type/deployment]
created: {date}
updated: {date}
---

# Deployment: {project_title}

## Prerequisites
- Docker / Docker Compose
- Access to rhncrs.com VPS

## Configuration
See `docker-compose.yml` for service definitions.

## Deploy Commands
```bash
docker-compose up -d
```
""",
    "Development": """---
type: development
project: {project_name}
tags: [#{project_tag}, #type/development]
created: {date}
updated: {date}
---

# Development Guide: {project_title}

## Setup
1. Clone the repository: `git clone ...`
2. Install dependencies:
   ```bash
   {install_cmd}
   ```

## Testing
Run tests using:
```bash
{test_cmd}
```

## Workflow
- Use semantic commit messages.
- Push to main branch for deployment.
"""
}

def read_file_safe(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return None

def parse_package_json(path):
    content = read_file_safe(path)
    if not content:
        return {}, ""
    try:
        data = json.loads(content)
        stack = []
        if "dependencies" in data:
            stack.extend([f"{k}: {v}" for k, v in data["dependencies"].items()])
        return data, "\n".join([f"- {s}" for s in stack])
    except json.JSONDecodeError:
        return {}, "Error parsing package.json"

def process_project(vault_name, source_name):
    print(f"🔹 Processing {vault_name} (Source: {source_name})...")

    project_dir = VAULT_ROOT / "1_Projects" / vault_name
    source_dir = SOURCE_ROOT / source_name

    if not source_dir.exists():
        print(f"   ⚠️  Source not found: {source_dir}")
        return

    project_dir.mkdir(parents=True, exist_ok=True)

    # Analyze Source
    readme = read_file_safe(source_dir / "README.md") or "No README found."
    pkg_data, tech_stack = parse_package_json(source_dir / "package.json")

    # Determine Project Title & Tag
    title = vault_name.replace("_", " ").split(" ", 1)[1] if "_" in vault_name else vault_name
    tag = "domain/" + source_name.replace("-", "/")

    # Generate Docs
    files = {
        "Architecture.md": TEMPLATES["Architecture"].format(
            project_name=vault_name, project_tag=tag, project_title=title, date=TODAY,
            overview=readme[:500] + "...", tech_stack=tech_stack or "Not specified"
        ),
        "API.md": TEMPLATES["API"].format(
            project_name=vault_name, project_tag=tag, project_title=title, date=TODAY
        ),
        "Deployment.md": TEMPLATES["Deployment"].format(
            project_name=vault_name, project_tag=tag, project_title=title, date=TODAY
        ),
        "Development.md": TEMPLATES["Development"].format(
            project_name=vault_name, project_tag=tag, project_title=title, date=TODAY,
            install_cmd="npm install" if pkg_data else "pip install -r requirements.txt",
            test_cmd="npm test" if pkg_data else "pytest"
        )
    }

    for filename, content in files.items():
        file_path = project_dir / filename
        if not file_path.exists():
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"   ✅ Created {filename}")
        else:
            print(f"   ⏭️  {filename} already exists. Skipping.")

def create_area_placeholders():
    print("🔹 Creating Area Placeholders...")
    areas = {
        "21_Audio_Engineering": "Signal flow guides, mixing checklists.",
        "22_AI_Systems": "Prompt patterns, agent architectures.",
        "23_DevOps": "Docker patterns, CI/CD guides.",
        "24_Business_Admin": "Operations docs, financial summaries."
    }

    for area, desc in areas.items():
        area_dir = VAULT_ROOT / "2_Areas" / area
        area_dir.mkdir(parents=True, exist_ok=True)

        readme_path = area_dir / "README.md"
        if not readme_path.exists():
            content = f"---\ntags: [#area/{area}]\ncreated: {TODAY}\n---\n\n# {area.replace('_', ' ')}\n\n{desc}\n\n## Topics\n- \n"
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"   ✅ Created {area}/README.md")

def update_system():
    print("🔹 Updating System Folders...")
    # Admin Templates
    templates_dir = VAULT_ROOT / "9_System/Admin/Templates"
    templates_dir.mkdir(parents=True, exist_ok=True)

    new_templates = ["Meeting_Note.md", "Incident_Report.md", "Daily_Note.md"]
    for tmpl in new_templates:
        path = templates_dir / tmpl
        if not path.exists():
            with open(path, 'w', encoding='utf-8') as f:
                f.write(f"# {tmpl.replace('.md', '').replace('_', ' ')}\n\nDate: {{date}}\n\n## Content\n")
            print(f"   ✅ Created Template: {tmpl}")

def main():
    if not VAULT_ROOT.exists():
        print(f"❌ Vault root not found: {VAULT_ROOT}")
        return

    print("🚀 Starting Vault Population...")

    # 1. Process Projects
    for v_name, s_name in PROJECTS.items():
        process_project(v_name, s_name)

    # 2. Areas
    create_area_placeholders()

    # 3. System
    update_system()

    print("\n✅ Vault Population Complete!")

if __name__ == "__main__":
    main()
