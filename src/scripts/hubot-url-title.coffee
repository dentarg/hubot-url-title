# Description:
#   Returns the title when a link is posted
#
# Dependencies:
#   "cheerio": "^0.19.0",
#   "underscore": "~1.3.3"
#   "request": "~2.30.0"
#   "iconv": "2.1.11"
#   "jschardet": "1.4.1"
#   "charset": "1.0.0"
#
# Configuration:
#   HUBOT_URL_TITLE_IGNORE_URLS - RegEx used to exclude Urls
#   HUBOT_URL_TITLE_IGNORE_USERS - Comma-separated list of users to ignore
#
# Commands:
#   http(s)://<site> - prints the title for site linked
#
# Author:
#   ajacksified, dentarg, impca

cheerio    = require 'cheerio'
_          = require 'underscore'
request    = require 'request'
charset    = require 'charset'
jschardet  = require 'jschardet'
Iconv      = require 'iconv'

module.exports = (robot) ->

  ignoredusers = []
  if process.env.HUBOT_URL_TITLE_IGNORE_USERS?
    ignoredusers = process.env.HUBOT_URL_TITLE_IGNORE_USERS.split(',')

  robot.hear /(http(?:s?):\/\/(\S*))/gi, (msg) ->
    for url in msg.match
      username = msg.message.user.name
      if _.some(ignoredusers, (user) -> user == username)
        console.log 'ignoring user due to blacklist:', username
        return

      # filter out some common files from trying
      ignore = url.match(/\.(png|jpg|jpeg|gif|txt|zip|tar\.bz|js|css|pdf)/)

      ignorePattern = process.env.HUBOT_URL_TITLE_IGNORE_URLS
      if !ignore && ignorePattern
        ignore = url.match(ignorePattern)

      unless ignore
        request(
          url, {encoding:null}
          (error, response, body) ->
            if response.statusCode == 200
              enc = charset(response.headers, body)
              enc = enc || jschardet.detect(body).encoding.toLowerCase()
              robot.logger.debug "webpage encoding is #{enc}"
              if enc != 'utf-8'
                iconv = new Iconv.Iconv(enc, 'UTF-8//TRANSLIT//IGNORE')
                html = iconv.convert(new Buffer(body, 'binary')).toString('utf-8')
                document = cheerio.load(html)
                title = document('head title').first().text().trim().replace(/\s+/g, " ")
                msg.send "#{title}"
              else
                document = cheerio.load(body)
                title = document('head title').first().text().trim().replace(/\s+/g, " ")
                msg.send "#{title}"
        )
