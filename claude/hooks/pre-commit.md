---
description: Pre-commit validation hook for code quality checks
event: pre-commit
---

Before committing, please verify:

1. **Linting**: Run linters and fix any issues
2. **Tests**: Ensure all tests pass
3. **Formatting**: Code follows project formatting standards
4. **Security**: No secrets or credentials are being committed

If any checks fail, prevent the commit and provide clear feedback.
