# Pechkin PR #22: Implementation Plan

**Date:** December 17, 2025  
**Goal:** Port changes from `pr/22` to `master` as independent, incremental commits  
**Original Changes:** 20 files changed with 363 insertions and 275 deletions

---

## Implementation Strategy

This plan breaks down PR #22 into **independent, atomic changes** that can be implemented and tested one at a time. Each task is designed to be self-contained where possible, with clear dependencies noted.

---

## Workflow Instructions

For **EVERY** feature/change in this plan, follow this process:

### 1. 📦 Use Code from `pr/22` Branch

- **DO NOT rewrite code from scratch**
- All code is already implemented in the `pr/22` branch
- Your job is to extract and port specific changes

### 2. 🌿 Create a Feature Branch

- Branch from `master` (or current target branch)
- Use a **meaningful, descriptive name** that reflects the specific change
- Naming convention: `feature/description` or `fix/description`

**Examples:**

```bash
# For Task 1.1 (typo fix)
git checkout master
git checkout -b fix/typo-proces-app-error

# For Task 2.2 (Ruby compatibility)
git checkout master
git checkout -b feature/ruby-3x-compatibility-gems

# For Task 8.2 (email resolution)
git checkout master
git checkout -b feature/slack-email-user-lookup
```

### 3. 🍒 Cherry-Pick Related Changes Only

- Identify commits in `pr/22` that contain your specific feature
- Cherry-pick **ONLY** the changes related to that task
- May need to manually extract parts of commits if they're mixed

**Commands:**

```bash
# View all commits in pr/22
git log master..pr/22 --oneline

# View commits that touched specific files
git log master..pr/22 --oneline -- path/to/file.rb

# View detailed diff for a specific file
git diff master..pr/22 -- path/to/file.rb

# Show a specific commit
git show <commit-hash>

# Cherry-pick specific commit(s)
git cherry-pick <commit-hash>

# If commit contains mixed changes, use interactive mode
git cherry-pick -n <commit-hash>  # Stage without committing
git reset HEAD                     # Unstage all
git add -p                         # Selectively stage only relevant changes
git commit -m "feat: descriptive message"

# Alternative: manually apply specific file changes
git show pr/22:path/to/file.rb > temp.rb
# Compare and manually integrate changes
# Then:
git add path/to/file.rb
git commit -m "feat: descriptive message"
```

### 4. ✅ Test & Verify

- Run tests specific to your changes
- Run full test suite
- Ensure rubocop passes
- Manual smoke test if needed

### 5. 🔄 Create Pull Request

- Create PR from your feature branch to `master`
- Reference this implementation plan
- Link to original PR #22
- Note any dependencies on other tasks

### 6. ✨ Merge & Continue

- After PR is approved and merged
- Move to next task in the plan
- Repeat process

---

## Example Workflow

```bash
# Task 1.1: Fix typo in app.rb
git checkout master
git pull origin master
git checkout -b fix/typo-proces-app-error

# Find the relevant change in pr/22
git log master..pr/22 --oneline --all -- lib/pechkin/app/app.rb
git show <commit-hash>

# Cherry-pick or manually apply the change
git cherry-pick <commit-hash>
# OR manually edit the file with only that specific change

# Test
bundle exec rspec spec/pechkin/app_spec.rb
bundle exec rspec

# Commit if manual
git add lib/pechkin/app/app.rb
git commit -m "fix: rename proces_app_error to process_app_error

Fixes typo in method name for better code clarity.

Part of PR #22 implementation plan (Task 1.1)"

# Push and create PR
git push origin fix/typo-proces-app-error
```

---

## Phase 1: Simple Bug Fixes & Code Quality (No Dependencies)

### ✅ Task 1.1: Fix Typo in app.rb

**Branch Name:** `fix/typo-proces-app-error`  
**Files:** `lib/pechkin/app/app.rb`  
**Change:** Rename `proces_app_error` → `process_app_error`  
**Dependencies:** None  
**Test Impact:** None (internal method name only)  
**Estimated Effort:** 2 minutes

