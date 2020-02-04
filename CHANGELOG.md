# New

* Add basic logging layer
* Internal cleanup

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
