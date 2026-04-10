---
name: datastar
description: Practical guidance for building and modifying Datastar apps and Datastar itself. Covers backend-driven UI flows, `data-*` attributes, backend actions, SSE patch events, and repo-aware pointers for the starfederation/datastar codebase.
---

# Datastar Skill

Use this skill when working on Datastar apps, debugging Datastar behavior, or making changes in the `starfederation/datastar` repository.

## What Datastar Is

Datastar is a hypermedia framework for backend-driven reactive web apps.

- Frontend behavior is expressed with declarative `data-*` HTML attributes.
- The backend drives UI updates by returning `text/html`, `application/json`, `text/javascript`, or `text/event-stream`.
- SSE is a first-class transport for incremental UI and state updates.
- The main mental model is: keep durable state on the server when possible, use frontend signals for interaction and presentation state.

Datastar sits in the overlap between:

- htmx-style backend requests and DOM patching
- Alpine-style declarative frontend reactivity
- lightweight realtime updates over SSE

## Default Working Approach

When implementing with Datastar, prefer this order:

1. Model the UI around server-rendered HTML fragments with stable IDs.
2. Use signals only for local interaction state, derived view state, and temporary request state.
3. Use `data-bind`, `data-signals`, `data-computed`, `data-effect`, `data-show`, `data-text`, and `data-on` before reaching for custom JavaScript.
4. Use backend actions like `@get()` / `@post()` to talk to the server.
5. Return HTML patches for DOM changes and SSE for streaming or multi-step updates.

Avoid turning Datastar into a client-heavy SPA. If a behavior can stay declarative or be driven by the backend, prefer that.

## Core Primitives

### Signals

Signals are referenced as `$name` in expressions.

- Create or patch signals with `data-signals`
- Two-way bind form values with `data-bind`
- Derive read-only values with `data-computed`
- Run side effects with `data-effect`
- Remove a signal by setting it to `null` or `undefined`

Examples:

```html
<div data-signals="{count: 0, user: {name: 'Ada'}}"></div>
<input data-bind:user-name />
<div data-computed:greeting="`Hello ${$userName}`"></div>
<p data-text="$greeting"></p>
```

Important details:

- Signal names from attribute suffixes are camel-cased by default.
- Signal names must not contain `__` because that delimiter is reserved for modifiers.
- Signals with `_` prefixes are excluded from backend requests by default.

### Attributes To Reach For First

- `data-signals`: define or patch signal values
- `data-bind`: two-way bind inputs, selects, textareas, and compatible web components
- `data-text`: bind text content
- `data-show`: toggle visibility based on an expression
- `data-class`: conditionally add/remove classes
- `data-attr`: bind arbitrary attributes
- `data-style`: bind inline styles while preserving original inline values
- `data-on`: attach event listeners and run Datastar expressions
- `data-effect`: perform side effects when dependent signals change
- `data-computed`: derive read-only signals
- `data-indicator`: expose in-flight fetch state as a signal
- `data-ref`: reference an element as a signal
- `data-json-signals`: inspect current signals during debugging

Useful but more situational:

- `data-init`: initialize behavior on load or reapplication
- `data-ignore`: keep Datastar off a subtree
- `data-ignore-morph`: protect a subtree from morph updates
- `data-preserve-attr`: preserve specific DOM attributes during morphing
- `data-on-signal-patch`: react to signal patches globally or through filters

### Actions

Use actions inside expressions with the `@action()` syntax.

Most common actions:

- `@get('/endpoint')`
- `@post('/endpoint')`
- `@put('/endpoint')`
- `@patch('/endpoint')`
- `@delete('/endpoint')`

High-value options:

- `filterSignals`: include/exclude which signals are sent
- `contentType: 'form'`: submit forms instead of sending signals as JSON/query params
- `headers`: add auth/CSRF/etc.
- `openWhenHidden`: keep GET SSE requests open in background tabs
- `requestCancellation`: control automatic abort behavior
- `payload`: override request payload

Examples:

```html
<button
  data-on:click="@post('/todos', {filterSignals: {include: /^todo/}})"
  data-indicator:saving
  data-attr:disabled="$saving"
>
  Save
</button>
<p data-show="$saving" style="display: none">Saving...</p>
```

### Backend Responses

Datastar backend actions understand these response types:

- `text/event-stream`: stream Datastar SSE events
- `text/html`: patch HTML into the DOM
- `application/json`: patch returned JSON into signals
- `text/javascript`: execute returned JavaScript in the browser

Prefer these response types in this order:

1. `text/html` for standard UI changes
2. `text/event-stream` for progressive or realtime updates
3. `application/json` for signal-only patches
4. `text/javascript` only when there is no cleaner declarative or HTML/SSE path

### SSE Events

The two key Datastar SSE events are:

- `datastar-patch-elements`
- `datastar-patch-signals`

Patch elements example:

```text
event: datastar-patch-elements
data: elements <div id="status">Saved</div>

```

Patch signals example:

```text
event: datastar-patch-signals
data: signals {status: 'saved', retries: 0}

```

Important details:

- SSE events must end with a blank line.
- For morphing, top-level elements should usually have stable IDs.
- `datastar-patch-elements` supports modes like `outer`, `inner`, `replace`, `prepend`, `append`, `before`, `after`, and `remove`.
- `datastar-patch-signals` supports `onlyIfMissing true`.

## Practical Patterns

### CRUD With Minimal JS

