# Pechkin

[![Gem](https://img.shields.io/gem/v/pechkin.svg)](https://rubygems.org/gems/pechkin)

Pechkin is a small webhook → messenger proxy (currently Slack + Telegram). You define a config directory with bots, channels, message templates, and Pechkin turns incoming JSON POST requests into formatted messages.

## Quickstart (use the bundled `examples/`)

### 1) Install

```bash
gem install pechkin
```

### 2) Configure a bot token (Slack example)

The bundled config uses `examples/bots/marvin.yml`:

```yaml
token_env: MARVIN_BOT_TOKEN
connector: slack
```

Set the env var before you run Pechkin:

```bash
export MARVIN_BOT_TOKEN=xoxb-your-actual-token-here
```

### 3) Validate configuration

```bash
pechkin -c examples --check --list
```

### 4) Run the server

Default bind is `127.0.0.1:9292`:

```bash
pechkin -c examples
```

### 5) Send a request

```bash
curl -X POST -H 'Content-Type: application/json' \
  --data '{"name":"all"}' \
  http://127.0.0.1:9292/my-org-random/hello
```

### 6) Preview rendering from CLI (no HTTP)

`--send` expects `channel/message` (no leading slash):

```bash
pechkin -c examples --send my-org-random/hello --data '{"name":"all"}' --preview
```

## Concepts

- **Bot**: how Pechkin authenticates to a messenger API (Slack/Telegram).
- **Channel**: where to deliver messages (one channel config can target multiple `chat_ids`).
- **Message**: how to render data into text + connector-specific payloads.
- **View**: ERB templates stored in `views/`.

## Configuration basics

Pechkin expects a directory layout:

```
.
├── bots/
│   └── marvin.yml
├── channels/
│   └── my-org-random/
│       ├── _channel.yml
│       └── hello.yml
└── views/
    └── hello.erb
```

### Bots (`bots/*.yml`)

Each bot file defines:

- `token_env`: env var name that contains the bot token
- `connector`: `slack` or `telegram` (also accepts `tg`)

Example:

```yaml
# bots/marvin.yml
token_env: MARVIN_BOT_TOKEN
connector: slack
```

### Views (`views/**/*.erb`)

Views are ERB templates rendered with `trim_mode: '-'`.

Example:

```erb
Hello, <%= name %>!
```

### Channels (`channels/<channel_name>/_channel.yml`)

Channel config defines:

- `bot`: which bot to use
- `chat_ids`: a string or list of destination chat IDs / channel IDs

Example:

```yaml
# channels/my-org-random/_channel.yml
chat_ids: '#random'
bot: marvin
```

### Messages (`channels/<channel_name>/*.yml`)

Message config defines:

- `template`: view path relative to `views/` (e.g. `hello.erb`)
- `variables`: static variables merged into request data (request keys override)
- optional connector-specific fields like `slack_attachments`, `telegram_parse_mode`

Example:

```yaml
# channels/my-org-random/hello.yml
template: hello.erb
```

#### Template expansion inside message config

For nested fields you can use `{ template: "..." }` to render a template and replace that value. The object must contain **only** the `template` key.

Example:

```yaml
template: gitlab-commit.erb
slack_attachments:
  - text:
      template: gitlab-commit-attachment.erb
```

#### Message values substitution (`${...}`)

Any string value in message config can substitute `${var}` from the request JSON / `variables`.

Example:

```yaml
slack_attachments:
  - title: Author
    value: "${author}"
```

## Filters (Allow / Forbid)

You can control whether a message is sent using either `allow` or `forbid` rules (but not both).

- `allow`: message is sent if **any** rule matches (OR)
- `forbid`: message is sent if **no** rule matches

Example allow:

```yml
allow:
  - branch: 'master'
```

Example forbid:

```yml
forbid:
  - branch: 'testing'
```

## Connector-specific parameters

### Telegram

- `telegram_parse_mode`: passed to Telegram `parse_mode` (default: `HTML`)

### Slack

- `slack_attachments`: passed as Slack `attachments` to `chat.postMessage`. See [Slack message attachments docs](https://api.slack.com/docs/message-attachments).

#### Slack: email-based user resolution (v2.0.2+)

To send a direct message to a user by email:

1. Put `'email'` in the channel’s `chat_ids`
2. Include an `email` field in the POST request JSON

Example channel config:

```yaml
bot: marvin
chat_ids:
  - 'email'
```

Example request:

```json
{
  "email": "user@example.com",
  "name": "all"
}
```

## HTTP API

- **Endpoint**: `POST /:channel/:message`
- **Body**: JSON object
- **Content-Type**: `application/json`

Example:

```bash
curl -X POST -H 'Content-Type: application/json' \
  --data '{"name":"all"}' \
  http://127.0.0.1:9292/my-org-random/hello
```

## Authorization (Basic Auth via `.htpasswd`)

If `<config-dir>/pechkin.htpasswd` exists (or you pass `--auth-file`), Pechkin will enforce HTTP Basic auth.

Create/update credentials:

```bash
# create/update examples/pechkin.htpasswd
pechkin -c examples --add-auth root:root123
```

Use a custom htpasswd file:

```bash
pechkin -c examples --add-auth root:root123 --auth-file /etc/config/pechkin.htpasswd
pechkin -c examples --auth-file /etc/config/pechkin.htpasswd
```

## Docker quickstart

The repo ships `docker/docker-compose.yml` that mounts `../examples` into the container.

```bash
cd docker
MARVIN_BOT_TOKEN=xoxb-your-actual-token-here docker compose up --build
```

## CLI

Run:

```bash
pechkin --help
```

Common flows:

```bash
pechkin -c examples --check --list
pechkin -c examples --send my-org-random/hello --data '{"name":"all"}' --preview
pechkin -c examples --port 9292 --address 127.0.0.1
```

## Metrics

Pechkin exposes Prometheus metrics at:

```bash
curl http://127.0.0.1:9292/metrics
```

Includes:

- `pechkin_start_time_seconds`
- `pechkin_version{version="..."}`

## Troubleshooting

- **Bot token missing**: ensure the env var named in `token_env` is exported before running Pechkin.\n+  Example: `export MARVIN_BOT_TOKEN=...`\n+- **CLI preview/send endpoint format**: `--send` uses `channel/message` (no leading `/`).\n+- **Template prints nothing**: use `<%= ... %>` (output) not `<% ... %>` (no output).

## Who the heck is Pechkin?

Pechkin is a postman from a Soviet animated film series.
