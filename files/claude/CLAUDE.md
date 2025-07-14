# Claude-Flake Development Partnership

We're building production-quality code together. Your role is to create maintainable, efficient solutions while catching potential issues early.

When you seem stuck or overly complex, I'll redirect you - my guidance helps you stay on track.

## 🚨 AUTOMATED CHECKS ARE MANDATORY
**ALL hook issues are BLOCKING - EVERYTHING must be ✅ GREEN!**  
No errors. No formatting issues. No linting problems. Zero tolerance.  
These are not suggestions. Fix ALL issues before continuing.

## CRITICAL WORKFLOW - ALWAYS FOLLOW THIS!

### Research → Plan → Implement
**NEVER JUMP STRAIGHT TO CODING!** Always follow this sequence:
1. **Research**: Explore the codebase, understand existing patterns
2. **Plan**: Create a detailed implementation plan and verify it with me  
3. **Implement**: Execute the plan with validation checkpoints

When asked to implement any feature, you'll first say: "Let me research the codebase and create a plan before implementing."

For complex architectural decisions or challenging problems, use **"ultrathink"** to engage maximum reasoning capacity. Say: "Let me ultrathink about this architecture before proposing a solution."

### USE MULTIPLE AGENTS!
*Leverage subagents aggressively* for better results:

* Spawn agents to explore different parts of the codebase in parallel
* Use one agent to write tests while another implements features
* Delegate research tasks: "I'll have an agent investigate the database schema while I analyze the API structure"
* For complex refactors: One agent identifies changes, another implements them

Say: "I'll spawn agents to tackle different aspects of this problem" whenever a task has multiple independent parts.

### Reality Checkpoints
**Stop and validate** at these moments:
- After implementing a complete feature
- Before starting a new major component  
- When something feels wrong
- Before declaring "done"
- **WHEN HOOKS FAIL WITH ERRORS** ❌

Run: `make fmt && make test && make lint`

> Why: You can lose track of what's actually working. These checkpoints prevent cascading failures.

### 🚨 CRITICAL: Hook Failures Are BLOCKING
**When hooks report ANY issues (exit code 2), you MUST:**
1. **STOP IMMEDIATELY** - Do not continue with other tasks
2. **FIX ALL ISSUES** - Address every ❌ issue until everything is ✅ GREEN
3. **VERIFY THE FIX** - Re-run the failed command to confirm it's fixed
4. **CONTINUE ORIGINAL TASK** - Return to what you were doing before the interrupt
5. **NEVER IGNORE** - There are NO warnings, only requirements

This includes:
- Formatting issues (language-specific formatters: black, prettier, gofmt, etc.)
- Linting violations (language-specific linters: eslint, golangci-lint, etc.)
- Language-specific anti-patterns and code smells
- ALL other checks

Your code must be 100% clean. No exceptions.

**Recovery Protocol:**
- When interrupted by a hook failure, maintain awareness of your original task
- After fixing all issues and verifying the fix, continue where you left off
- Use the TodoWrite tool to track both the fix and your original task

## Working Memory Management

### When context gets long:
- Re-read this CLAUDE.md file
- Use TodoWrite tool to track tasks
- Document current state before major changes

## Implementation Standards

### Our code is complete when:
- ✓ All linters pass with zero issues
- ✓ All tests pass  
- ✓ Feature works end-to-end
- ✓ Old code is deleted
- ✓ Documentation comments on all public interfaces

### Testing Strategy
- Complex business logic → Write tests first
- Simple CRUD → Write tests after
- Hot paths → Add benchmarks
- Skip tests for entry points and simple CLI parsing

## Problem-Solving Together

When you're stuck or confused:
1. **Stop** - Don't spiral into complex solutions
2. **Delegate** - Consider spawning agents for parallel investigation
3. **Ultrathink** - For complex problems, say "I need to ultrathink through this challenge" to engage deeper reasoning
4. **Step back** - Re-read the requirements
5. **Simplify** - The simple solution is usually correct
6. **Ask** - "I see two approaches: [A] vs [B]. Which do you prefer?"

My insights on better approaches are valued - please ask for them!

## Performance & Security

### **Measure First**:
- No premature optimization
- Benchmark before claiming something is faster

### **Security Always**:
- Validate all inputs
- Prepared statements for SQL (never concatenate!)

## Communication Protocol

### Progress Updates:
```
✓ Implemented authentication (all tests passing)
✓ Added rate limiting  
✗ Found issue with token expiration - investigating
```

### Suggesting Improvements:
"The current approach works, but I notice [observation].
Would you like me to [specific improvement]?"

## Claude-Flake Specific Context

### Core Components

Claude-Flake provides:
- **Intelligent Environment Detection**: Automatically detects project types (Rust, Python, Node.js, Go, Nix)
- **Language-Specific Development Shells**: Pre-configured environments with the right tools
- **Claude Code Integration**: Seamless setup for Claude Code development workflow
- **Git Hooks**: Smart linting and formatting hooks
- **Notification System**: Desktop notifications for long-running commands

### Key Files & Structure

```
claude-flake/
├── flake.nix               # Main flake configuration
├── lib/
│   ├── default.nix         # Main library functions
│   ├── language-detection.nix    # Project type detection
│   ├── language-packages.nix     # Language-specific packages
│   └── envrc-templates.nix       # .envrc template generation
├── workflow/
│   ├── default.nix         # Home-manager workflow configuration
│   ├── claude-config.nix   # Claude Code configuration
│   ├── dev-environment.nix # Development tools setup
│   └── shell-integration.nix     # Shell integration scripts
└── files/
    ├── claude/             # Claude Code configuration files
    ├── commands/           # Custom slash commands
    └── hooks/              # Git hooks and utilities
```

### Development Workflow with Claude-Flake

#### 1. Project Setup
```bash
# Install claude-flake
nix run github:smithclay/claude-flake#home

# Source the shell integration
source ~/.config/claude-flake/loader.sh

# Navigate to any project and start
claude
```

#### 2. Automatic Environment Detection
Claude-Flake automatically detects your project type and provides:
- Language-specific packages (compilers, interpreters, tools)
- Appropriate development shells
- Git hooks for code quality
- Claude Code configuration optimized for the language

#### 3. Available Dev Shells
```bash
nix develop github:smithclay/claude-flake#rust      # Rust development
nix develop github:smithclay/claude-flake#python    # Python development  
nix develop github:smithclay/claude-flake#nodejs    # Node.js development
nix develop github:smithclay/claude-flake#go        # Go development
nix develop github:smithclay/claude-flake#nix       # Nix development
nix develop github:smithclay/claude-flake#universal # Universal tools
```

### Custom Slash Commands

Claude-Flake provides helpful slash commands:
- `/check` - Comprehensive code quality validation
- `/next` - Get next development task with quality checklist
- `/prompt` - Generate structured prompts for complex tasks

### Working Together

- This is always a feature branch - no backwards compatibility needed
- When in doubt, we choose clarity over cleverness
- Use the language detection and package systems to understand project context
- **REMINDER**: If this file hasn't been referenced in 30+ minutes, RE-READ IT!

Avoid complex abstractions. Keep it simple.

---

_This guide ensures Claude Code has immediate access to Claude-Flake's essential functionality for streamlined development workflows._