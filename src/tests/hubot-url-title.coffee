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


  context "user posts link with redirects", ->
    beforeEach ->
      nock('http://www.nytimes.com')
        .get('/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html')
        .reply(303, 'See Other', {
          'Location': 'http://www.nytimes.com/glogin?URI=http://www.nytimes.com/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html?_r=0'
        })
      nock('http://www.nytimes.com', {
          reqheaders: {
            'Cookie': 'NYT-S=123456'
          }
        }).get('/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html?_r=0')
        .replyWithFile(200, 'src/tests/test_files/nytimes.html')
      nock('http://www.nytimes.com')
        .get('/glogin?URI=http://www.nytimes.com/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html?_r=0')
        .reply(302, 'Found', {
          'Set-Cookie': 'NYT-S=123456'
          'Location': 'http://www.nytimes.com/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html?_r=0'
        })
      co =>
        @room.user.say 'john', "http://www.nytimes.com/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html"
        new Promise.delay(100)

    it 'follows redirects and posts the page title', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', "http://www.nytimes.com/2016/07/31/us/politics/us-wrestles-with-how-to-fight-back-against-cyberattacks.html"]
        ['hubot', "U.S. Wrestles With How to Fight Back Against Cyberattacks - The New York Times"]
      ]

  context "page has very long title, but response is not limited by default", ->
    beforeEach ->
      nock('http://www.vishay.com/company/press/releases/2016/160721VLMU1610/').get('/').replyWithFile(200, 'src/tests/test_files/vishay.html')
      co =>
        @room.user.say 'amanda', "http://www.vishay.com/company/press/releases/2016/160721VLMU1610/"
        new Promise.delay(100)

    it 'responds with the complete long title', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['amanda', "http://www.vishay.com/company/press/releases/2016/160721VLMU1610/"]
        ['hubot', "Vishay - New Vishay Intertechnology Mid-Power UV LED in 365 nm Wavelength Range Delivers Exceptionally Long Lifetime in Compact Package Redpines Vishay Systems Vishay Systems Sr. Manager, Global Communications MarCom Manager, Asia Director of Business Development, USI Electronics Vishay Intertechnology Asia Pte Ltd Vishay Semiconductor GmbH Vice President, Integrated Products Division Vishay Measurements Group Vishay Nobel Wall Street Communications Lorenzoni GmbH, Public Relations Manager, Marketing Communications Vishay Measurements Group Nobel Ltd. Vishay Nobel E.V.P., Yosun Industrial Corp. Vishay Nobel Wall Street Communications Vishay Intertechnology, Inc. Vice President of Marketing, Digi-Key Corporation Manager, MarCom Asia"]
      ]
