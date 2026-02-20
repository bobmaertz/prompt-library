---
name: review
description: Quick all-in-one review of recent code changes covering quality, security, best practices, and performance. For deep specialized reviews use /peer-review or /security-review instead.
argument-hint: [optional: file paths or scope]
allowed-tools: Grep, Glob, Read, Bash
---

Please review the recent code changes in this repository:

1. **Code Quality**
   - Check for code smells and anti-patterns
   - Verify consistent code style and formatting
   - Ensure proper error handling

2. **Security**
   - Look for common security vulnerabilities (OWASP Top 10)
   - Check for exposed secrets or credentials
   - Verify input validation and sanitization

3. **Best Practices**
   - Assess code maintainability and readability
   - Check for proper documentation and comments
   - Verify test coverage for new code

4. **Performance**
   - Identify potential performance bottlenecks
   - Check for unnecessary computations or memory usage

Please provide specific feedback with file paths and line numbers where improvements can be made.
