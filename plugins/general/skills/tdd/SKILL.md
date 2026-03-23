---
name: tdd
description: Implements features using strict TDD red-green-refactor cycle. Use when asked to implement using TDD, test-first development, red-green flow, write tests first, or when translating a spec or requirements precisely into working code without over-engineering.
argument-hint: [spec, requirement, or feature description]
allowed-tools: Read, Glob, Grep, Bash, Edit, Write
---

# TDD Implementer

Implements features using disciplined red-green-refactor. One small cycle at a time. Nothing more than the spec asks for.

## Core Rules

1. **No production code before a failing test.** Always.
2. **Write only enough code to make the failing test pass.** Nothing extra.
3. **Follow the spec precisely.** Do not anticipate unstated requirements.
4. **Keep cycles small.** Each red-green loop should cover one behavior.
5. **Tests are the specification.** If behavior isn't tested, it doesn't exist yet.

## Process

### Step 0 — Read the Spec

Before writing anything:

1. Read the specification, requirement, or feature description fully.
2. Identify the behaviors the spec requires — list them explicitly.
3. Order them from simplest to most complex.
4. Pick only the first (simplest) behavior to implement next.

If `$ARGUMENTS` provides the spec or context, start there. Otherwise read the relevant files.

Do not proceed until you have a clear, ordered list of required behaviors.

### Step 1 — RED: Write a Failing Test

Write the smallest test that captures the next required behavior:

- Name the test to describe the behavior, not the implementation.
- Use the project's existing test framework and conventions (read existing tests first).
- Assert exactly one thing per test.
- Do not write the implementation yet — write the test against an interface that doesn't exist.

Run the test and confirm it **fails for the right reason**:
```bash
# Run only the new test
# The failure should be a missing implementation, not a syntax error or wrong assertion
```

If the test passes immediately, it is either wrong or the behavior already exists. Investigate before continuing.

If the test fails for the wrong reason (e.g., import error, test setup bug), fix the test first — do not move to green until the failure is meaningful.

### Step 2 — GREEN: Write Minimum Code

Write the simplest code that makes the failing test pass:

- Implement only what the test requires. Nothing more.
- Hardcoding a return value is acceptable if it makes the test pass — the next test will force generalization.
- Do not add parameters, configuration, or logic the test doesn't exercise.
- Do not handle edge cases not covered by a test.

Run the full test suite:
```bash
# All tests must pass before moving to refactor
```

If other tests break, fix them before moving on.

### Step 3 — REFACTOR: Clean Without Changing Behavior

With all tests green, improve the code:

- Remove duplication (in both tests and implementation).
- Improve names to reflect intent clearly.
- Simplify logic where possible.
- Do not add new functionality during refactor.
- Run the full test suite after each change to confirm nothing broke.

Stop when the code is clean and expressive. Do not over-polish.

### Step 4 — Repeat

Return to Step 1 with the next behavior from the list.

Continue until all behaviors in the spec are implemented and tested.

## What "Simple" Means

Simple means: the smallest code that correctly satisfies the spec.

- Prefer a plain function over a class if a class isn't needed.
- Prefer a flat structure over nested abstraction.
- Prefer explicit over clever.
- No config flags for behavior that isn't configurable in the spec.
- No base classes, interfaces, or generics unless the spec requires variation.

## Staying Faithful to the Spec

Before each cycle, re-read the relevant portion of the spec. Ask:

- Does the test I'm about to write reflect what the spec actually says?
- Am I adding behavior the spec doesn't ask for?
- Am I interpreting the spec or implementing it?

If a spec is ambiguous, surface the ambiguity explicitly before proceeding. Do not resolve it silently.

## Cycle Output Format

After each red-green-refactor cycle, report:

```
## Cycle N — [Behavior implemented]

**Red**: [Test name] — failed with: [failure reason]
**Green**: [What was added to pass it]
**Refactor**: [What was cleaned up, or "none needed"]

Remaining behaviors: [list]
```

This keeps the work visible and confirms the cycle completed correctly.

## Example

**Spec**: A `Stack` that supports `push`, `pop`, and `isEmpty`. `pop` on an empty stack raises an error.

**Ordered behaviors**:
1. New stack is empty
2. Stack is not empty after a push
3. Pop returns the last pushed value
4. Pop removes the item (stack is empty again after popping the only item)
5. Pop on empty stack raises an error

**Cycle 1 — New stack is empty**

Red:
```python
def test_new_stack_is_empty():
    s = Stack()
    assert s.is_empty()
```
Fails: `NameError: name 'Stack' is not defined`

Green:
```python
class Stack:
    def is_empty(self):
        return True
```

Refactor: none needed.

**Cycle 2 — Stack is not empty after a push**

Red:
```python
def test_not_empty_after_push():
    s = Stack()
    s.push(1)
    assert not s.is_empty()
```
Fails: `AttributeError: 'Stack' object has no attribute 'push'`

Green:
```python
class Stack:
    def __init__(self):
        self._items = []

    def push(self, item):
        self._items.append(item)

    def is_empty(self):
        return len(self._items) == 0
```

Both tests pass. Refactor: none needed.

...and so on.
