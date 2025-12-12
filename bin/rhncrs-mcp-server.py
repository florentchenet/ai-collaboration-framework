#!/usr/bin/env python3
"""
RHNCRS MCP Server - Model Context Protocol Server for RHINOCEROS Ecosystem
Enables fast communication and context sharing between Claude and Gemini
"""

import os
import json
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional
import asyncio

# MCP SDK imports (install with: pip install mcp)
try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp import types
except ImportError:
    print("Error: MCP SDK not installed. Run: pip install mcp")
    exit(1)

# Configuration
VAULT_PATH = Path("/Users/hoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab")
PROJECT_ROOT = Path("/Users/hoe/Dev/org")
VAULT_MANAGER = Path("/Users/hoe/Dev/workspace/tools/gemini-vault")

# Initialize MCP Server
server = Server("rhncrs-ecosystem")

#  ═══════════════════════════════════════════════════════════
#  RESOURCES - Shared context between Claude and Gemini
#  ═══════════════════════════════════════════════════════════

@server.list_resources()
async def list_resources() -> List[types.Resource]:
    """List all available resources in the RHINOCEROS ecosystem"""
    return [
        types.Resource(
            uri="rhncrs://vault/structure",
            name="Vault Structure",
            mimeType="application/json",
            description="Complete structure of the rhncrs-collab Obsidian vault"
        ),
        types.Resource(
            uri="rhncrs://vault/stats",
            name="Vault Statistics",
            mimeType="application/json",
            description="Statistics about the vault (file counts, sizes, etc.)"
        ),
        types.Resource(
            uri="rhncrs://projects/list",
            name="Project List",
            mimeType="application/json",
            description="List of all RHINOCEROS projects with metadata"
        ),
        types.Resource(
            uri="rhncrs://projects/rhinoceros-music",
            name="Rhinoceros Music Project",
            mimeType="application/json",
            description="Rhinoceros Music project information and structure"
        ),
        types.Resource(
            uri="rhncrs://projects/rhinocrash",
            name="RhinoCrash Project",
            mimeType="application/json",
            description="RhinoCrash development tools project"
        ),
        types.Resource(
            uri="rhncrs://projects/rhncrsv1",
            name="RHNCRS V1 Platform",
            mimeType="application/json",
            description="Legacy platform project"
        ),
        types.Resource(
            uri="rhncrs://projects/infrastructure",
            name="Infrastructure Core",
            mimeType="application/json",
            description="Server infrastructure project"
        ),
        types.Resource(
            uri="rhncrs://projects/infrastructure-swarm",
            name="Infrastructure Swarm",
            mimeType="application/json",
            description="Docker Swarm UI project"
        ),
        types.Resource(
            uri="rhncrs://shared-state",
            name="Shared State",
            mimeType="application/json",
            description="Shared context and state between Claude and Gemini"
        ),
    ]

@server.read_resource()
async def read_resource(uri: str) -> str:
    """Read resource content"""

    if uri == "rhncrs://vault/structure":
        result = subprocess.run(
            [str(VAULT_MANAGER), "structure"],
            capture_output=True,
            text=True
        )
        return result.stdout

    elif uri == "rhncrs://vault/stats":
        result = subprocess.run(
            [str(VAULT_MANAGER), "stats"],
            capture_output=True,
            text=True
        )
        return result.stdout

    elif uri == "rhncrs://projects/list":
        projects = {
            "projects": [
                {
                    "id": "rhinoceros-music",
                    "name": "Rhinoceros Music",
                    "path": str(PROJECT_ROOT / "rhinoceros-music"),
                    "vault_path": "10_Projects/11_Rhinoceros_Music",
                    "description": "Creative hub, hardware, production"
                },
                {
                    "id": "rhinocrash",
                    "name": "RhinoCrash",
                    "path": str(PROJECT_ROOT / "rhinocrash"),
                    "vault_path": "10_Projects/12_Rhinocrash",
                    "description": "Development tools, RhinoChat agents"
                },
                {
                    "id": "rhncrsv1",
                    "name": "RHNCRS V1",
                    "path": str(PROJECT_ROOT / "rhncrsv1"),
                    "vault_path": "10_Projects/13_Rhncrs_V1",
                    "description": "Platform infrastructure, streaming"
                },
                {
                    "id": "infrastructure",
                    "name": "Infrastructure",
                    "path": str(PROJECT_ROOT / "infrastructure"),
                    "vault_path": "10_Projects/14_Infrastructure",
                    "description": "Server management"
                },
                {
                    "id": "infrastructure-swarm",
                    "name": "Infrastructure Swarm",
                    "path": str(PROJECT_ROOT / "infrastructure-swarm"),
                    "vault_path": "10_Projects/15_Infra_Swarm",
                    "description": "Web UI for infrastructure"
                },
            ]
        }
        return json.dumps(projects, indent=2)

    elif uri.startswith("rhncrs://projects/"):
        project_id = uri.split("/")[-1]
        project_path = PROJECT_ROOT / project_id

        if not project_path.exists():
            return json.dumps({"error": f"Project not found: {project_id}"})

        # Gather project information
        info = {
            "id": project_id,
            "path": str(project_path),
            "exists": True,
            "files": []
        }

        # List key files
        for item in project_path.rglob("*.md"):
            if not any(part.startswith(".") for part in item.parts):
                info["files"].append(str(item.relative_to(project_path)))

        # Read README if exists
        readme_path = project_path / "README.md"
        if readme_path.exists():
            info["readme"] = readme_path.read_text()

        return json.dumps(info, indent=2)

    elif uri == "rhncrs://shared-state":
        # Read shared state file (for coordination between agents)
        state_file = VAULT_PATH / "90_Admin" / "shared-state.json"
        if state_file.exists():
            return state_file.read_text()
        else:
            return json.dumps({"initialized": False, "messages": []})

    else:
        return json.dumps({"error": f"Unknown resource: {uri}"})

