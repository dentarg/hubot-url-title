Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/hubot-url-title.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect
nock = require('nock')

describe 'hubot-url-title', ->

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user posts link to youtube video", ->
    beforeEach ->
      nock('https://www.youtube.com').get('/watch?v=u-mRU44Q5u4').replyWithFile(200, 'src/tests/test_files/youtube.html')
      co =>
        @room.user.say 'john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"
        new Promise.delay(100)

    it 'posts the title of the video', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"]
        ['hubot', "AWS re:Invent 2015 | (SEC316) Harden Your Architecture w/ Security Incident Response Simulations - YouTube"]
      ]


  context "user posts link to GitHub", ->
    beforeEach ->
      nock('https://github.com').get('/').replyWithFile(200, 'src/tests/test_files/github.html')
      co =>
        @room.user.say 'john', "https://github.com"
        new Promise.delay(100)

    it 'posts the title of the video', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', "https://github.com"]
        ['hubot', "How people build software · GitHub"]
      ]


  context "user posts 2 links", ->
    beforeEach ->
      nock('https://www.youtube.com').get('/watch?v=u-mRU44Q5u4').replyWithFile(200, 'src/tests/test_files/youtube.html')
      nock('https://github.com').get('/').replyWithFile(200, 'src/tests/test_files/github.html')
      co =>
        @room.user.say 'john', "https://www.youtube.com/watch?v=u-mRU44Q5u4 https://github.com"
        new Promise.delay(100)

    it 'posts the title of the video', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages[0]).to.eql ['john', "https://www.youtube.com/watch?v=u-mRU44Q5u4 https://github.com"]
      titles = [
        "AWS re:Invent 2015 | (SEC316) Harden Your Architecture w/ Security Incident Response Simulations - YouTube"
        "How people build software · GitHub"
      ]
      expect(@room.messages[1][1]).to.be.oneOf titles
      expect(@room.messages[2][1]).to.be.oneOf titles


  context "user posts link to large ISO file", ->
    beforeEach ->
      long_string = (new Array(10*1024*1024)).join("x")
      nock('http://cdimage.debian.org').get(/.*\.iso$/).reply(200, long_string)
      co =>
        @room.user.say 'john', "http://cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso"
        new Promise.delay(100)

    it 'stops download because it exceeds the maximum size', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', "http://cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso"]
        ['hubot', "Resource at http://cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso exceeds the maximum size."]
      ]


  context "Japanese user posts link to Etsy", ->
    beforeEach ->
      nock('https://etsy.com', reqheaders: {'Accept-Language':'ja'}).get('/').replyWithFile(200, 'src/tests/test_files/etsy.ja.html')
      process.env.HUBOT_URL_TITLE_ACCEPT_LANGUAGE = 'ja'
      co =>
        @room.user.say 'john', "https://etsy.com"
        new Promise.delay(100)

    it 'posts the title of the top page', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', "https://etsy.com"]
        ['hubot', "Etsy :: すべてのハンドメイドのマーケットプレイス"]
      ]
