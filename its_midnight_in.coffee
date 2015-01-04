Twitter   = require 'node-twitter'
fs        = require 'fs'
nodeConf  = require 'nconf'
_         = require 'underscore'
Cities    = require './cities'
path      = require 'path'

# Load configuration
nodeConf.file 'keys', './config/twitter_keys.json'
nodeConf.file 'urls', './config/twitter_urls.json'
nodeConf.env() # if the above files are empty, look in the environment variable

class ItsMidnightIn
  cities: Cities
  timeType: 'ST'
  imagePath: './assets/'
  stockImages: ['stock1.jpeg', 'stock2.jpg', 'stock3.jpg', 'stock4.jpg', 'stock5.png']

  defaults:
    autoStart: true
    tweetNow: false
    preventTimer: false
    sendTweet: true
    timeoutTime: 60000
    maxImageLoop: 2

  constructor: (options = {}) ->
    @setupOptions(options)

    return unless @options.autoStart

    @checkRequirements()
    @setupTwitterClient()
    @checkTime()

  setupOptions: (options = {}) ->
    @options = _.chain(@defaults)
                .clone()
                # Generate a new object with the keys of @defaults, and the values from environment
                .reduce (memo, val, key) ->
                    memo[key] = nodeConf.get(key)
                    return memo
                  , {}
                # Any missing values from the environment are filled in by @defaults
                .defaults @defaults
                # Swap out the object we're dealing and fill in missing options
                .tap (defaults) -> defaults = _.defaults(options, defaults)
                # Map strings and integers to true/false
                .each (value, key, options) ->
                  options[key] = true if _.include(['true', 1, '1'], value)
                  options[key] = false if _.include(['false', 0, '0'], value)
                .value()

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
    setTimeout @checkTime, @options.timeoutTime unless @options.preventTimer
    now = new Date()
    minute = now.getUTCMinutes()
    if @options.tweetNow or (minute is 0 and not @tweetInProgress)
      @createTweet(now)
      @tweetInProgress = true
    else
      @tweetInProgress = false

  createTweet: (now = new Date()) ->
    hour = now.getUTCHours()
    utcDist = @getUTCDistance hour
    city = @getCity utcDist
    status = @buildStatus city.name
    imageURL = @generateImageURL city.images
    console.log ''
    console.log now, status, imageURL

    if @options.sendTweet
      @sendTweet status, imageURL
    else
      [status, imageURL]

  generateImageURL: (images = [], timesLooped = 0) ->
    timesLooped += 1

    # If there is no image for this city, only show a stock image 20% of the time
    if (not images? or images.length is 0) and _.random(9) > 7
      images = @stockImages

    image = _.sample(images)

    imageURL = "#{@imagePath}#{String(image).toLowerCase()}"
    imageURL = null unless fs.existsSync path.normalize imageURL

    # If the image being used was recently seen
    if @lastImageURL is imageURL
      # try and generate another one, but only if we haven't looped too many times
      if @options.maxImageLoop < timesLooped
        return @generateImageURL images, timesLooped
      imageURL = null

    @lastImageURL = imageURL if imageURL?

    return imageURL





  buildStatus: (city) -> "Its midnight in #{city}#{@randomHashtag()}"

  randomHashtag: ->
    num =  _.random(10)
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

  sendTweet: (status, imageURL) ->
    tweetParams = status: status

    if imageURL
      tweetParams['media[]'] = imageURL
      method = 'statusesUpdateWithMedia'
    else
      method = 'statusesUpdate'

    @twitterClient[method] tweetParams, (err, data) -> console.log("Error #{method}", err) if err

  setupTwitterClient: ->
    @twitterClient = new Twitter.RestClient(
        nodeConf.get('consumer_key'),
        nodeConf.get('consumer_secret'),
        nodeConf.get('access_token'),
        nodeConf.get('access_secret')
    )

module.exports = ItsMidnightIn