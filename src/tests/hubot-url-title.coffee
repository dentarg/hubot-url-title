Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/hubot-url-title.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect

describe 'hubot-url-title', ->
  this.timeout(5000)

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user posts link to youtube video", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"
        yield new Promise.delay(1000)

    it 'posts the title of the video', ->
      expect(@room.messages).to.eql [
        ['john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"]
        ['hubot', "AWS re:Invent 2015 | (SEC316) Harden Your Architecture w/ Security Incident Response Simulations - YouTube"]
      ]

  context "user posts link to GitHub", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "https://github.com"
        yield new Promise.delay(1000)

    it 'posts the title of the video', ->
      expect(@room.messages).to.eql [
        ['john', "https://github.com"]
        ['hubot', "GitHub · Where software is built"]
      ]

  context "user posts 2 links", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "https://www.youtube.com/watch?v=u-mRU44Q5u4 https://github.com"
        yield new Promise.delay(2000)

    it 'posts the title of the video', ->
      expect(@room.messages).to.eql [
        ['john', "https://www.youtube.com/watch?v=u-mRU44Q5u4 https://github.com"]
        ['hubot', "AWS re:Invent 2015 | (SEC316) Harden Your Architecture w/ Security Incident Response Simulations - YouTube"]
        ['hubot', "GitHub · Where software is built"]
      ]