### ✅ Task 1.2: Add Null Safety for req.body

**Branch Name:** `fix/req-body-null-safety`  
**Files:** `lib/pechkin/app/app.rb`  
**Change:** Add null check before `req.body.rewind`

```ruby
if req.body
  req.body.rewind
  body = req.body.read
else
  body = ''
end
```

**Dependencies:** None  
**Test Impact:** Should add test for bodyless requests  
**Estimated Effort:** 5 minutes

### ✅ Task 1.3: Refactor List Command - Use .each_key

**Branch Name:** `refactor/list-command-each-key`  
**Files:** `lib/pechkin/command/list.rb`  
**Change:** Replace `.each do |message_name, _message|` with `.each_key`  
**Dependencies:** None  
**Test Impact:** None (behavior unchanged)  
**Estimated Effort:** 2 minutes

### ✅ Task 1.4: Increase Channel Name Column Width

**Branch Name:** `feature/increase-channel-column-width`  
**Files:** `lib/pechkin/command/list.rb`  
**Change:** Update `CHAT_ENTRY_FORMAT` from 40 → 60 characters  
**Dependencies:** None  
**Test Impact:** None (display only)  
**Estimated Effort:** 2 minutes

---

## Phase 2: RuboCop & Ruby 3.x Compatibility

### ✅ Task 2.1: Disable New RuboCop Cops

**Branch Name:** `chore/disable-rubocop-new-cops`  
**Files:** `.rubocop.yml`  
**Change:** Add `NewCops: disable` under `AllCops`  
**Dependencies:** None  
**Test Impact:** None  
**Estimated Effort:** 1 minute

### ✅ Task 2.2: Add Ruby 3.x Compatibility Gems

**Branch Name:** `feature/ruby-3x-compatibility-gems`  
**Files:** `Gemfile`, `Gemfile.lock`  
**Change:** Add `base64` and `bigdecimal` gems to `:dev` group  
**Dependencies:** None  
**Test Impact:** Run `bundle install` and verify tests pass  
**Estimated Effort:** 5 minutes

---

## Phase 3: Test Refactoring (Independent Changes)

### ✅ Task 3.1: Refactor app_spec.rb

**Branch Name:** `refactor/app-spec-top-level-describe`  
**Files:** `spec/pechkin/app_spec.rb`  
**Change:** Move from module-nested to top-level `describe` blocks  
**Dependencies:** None  
**Test Impact:** Tests should pass without changes  
**Estimated Effort:** 10 minutes

### ✅ Task 3.2: Refactor auth_spec.rb

**Branch Name:** `refactor/auth-spec-top-level-describe`  
**Files:** `spec/pechkin/auth_spec.rb`  
**Change:** Move from module-nested to top-level `describe` blocks  
**Dependencies:** None  
**Test Impact:** Tests should pass without changes  
**Estimated Effort:** 10 minutes

### ✅ Task 3.3: Refactor send_data_spec.rb

**Branch Name:** `refactor/send-data-spec-top-level-describe`  
**Files:** `spec/pechkin/command/send_data_spec.rb`  
**Change:** Move from module-nested to top-level `describe` blocks  
**Dependencies:** None  
**Test Impact:** Tests should pass without changes  
**Estimated Effort:** 10 minutes

---

## Phase 4: Configuration Loader Refactoring (Prerequisite for Token Changes)

### ✅ Task 4.1: Rename check_field to fetch_field

**Branch Name:** `refactor/rename-check-field-to-fetch-field`  
**Files:** `lib/pechkin/configuration/configuration_loader.rb`, `lib/pechkin/configuration/configuration_loader_channels.rb`  
**Change:** Rename method for clarity (no behavior change yet)  
**Dependencies:** None  
**Test Impact:** Tests should pass without changes  
**Estimated Effort:** 5 minutes

### ✅ Task 4.2: Add fetch_value_from_env Helper Method

**Branch Name:** `feature/fetch-value-from-env-helper`  
**Files:** `lib/pechkin/configuration/configuration_loader.rb`  
**Change:** Add new `fetch_value_from_env(object, token_field, file)` method  
**Dependencies:** Task 4.1  
**Test Impact:** Add unit tests for new method  
**Estimated Effort:** 15 minutes