Use a form or button with `@post()`/`@patch()`/`@delete()`, then let the server return HTML for the changed region.

```html
<form>
  <input data-bind:title name="title" />
  <button data-on:click="@post('/todos')">Create</button>
</form>
<ul id="todo-list"></ul>
```

Have the server return:

```html
<ul id="todo-list">...</ul>
```

### Progressive Server Feedback

Use SSE when the backend needs to emit multiple UI updates over time.

- show queued state
- stream progress
- patch final result

### Local UI State

Keep client-only concerns in signals:

- currently open accordion row
- optimistic disable/loading flags
- unsaved draft text
- local filter text

Do not move authoritative domain state to frontend signals unless there is a clear need.

### Derived State

Use `data-computed` for pure derivations and `data-effect` for side effects.

- `data-computed`: totals, labels, booleans, filtered display values
- `data-effect`: fetches, assignments with side effects, DOM APIs, logging

### Stable Morph Targets

When returning HTML intended for morphing:

- put IDs on top-level patch targets
- also put IDs on important stateful descendants when their state should survive morphs
- use `data-preserve-attr` or `data-ignore-morph` when native DOM state must survive server patches

## Common Pitfalls

### Attribute Order Matters

Datastar applies attributes in DOM order.

If one attribute depends on a signal created by another, define the signal first.

Correct:

```html
<div data-indicator:fetching data-init="@get('/endpoint')"></div>
```

### Casing Surprises

- Signal-defining suffixes are camel-cased by default.
- Non-signal keys like classes and event names default to kebab-case.
- Use `__case` modifiers when integrating with names like `widgetLoaded`.

Example:

```html
<div data-on:widget-loaded__case.camel="console.log('loaded')"></div>
```

### Overusing `data-effect`

Do not use `data-effect` for pure derived values. Prefer `data-computed` for anything that should just calculate a value.

### Unnecessary Custom JavaScript

Before adding browser-side JS, check whether the same behavior can be expressed with:

- a Datastar attribute
- a backend action
- an HTML response patch
- an SSE stream

### Mixing Client and Server Authority

If the server owns the truth, do not duplicate that state in multiple frontend signals unless the duplication is explicitly temporary.

## Debugging Checklist

When behavior is wrong, check in this order:

1. The attribute name and modifier spelling match the reference.
2. The expression uses the signal name after Datastar casing rules.
3. Required signals exist before dependent attributes run.
4. Backend responses have the intended `Content-Type`.
5. SSE payloads are correctly formatted and terminated with blank lines.
6. Morph targets have stable IDs or explicit selectors/modes.
7. A subtree is not blocked by `data-ignore` or `data-ignore-morph`.
8. Requests are not being auto-cancelled by default element-level cancellation.
9. Console errors include a Datastar runtime error URL with contextual metadata.

Helpful tools:

- browser devtools network panel for response types and SSE frames
- browser console for Datastar runtime error URLs
- `data-json-signals` for inspecting current signal state
- Datastar Inspector if available

## Repo-Aware Notes For `starfederation/datastar`

Repository shape at a high level:

- `bundles/`: built distributable bundles
- `library/src/engine/`: core runtime engine behavior
- `library/src/plugins/`: attribute/action plugin implementations
- `library/src/utils/`: supporting utilities
- `library/src/bundles/`: bundle entrypoints/build-facing source
- `sdk/`: language SDKs for generating Datastar responses and SSE events

When changing Datastar itself:

1. Locate the relevant attribute, action, watcher, or SSE behavior in `library/src/plugins/` or `library/src/engine/`.
2. Preserve the documented contract from `https://data-star.dev/reference` unless the task explicitly includes a docs/API change.
3. Check whether the behavior depends on casing, modifiers, cleanup, morphing, or reapplication after patching.
4. For backend integration changes, verify whether SDK behavior under `sdk/` also needs updates.

Likely responsibility boundaries:

- new or changed `data-*` behavior: plugin layer
- signal lifecycle / DOM traversal / reactivity internals: engine layer
- public browser bundle exposure: bundle layer
- server event emitters/helpers: SDK layer

## Preferred Implementation Style

When asked to build a Datastar feature:

- write the smallest HTML-first solution
- keep expressions readable and local to the markup
- use server-rendered fragments instead of client templates when feasible
- keep request payloads narrow with `filterSignals` when that improves correctness
- prefer HTML or SSE responses over client-executed JavaScript

## Quick Reference

```html
<!-- Local state -->
<div data-signals="{open: false, count: 0}"></div>

<!-- Input binding -->
<input data-bind:title />

<!-- Derived state -->
<div data-computed:title-length="$title.length"></div>

<!-- Side effect -->
<div data-effect="$count > 10 && console.log('high')"></div>

<!-- Event -->
<button data-on:click="$open = !$open">Toggle</button>

<!-- Backend request -->
<button data-on:click="@get('/panel')">Reload</button>

<!-- Loading -->
<button data-on:click="@post('/save')" data-indicator:saving>Save</button>

<!-- Patch target -->
<section id="panel"></section>
```

## References

- Website: `https://data-star.dev/`
- Guide: `https://data-star.dev/guide/getting_started`
- Attributes reference: `https://data-star.dev/reference/attributes`
- Actions reference: `https://data-star.dev/reference/actions`
- SSE events reference: `https://data-star.dev/reference/sse_events`
- Repo: `https://github.com/starfederation/datastar`
