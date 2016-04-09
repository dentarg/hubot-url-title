# hubot-url-title

[![Build Status](https://travis-ci.org/dentarg/hubot-url-title.svg?branch=master)](https://travis-ci.org/dentarg/hubot-url-title) [![npm version](https://badge.fury.io/js/hubot-url-title.svg)](https://www.npmjs.com/package/hubot-url-title) [![npm downloads](https://img.shields.io/npm/dm/hubot-url-title.svg)](https://www.npmjs.com/package/hubot-url-title) [![Dependency Status](https://david-dm.org/dentarg/hubot-url-title.svg)](https://david-dm.org/dentarg/hubot-url-title) [![devDependency Status](https://david-dm.org/dentarg/hubot-url-title/dev-status.svg)](https://david-dm.org/dentarg/hubot-url-title#info=devDependencies)

Returns the title when a link is posted.

## Installation

Install the module:

    npm install --save hubot-url-title

(this will update your `package.json`).

Then add hubot-url-title to `external-scripts.json`:

```coffee
["hubot-url-title"]
```

## Configuration

#### Regular expression used to exclude URLs

    HUBOT_URL_TITLE_IGNORE_URLS

If you use HipChat, it's useful to ignore sites already supported by HipChat:

    HUBOT_URL_TITLE_IGNORE_URLS="github.com|twitter.com|imgur.com|youtube.com|spotify.com|instagram.com"

#### Comma-separated list of users to ignore

    HUBOT_URL_TITLE_IGNORE_USERS

## Development

Install dependencies

    npm install

Run tests

    npm test

### Release workflow

    git ci -m 'new cool feature'
    git ci -m 'new nice feature'

    npm version [<newversion> | major | minor | patch]

    git push
    git push --tags

    npm publish .

Update the changelog:

    github_changelog_generator
