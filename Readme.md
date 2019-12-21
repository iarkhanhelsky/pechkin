# Pechkin

[![Gem](https://img.shields.io/gem/v/pechkin.svg)](https://rubygems.org/gems/pechkin)

# Who the heck is Pechkin?

Pechkin is a postman from soviet animated film series.

# What is pechkin (gem) ?

Pechkin is webhook to IM (currently Telegram, Slack) proxy. It allows you to
transform any request into pretty message in your working channels. Long story
short:

* You describe set of templates and channel configurations to instruct pechkin
  how to render received json data into messages and where to send them
* When pechkin started process any POST request and acts according to your
  instrcutions

# Configuration basics

## Bots

First. You need to create bot to allow pechkin interact with IM APIs. All bots
stored in `bots/` directory, one `yaml` file per bot.

```
bots/marvin.yml
bots/bender.yml
```

Each `bot/*.yml` is bot description. It has following fields:

* `token` - API token to authorize bot requests. See IM documentation for
  details.
* `connector` - connector type. Currenlty: `slack` or `telegram`.

Bot name is taken from `yml` file name. So `bot/bender.yml` is `bender` and
`bot/marvin.yml` is `marvin`

Next. You need to create `views/` directory and create your first template.
Template is `*.erb` file. Each template is rendered with ruby internal ERB class
with `trim_mode: '-'`. Let's create very simple erb template `views/hello.erb`:

```
Hello, <% name %>!
```

## Channels

Now we need destination where to send our message. This destinations are grouped
in `channels` and each `channel` has list of messages it can receive. Channel
descriptions are stored under `channels/` directory. It has following
structure:

```
channels/
  | - %channel-name%
       | - _channel.yml
       | - %message-name%.yml
```

Common channel setting are stored in `_channel.yml` file. You can configure
following parameters:

* `chat_ids` - list of chats or channels to send your message to
* `bot` - name of bot to use for sending messages

## Messages

Then we create `hello.yml` to send hello in channels chats. Messages are
configured with following parameters:

* `template` - template file path relative to `views/` directory
(i.e. 'hello.erb')
* `variables` - is a mapping (key - value) for configurable values in shared
templates. For example one may want to share `commit.erb` among multiple
channels but with sligthly different parameters. It may be `repository_base_url`
wich you want to override for each channel separately. `variables` content will
be merged with received data. So data can override variable parameters too.

### Message values substitutions

As well as you can inject variable parameters into template data through
`variables` field in message configuration you also can substitute some values
in message config. This is honestly very dirty way to set `slack_attachments`
(see below) values, without any external scripting.

Any top-level value can be substitued with `${...}` syntax in any field inside
message description. For example:

```
slack_attachments:
  - title: Author
    value: "${author}"
```

No value processing is supported.

### Connector speceific parameters

*Telegram*:

* `telegram_parse_mode` - `markdown` or `html` mode for Telegram messages

*Slack*:

* `slack_attachments` - description of attachments to use with Slack message.
Slack allows to send messages with empty text and only attachments set. Content
of this field is direct mapping for `attachments` field in Slack API. See
[documentation](https://api.slack.com/docs/message-attachments) for more
details.

## Authorization

Pechkin can make simple request authorization. If configuration directory
contains `pechkin.htpasswd` file or path to `*.htpasswd` file provided via CLI
options pechkin will use it to check Authorization header against it. Pechkin
check Basic-Auth at the moment.

To create `.htpasswd` file one can use `--add-auth` flag to create or update
htpasswd file with provided credentials. For example

```
# Create or update pechkin.htpasswd file in examples/ directory with user
# root and password root123
pechkin -c examples --add-user root:root123

# Create or update pechkin-global.htpasswd file at /etc/config
pechkin --add-user root:root123 --auth-file /etc/config/pechkin-global.htpasswd

# Launch pechkin with explicitly provided htpasswd file
pechkin -c examples --auth-file /etc/config/pechkin-global.htpasswd
```

## Wrapping up

Create bot file `bots/marvin.yml`

```
token: xob-1234567890987654321
connector: slack
```

Create view `views/hello.erb`

```
Hello, <% name %>!
```

Create channel `channels/my-org-random/_channel.yml`

```
chat_ids: '#random'
bot: marvin
```

Create message `channels/my-org-random/hello.yml`

```
template: hello.erb
```

Check configuration

```
pechkin -c . -k -l
```

Preview message

```
pechkin -c -s /my-org-random/hello --data '{"name": "all"}' --preview
```


Try to send message manualy

```
pechkin -c -s /my-org-random/hello --data '{"name": "all"}'
```

Start pechkin:

```
pechkin -c . --port 8080
```

Send message:

```
curl -X POST -H 'Content-Type: application/json' --data '{"name": "all"}' \
     localhost:8080/my-org-random/hello
```

Check metrics:

```
curl localhost:8080/metrics
```

## Startup options

```
Usage: pechkin [options]
Run options
    -c, --config-dir FILE            Path to configuration file
        --port PORT
    -p, --pid-file [FILE]            Path to output PID file
        --log-dir [DIR]              Path to log directory. Output will be
                                     writen topechkin.log file. If not specified
                                     will write to STDOUT
        --auth-file FILE             Path to .htpasswd file. By default
                                    `pechkin.htpasswd` file will be looked up in
                                     configuration directory and if found then
                                     authorization will be enabled implicitly.
                                     Providing this option enables htpasswd
                                     based authorization explicitly. When making
                                     requests use Basic auth to authorize.
Utils for configuration maintenance
    -l, --[no-]list                  List all endpoints
    -k, --[no-]check                 Load configuration and exit
    -s, --send ENDPOINT              Send data to specified ENDPOINT and exit.
                                     Requires --data to be set.
        --preview                    Print rendering result to STDOUT and exit.
                                     Use with --send.
        --data DATA                  Data to send with --send flag. Json string
                                     or @filename.
Auth utils
        --add-auth USER:PASSWORD     Add auth entry to .htpasswd file. By
                                     default pechkin.htpasswd from configuration
                                     directory will be used. Use --auth-file to
                                     specify other file to update. If file does
                                     not exist it will be created.
Debug options
        --[no-]debug                 Print debug information and stack trace on
                                     errors

Common options:
    -h, --help                       Show this message
        --version                    Show version

```

## Other notes

* Pechkin is bundled with prometheus client, all metrics available
  on `/metrics` endpoint.
