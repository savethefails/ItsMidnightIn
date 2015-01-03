# OAuth     = require 'oauth'
Twitter   = require 'node-twitter'
fs        = require 'fs'
nodeConf  = require 'nconf'
_         = require 'underscore'
Cities    = require './cities'

# Load configuration
nodeConf.file 'keys', './config/twitter_keys.json'
nodeConf.file 'urls', './config/twitter_urls.json'
nodeConf.env() # if the above files are empty, look in the environment variable

class ItsMidnightIn
  cities: Cities
  timeType: 'ST'

  constructor: (start = true) ->
    return unless start
    @checkRequirements()
    # @setOauth()
    @setupTwitterClient()
    @checkTime()
    return @

  checkRequirements: ->
    requirements = [
      'consumer_key'
      'consumer_secret'
      'access_token'
      'access_secret'
      'request_token_url'
      'access_token_url'
      'tweet_url'
    ]

    for key in requirements
      throw new Error("'#{key}' is needed") unless nodeConf.get(key)?

  checkTime: =>
    # setTimeout @checkTime, 60000
    now = new Date()
    minute = now.getUTCMinutes()
    console.log now
    if true #minute is 0 and not @tweetInProgress
      @createTweet(now)
      @tweetInProgress = true
    else
      @tweetInProgress = false

  createTweet: (now = new Date(), send = true) ->
    hour = now.getUTCHours()
    utcDist = @getUTCDistance hour
    city = @getCity utcDist
    status = @buildStatus city.name
    console.log status
    if send
      @sendTweet status, city.images
    else
      status

  buildStatus: (city) -> "It's midnight in #{city}#{@randomHashtag()}"

  randomHashtag: ->
    num = Math.floor(Math.random()*10)
    msg = ""
    msg += "#{if msg isnt "" then " " else ""}#midnight" if num > 4
    msg += "#{if msg isnt "" then " " else ""}#12am" if num > 6
    msg = "\r\n#{msg}" if msg isnt ""
    return msg


  getCity: (utcDist) ->
    timeType = @timeType

    _.chain(@cities)
    .filter (city) -> city.offset[timeType] is utcDist
    .sample()
    .value()


  # 0
  # => 0
  # 1
  # => -1
  # 2
  # => -2
  # 3
  # => -3
  # 4
  # => -4
  # 5
  # => -5
  # 6
  # => -6
  # 7
  # => -7
  # 8
  # => -8
  # 9
  # => -9
  # 10
  # => -10
  # 11
  # => -11
  # 12
  # => 12
  # 13
  # => 11
  # 14
  # => 10
  # 15
  # => 9
  # 16
  # => 8
  # 17
  # => 7
  # 18
  # => 6
  # 19
  # => 5
  # 20
  # => 4
  # 21
  # => 3
  # 22
  # => 2
  # 23
  # => 1
  getUTCDistance: (hour) -> if hour < 12 then 0 - hour else 24 - hour

  sendTweet: (status, images = []) ->
    if images.length > 0
    else
      @twitterClient.statusesUpdate {status: status}, (err, data) -> console.log "Error sendTweet", err, data

  sendOauthTweet: (status) ->
    unless status?
      console.log "Warning: No status"
      return
    @oauth.post(
      nodeConf.get('tweet_url')
    , nodeConf.get('access_token')
    , nodeConf.get('access_secret')
    , status: status
    , (e, data, res) ->
        console.log ''
        console.log ''
        console.log "Error!", new Date(), e if e?
    )

  setOauth: ->
    @oauth = new OAuth.OAuth(
      nodeConf.get('request_token_url')
    , nodeConf.get('access_token_url')
    , nodeConf.get('consumer_key')
    , nodeConf.get('consumer_secret')
    , '1.0'
    , null
    , 'HMAC-SHA1'
    )

  setupTwitterClient: ->
    @twitterClient = new Twitter.RestClient(
        nodeConf.get('consumer_key'),
        nodeConf.get('consumer_secret'),
        nodeConf.get('access_token'),
        nodeConf.get('access_secret')
    )

module.exports = ItsMidnightIn