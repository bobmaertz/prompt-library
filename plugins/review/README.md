# Code Review Plugin

Peer review and security review agents designed to run as background tasks after your primary implementation agent finishes. Catches quality issues and security vulnerabilities before you commit.

## Commands

| Command | Description |
|---------|-------------|
| `/review` | Quick all-in-one review covering quality, security, best practices, and performance |
| `/peer-review` | Deep peer review on recent changes, run as a background agent |
| `/security-review` | Security-focused review (OWASP Top 10 and vulnerabilities), run as a background agent |

## Skills

| Skill | Description |
|-------|-------------|
| `peer-reviewer` | Reviews code for quality, best practices, performance, and maintainability |
| `security-reviewer` | Reviews code for OWASP Top 10, injection flaws, auth issues, and common vulnerabilities |

## Hooks

`hooks/hooks.json` defines a `PreToolUse` hook that intercepts `git commit` Bash commands and asks Claude to confirm peer review has been completed before allowing the commit to proceed.

## Workflow

### Recommended flow

```
1. Primary agent implements the feature/fix
2. /peer-review              ← runs as background fork agent
3. /security-review          ← runs as background fork agent (optional, for sensitive changes)
4. Address any findings
5. git commit                ← pre-commit hook reminds you to review findings
```

### Running reviews

After your implementation agent finishes, invoke either review command. Both run with `context: fork` so they execute as independent sub-agents without interrupting your main thread.

```
/peer-review
/peer-review src/auth/ src/api/

/security-review
/security-review src/auth/
```

## Review Coverage

### Peer Review
- Code quality and readability
- Adherence to project conventions (detected from codebase)
- Performance and efficiency
- Test coverage and test quality
- Documentation and naming
- DRY / SOLID principles
- Error handling

### Security Review
- OWASP Top 10
- Injection vulnerabilities (SQL, command, LDAP, XPath)
- Authentication and authorization flaws
- Sensitive data exposure (secrets, PII, credentials)
- Insecure deserialization
- Dependency vulnerabilities
- Input validation and sanitization
- Security headers and CORS