#  ═══════════════════════════════════════════════════════════
#  TOOLS - Operations available to both Claude and Gemini
#  ═══════════════════════════════════════════════════════════

@server.list_tools()
async def list_tools() -> List[types.Tool]:
    """List all available tools"""
    return [
        types.Tool(
            name="vault_write",
            description="Write content to a file in the Obsidian vault",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "Relative path within vault"},
                    "content": {"type": "string", "description": "File content to write"}
                },
                "required": ["path", "content"]
            }
        ),
        types.Tool(
            name="vault_read",
            description="Read content from a file in the Obsidian vault",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "Relative path within vault"}
                },
                "required": ["path"]
            }
        ),
        types.Tool(
            name="vault_list",
            description="List files in a vault directory",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "Directory path (default: root)"}
                }
            }
        ),
        types.Tool(
            name="vault_tree",
            description="Show directory tree structure",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "Directory path"},
                    "depth": {"type": "number", "description": "Tree depth (default: 3)"}
                }
            }
        ),
        types.Tool(
            name="project_read_file",
            description="Read a file from one of the project repositories",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {"type": "string", "description": "Project ID (e.g., 'rhinoceros-music')"},
                    "path": {"type": "string", "description": "Relative path within project"}
                },
                "required": ["project", "path"]
            }
        ),
        types.Tool(
            name="shared_state_update",
            description="Update shared state for coordination between agents",
            inputSchema={
                "type": "object",
                "properties": {
                    "message": {"type": "string", "description": "Message to add to shared state"},
                    "data": {"type": "object", "description": "Additional data to store"}
                },
                "required": ["message"]
            }
        ),
        types.Tool(
            name="shared_state_read",
            description="Read current shared state",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
    ]

@server.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[types.TextContent]:
    """Execute tool calls"""

    if name == "vault_write":
        path = arguments["path"]
        content = arguments["content"]
        result = subprocess.run(
            [str(VAULT_MANAGER), "write", path, content],
            capture_output=True,
            text=True
        )
        return [types.TextContent(type="text", text=result.stdout)]

    elif name == "vault_read":
        path = arguments["path"]
        result = subprocess.run(
            [str(VAULT_MANAGER), "read", path],
            capture_output=True,
            text=True
        )
        return [types.TextContent(type="text", text=result.stdout)]

    elif name == "vault_list":
        path = arguments.get("path", ".")
        result = subprocess.run(
            [str(VAULT_MANAGER), "list", path],
            capture_output=True,
            text=True
        )
        return [types.TextContent(type="text", text=result.stdout)]

    elif name == "vault_tree":
        path = arguments.get("path", ".")
        depth = str(arguments.get("depth", 3))
        result = subprocess.run(
            [str(VAULT_MANAGER), "tree", path, depth],
            capture_output=True,
            text=True
        )
        return [types.TextContent(type="text", text=result.stdout)]

    elif name == "project_read_file":
        project = arguments["project"]
        path = arguments["path"]
        file_path = PROJECT_ROOT / project / path

        if not file_path.exists():
            return [types.TextContent(type="text", text=f"Error: File not found: {path}")]

        content = file_path.read_text()
        return [types.TextContent(type="text", text=content)]

    elif name == "shared_state_update":
        message = arguments["message"]
        data = arguments.get("data", {})

        state_file = VAULT_PATH / "90_Admin" / "shared-state.json"

        # Read current state
        if state_file.exists():
            state = json.loads(state_file.read_text())
        else:
            state = {"initialized": True, "messages": []}

        # Add new message
        state["messages"].append({
            "timestamp": str(asyncio.get_event_loop().time()),
            "message": message,
            "data": data
        })

        # Write updated state
        state_file.parent.mkdir(parents=True, exist_ok=True)
        state_file.write_text(json.dumps(state, indent=2))

        return [types.TextContent(type="text", text=f"State updated: {message}")]

    elif name == "shared_state_read":
        state_file = VAULT_PATH / "90_Admin" / "shared-state.json"

        if state_file.exists():
            content = state_file.read_text()
        else:
            content = json.dumps({"initialized": False, "messages": []})

        return [types.TextContent(type="text", text=content)]

    else:
        return [types.TextContent(type="text", text=f"Unknown tool: {name}")]

#  ═══════════════════════════════════════════════════════════
#  MAIN - Run the MCP server
#  ═══════════════════════════════════════════════════════════

async def main():
    """Run the MCP server"""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())