---

## Phase 5: Token Loading from Environment Variables

### ⚠️ Task 5.1: Update Bot Configuration Loader

**Branch Name:** `feature/bot-tokens-from-env-vars`  
**Files:** `lib/pechkin/configuration/configuration_loader_bots.rb`  
**Change:** Use `fetch_value_from_env(bot_configuration, 'token_env', bot_file)` instead of `fetch_field(bot_configuration, 'token', bot_file)`  
**Dependencies:** Task 4.2  
**Test Impact:** Update tests to mock environment variables  
**Breaking Change:** ⚠️ **YES** - Requires configuration file updates  
**Estimated Effort:** 20 minutes

### 📝 Task 5.2: Update Example Bot Configurations

**Branch Name:** `docs/update-example-bot-configs`  
**Files:** `examples/bots/marvin.yml`  
**Change:** Change `token: xoxb-...` to `token_env: MARVIN_BOT_TOKEN`  
**Dependencies:** Task 5.1  
**Test Impact:** Update documentation  
**Estimated Effort:** 10 minutes

---

## Phase 6: Add Logger Parameter to Handler Chain

This phase updates method signatures to pass logger through the stack.

### ✅ Task 6.1: Update Handler#handle Signature

**Branch Name:** `feature/handler-logger-parameter`  
**Files:** `lib/pechkin/handler.rb`  
**Change:** Add `logger` parameter: `def handle(channel_id, msg_id, logger, data)`  
**Dependencies:** None (but breaking change)  
**Test Impact:** Update all handler tests  
**Estimated Effort:** 15 minutes

### ✅ Task 6.2: Update RequestHandler to Pass Logger

**Branch Name:** `feature/request-handler-pass-logger`  
**Files:** `lib/pechkin/app/request_handler.rb`  
**Change:** Update call to `handler.handle(channel_id, message_id, logger, **data)`  
**Dependencies:** Task 6.1  
**Test Impact:** Update request handler tests  
**Estimated Effort:** 5 minutes

### ✅ Task 6.3: Update handler_spec.rb

**Branch Name:** `test/update-handler-spec-for-logger`  
**Files:** `spec/pechkin/handler_spec.rb`  
**Change:**

1. Add logger mock
2. Update all `handler.handle()` calls to include logger
3. Refactor to top-level describe blocks
   **Dependencies:** Task 6.1  
   **Test Impact:** Tests should pass after updates  
   **Estimated Effort:** 20 minutes

---

## Phase 7: Update Connector Interface with Email & Logger

### ✅ Task 7.1: Update Connector::Base Signature

**Branch Name:** `feature/connector-email-logger-signature`  
**Files:** `lib/pechkin/connector/base.rb`  
**Change:** Update method signature: `def send_message(chat, email, message, message_desc, logger)`  
**Dependencies:** None (base class)  
**Test Impact:** None yet (implementations needed)  
**Estimated Effort:** 2 minutes

### ✅ Task 7.2: Update Connector::Telegram

**Branch Name:** `feature/telegram-connector-new-signature`  
**Files:** `lib/pechkin/connector/telegram.rb`, `spec/pechkin/connector/telegram_spec.rb`  
**Change:** Update signature (email unused): `def send_message(chat_id, _email, message, message_desc, _logger)`  
**Dependencies:** Task 7.1  
**Test Impact:** Update telegram tests  
**Estimated Effort:** 10 minutes

### ✅ Task 7.3: Update Handler to Pass Email & Logger

**Branch Name:** `feature/handler-pass-email-and-logger`  
**Files:** `lib/pechkin/handler.rb`  
**Change:**

1. Extract email from data: `email = data['email']`
2. Update connector call: `connector.send_message(chat, email, text, message_config, logger)`
   **Dependencies:** Tasks 7.1, 7.2  
   **Test Impact:** Update handler tests  
   **Estimated Effort:** 10 minutes

