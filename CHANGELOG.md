# 2.0.2

## Breaking Changes

* **Bot configuration now requires `token_env` instead of `token`**: Bot tokens must be loaded from environment variables for security. Update your `bots/*.yml` files to use `token_env: ENV_VAR_NAME` instead of `token: actual_token`.

## New Features

* Add email-based user resolution for Slack connector
  * Slack connector can now resolve user IDs from email addresses
  * Use `channel: 'email'` in requests with `email` field to send direct messages
* Add logger parameter to handler and connector chain for better debugging
* Add `--list` option to `check` command to display configuration

## Improvements

* Rename `check_field` to `fetch_field` in configuration loader for clarity
* Add `fetch_value_from_env` helper method for environment variable loading
* Increase channel name column width from 40 to 60 characters in list output
* Add null safety check for `req.body` to prevent errors
* Fix typo: rename `proces_app_error` to `process_app_error`

## Ruby 3.x Compatibility

* Add `base64` and `bigdecimal` gems for Ruby 3.x compatibility

## Test Improvements

* Refactor test files to use top-level `describe` blocks for better organization
* Update test expectations to handle new method signatures

# 1.6.0

* Add `pechkin_version` metric

# 1.5.1

* Add template expansion for any variable

# 1.4.0

* Ruby 3.0 support
* Updated dependencies

# 1.3.2

* Force charset=UTF-8 in http requests
* Print request body when unhandled error occurs
* Internal cleanup
* Log expected and actual data when MessageMatcher fails to match rule.

# 1.3.1

* Fix pechkin initialization (missing logger parameter)

# 1.3.0

* Add basic logging layer
* Internal cleanup
* Drop grape from gemspec
* Add allow / forbid rules for messages

# 1.2.2

* Bind address was not actualy bound

# 1.2.1

* Fix pechkin error when auth header contains invalid content.
* Add auth error messages
* Remove debug oputput from Auth Middleware

# 1.2.0

* Add bind address support

# 1.1.0

* Metrics: Add metric `pechkin_start_time_seconds` with startup timestamp
* UX: Add missing space to CLI option description
* Implement `.htpasswd` based authorization

# Version 1.0.0

* Changed configuration layout. See Readme.md for that
* Added prometheus client to expose basic http metrics
* Drop Grape dependency. Use barebones Rack app
* Add propper logging support

Quality of life features:

* Added `--check` flag - read configuration and exit. With error reporting
* Added `--list` flag. To print current configuration
* Added `--send` flag. To test messages.
* Added `trim_mode: '-'` support for  ERB templates


# Version 0.2.0

* Misc fixes
* Can send slack attachments via `slack_attachments`
* Can substitute request parameters direct into message description values

# Version 0.1.3

* Do not send empty messages with Slack connector

# Version 0.1.2

* Slack connector: do not escape special characters after message formatting

# Version 0.1.1

* Slack connector should decode html entities

# Version 0.1.0

* Grape version pinned to 1.1.0
* Now we support multiple connectors
* Added Slack connector

* Rack version updated to 2.0.6

# Version 0.0.4

* Rack version updated to 2.0.4
* Support `--log-dir` option and add some logging
* Added filters support
