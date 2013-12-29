# hubot-url-title

Returns the title when a link is posted.

## Installation

* Install the module:

    npm install --save hubot-url-title

(this will update your `package.json`).

* Add hubot-url-title to `external-scripts.json`:

```coffee
["hubot-url-title"]
```

## Configuration

    HUBOT_HTTP_INFO_IGNORE_URLS

Regular expression used to exclude URLs.

If you use HipChat, it's useful to ignore sites already supported by HipChat: `HUBOT_HTTP_INFO_IGNORE_URLS: github.com|twitter.com|imgur.com`.

    HUBOT_HTTP_INFO_IGNORE_USERS

Comma-separated list of users to ignore.