### ✅ Task 7.4: Update Slack Connector (Without Email Feature)

**Branch Name:** `feature/slack-connector-new-signature`  
**Files:** `lib/pechkin/connector/slack.rb`, `spec/pechkin/connector/slack_spec.rb`  
**Change:** Update signature and add logging (no email resolution yet)  
**Dependencies:** Task 7.1  
**Test Impact:** Update slack tests with logger mocks  
**Estimated Effort:** 15 minutes

---

## Phase 8: Slack Email Resolution Feature

### ✅ Task 8.1: Add SlackApiRequestError Exception

**Branch Name:** `feature/slack-api-request-error`  
**Files:** `lib/pechkin/connector/slack.rb`  
**Change:** Add `class SlackApiRequestError < StandardError; end`  
**Dependencies:** None  
**Test Impact:** None (exception definition only)  
**Estimated Effort:** 1 minute

### ✅ Task 8.2: Implement resolve_user_id Method

**Branch Name:** `feature/slack-email-user-lookup`  
**Files:** `lib/pechkin/connector/slack.rb`  
**Change:** Add `resolve_user_id(email, logger)` method to lookup user by email  
**Dependencies:** Task 8.1  
**Test Impact:** Add unit tests for email resolution  
**Estimated Effort:** 30 minutes

### ✅ Task 8.3: Integrate Email Resolution in send_message

**Branch Name:** `feature/slack-email-resolution-integration`  
**Files:** `lib/pechkin/connector/slack.rb`  
**Change:** Add `channel = resolve_user_id(email, logger) if channel == 'email'`  
**Dependencies:** Task 8.2  
**Test Impact:** Add integration tests  
**Estimated Effort:** 15 minutes

---

## Phase 9: CLI Enhancements

### ✅ Task 9.1: Extract Formatting Constants to Module

**Branch Name:** N/A (skip - already done in original)  
**Files:** `lib/pechkin/command/list.rb`  
**Change:** Keep constants in List class for now (already shared via require)  
**Dependencies:** None  
**Test Impact:** None  
**Estimated Effort:** N/A (already done in original)

### ✅ Task 9.2: Enhance Check Command with List Option

**Branch Name:** `feature/check-command-list-option`  
**Files:** `lib/pechkin/command/check.rb`  
**Change:**

1. Add `require_relative 'list'`
2. Add list functionality if `options.list?`
3. Copy print methods from List command
   **Dependencies:** None  
   **Test Impact:** Add CLI tests for `--list` flag  
   **Estimated Effort:** 20 minutes

---

## Phase 10: Update Tests for New Signatures

### ✅ Task 10.1: Update app_spec.rb for Handler Changes

**Branch Name:** `test/update-app-spec-for-handler-changes`  
**Files:** `spec/pechkin/app_spec.rb`  
**Change:** Update handler expectations to use `any_args` for new parameters  
**Dependencies:** Phase 6, 7  
**Test Impact:** Tests should pass  
**Estimated Effort:** 10 minutes

---

## Phase 11: Version Bump & Documentation

### ✅ Task 11.1: Update Version Number

**Branch Name:** `chore/bump-version-to-2.0.2`  
**Files:** `lib/pechkin/version.rb` (or wherever version is defined), `Gemfile.lock`  
**Change:** Bump version from 2.0.1 → 2.0.2  
**Dependencies:** All previous tasks  
**Test Impact:** None  
**Estimated Effort:** 5 minutes

### ✅ Task 11.2: Update CHANGELOG

**Branch Name:** `docs/update-changelog-2.0.2`  
**Files:** `CHANGELOG.md`  
**Change:** Add entry for 2.0.2 with all changes  
**Dependencies:** Task 11.1  
**Test Impact:** None  
**Estimated Effort:** 15 minutes

### ✅ Task 11.3: Update README/Documentation

**Branch Name:** `docs/update-readme-for-2.0.2`  
**Files:** `Readme.md`  
**Change:** Document new features (email resolution, environment variables for tokens)  
**Dependencies:** Task 11.1  
**Test Impact:** None  
**Estimated Effort:** 30 minutes

---

## Dependency Graph Summary

```
Phase 1 (Bug Fixes) → [Independent]
Phase 2 (Ruby 3.x)  → [Independent]
Phase 3 (Test Refactor) → [Independent]

Phase 4 (Config Refactor) → Phase 5 (Token Env Vars)

Phase 6 (Handler Logger) → Phase 7 (Connector Interface) → Phase 8 (Slack Email)
                                                          ↘
Phase 9 (CLI) → [Independent]                              Phase 10 (Test Updates)
                                                          ↗
Phase 11 (Version & Docs) → [Depends on all previous]
```

---

## Testing Strategy

After each task:

1. ✅ Run relevant unit tests: `rspec spec/path/to/spec.rb`
2. ✅ Run full test suite: `bundle exec rspec`
3. ✅ Run rubocop: `bundle exec rubocop`
4. ✅ Manual smoke test if affecting runtime behavior

---

## Risk Assessment

| Task                      | Risk                      | Mitigation                           |
| ------------------------- | ------------------------- | ------------------------------------ |
| 5.1 - Token env vars      | 🔴 HIGH - Breaking change | Clear documentation, example configs |
| 6.x - Handler signature   | 🟡 MEDIUM - API change    | Comprehensive tests                  |
| 7.x - Connector interface | 🟡 MEDIUM - API change    | Backward compat check                |
| 8.x - Email resolution    | 🟡 MEDIUM - External API  | Error handling, fallback             |
| All others                | 🟢 LOW                    | Standard testing                     |

---

## Total Estimated Time

- **Minimum (without tests):** ~3-4 hours
- **With comprehensive testing:** ~6-8 hours
- **With documentation:** ~8-10 hours

---

## Rollback Plan

Each phase can be rolled back independently via git revert. Breaking changes (Phase 5) should have a documented rollback procedure in the CHANGELOG.

---

## Quick Reference: Files Changed in PR #22

Use this list to quickly locate changes when implementing tasks:

### Source Files

- `.rubocop.yml` - RuboCop configuration
- `Gemfile`, `Gemfile.lock` - Dependencies
- `lib/pechkin/app/app.rb` - Main app error handling
- `lib/pechkin/app/request_handler.rb` - Request handler logger
- `lib/pechkin/command/check.rb` - Check command enhancements
- `lib/pechkin/command/list.rb` - List command formatting
- `lib/pechkin/configuration/configuration_loader.rb` - Config loader helpers
- `lib/pechkin/configuration/configuration_loader_bots.rb` - Bot token loading
- `lib/pechkin/configuration/configuration_loader_channels.rb` - Channel config
- `lib/pechkin/connector/base.rb` - Base connector interface
- `lib/pechkin/connector/slack.rb` - Slack connector with email resolution
- `lib/pechkin/connector/telegram.rb` - Telegram connector updates
- `lib/pechkin/handler.rb` - Handler logger integration

### Test Files

- `spec/pechkin/app_spec.rb` - App tests refactoring
- `spec/pechkin/auth_spec.rb` - Auth tests refactoring
- `spec/pechkin/command/send_data_spec.rb` - SendData tests refactoring
- `spec/pechkin/connector/slack_spec.rb` - Slack connector tests
- `spec/pechkin/connector/telegram_spec.rb` - Telegram connector tests
- `spec/pechkin/handler_spec.rb` - Handler tests with logger

### Commands to View Changes

```bash
# View diff for a specific file
git diff master..pr/22 -- lib/pechkin/app/app.rb

# View commit history for a file
git log master..pr/22 --oneline -- lib/pechkin/connector/slack.rb

# Show all changed files with statistics
git diff master..pr/22 --stat
```

---

**Status:** Ready to implement  
**Next Step:** Start with Phase 1, Task 1.1

**Remember:** For EVERY task:

1. ✅ Create feature branch from master
2. ✅ Use code from pr/22 branch
3. ✅ Cherry-pick only related changes
4. ✅ Test thoroughly
5. ✅ Create PR with clear description
