OAuth     = require 'oauth'
fs        = require 'fs'
nodeConf  = require 'nconf'

# Load configuration
nodeConf.file 'keys', './config/twitter_keys.json'
nodeConf.file 'urls', './config/twitter_urls.json'
nodeConf.env() # if the above files are empty, look in the environment variable

class ItsMidnightIn
  constructor: (start = true) ->
    return unless start
    @checkRequirements()
    @setOauth()
    @checkTime()
    setInterval @checkTime, 100
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
    now = new Date()
    hour = now.getUTCHours()
    minute = now.getUTCMinutes()
    # console.log "#{hour}:#{minute}"
    console.log @getCity Math.floor Math.random() * 24
    # if minute is 0
      # city = @getCity hour
      # status = @buildStatus city
      # @sendTweet status

  buildStatus: (city) -> "It's midnight in #{city}"

  getCity: (hour) ->
    return unless hour? and hour < 24
    utcDist = @getUTCDistance hour
    midnightCities = @cities[utcDist]
    thisOne = Math.floor Math.random() * midnightCities.length
    # console.log utcDist, midnightCities, thisOne, midnightCities[thisOne]
    return midnightCities[thisOne]
  
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

  sendTweet: (status) ->
    return unless status?
    @oauth.post(
      nodeConf.get('tweet_url')
    , nodeConf.get('access_token')
    , nodeConf.get('access_secret')
    ,  status: status
    , (e, data, res) ->
        console.log ''
        console.log ''
        console.log 'Error!', new Date(), e if e?
    )
  
  # [List of tz database time zones](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
  # Reminder: 
  #   +13 == -11
  #   +14 == -10
  cities:
    "0":  [
          "Timbuktu, Mali"
          "Freetown, Sierra Leone"
          "Dakar, Senegal"
          "Bamako, Mali"
          "Accra, Ghana"
          "The Azores Archipelago"
          "Reykjavík, Iceland"
          ]
    "1":  [
          "Casablanca, Morocco"
          "Kinshasa, Congo"
          "Lagos, Nigeria"
          "Tunis, Tunisia"
          "Las Palmas, Canary Islands"
          "Funchal, Madeira"
          "London, England"
          "Dublin, Ireland"
          "Lisbon, Portugal"
          "Algiers, Algeria"
          "Douglas, The Isle of Man"
          "Belfast, Ireland"
          ]
    "2":  [
          "Lilongwe, Malawi"
          "Bujumbura, Burundi"
          "Cairo, Egypt"
          "Harare, Zimbabwe"
          "Johannesburg, South Africa"
          "Kigali, Rwanda"
          "Lusaka, Zambia"
          "Maputo, Mozambique"
          "Tripoli, Libya"
          "Amsterdam, The Netherlands"
          "Andorra la Vella, Andorra"
          "Belgrade, Serbia"
          "Berlin, Germany"
          "Brussels, Belgium"
          "Budapest, Hungary"
          "Copenhagen, Denmark"
          "Gibraltar"
          "Luxembourg"
          "Madrid, Spain"
          "Valletta, Malta"
          "Monaco"
          "Oslo, Norway"
          "Paris, France"
          "Prague, Czech Republic"
          "Rome, Italy"
          "Stockholm, Sweden"
          "Vienna, Austria"
          "Warsaw, Poland"
          "Sarajevo, Bosnia"
          "The Vatican"
          "Zagreb, Croatia"
          ]
    "3":  [
          "Dar es Salaam, Tanzania"
          "Kampala, Uganda"
          "Mogadishu, Somalia"
          "Nairobi, Kenya"
          "Amman, Jordan"
          "Baghdad, Iraq"
          "Manama, Bahrain"
          "Beirut, Lebanon"
          "Damascus, Syria"
          "Gaza"
          "Hebron, West Bank"
          "Istanbul, Turkey"
          "Jerusalem, Israel"
          "Kuwait City, Kuwait"
          "Doha, Qatar"
          "Athens, Greece"
          "Bucharest, Romania"
          "Helsinki, Finland"
          "Kiev, Ukraine"
          "Minsk, Belarus"
          "Sofia, Bulgaria"
          ]
    "4":  [
          "Dubai, United Arab Emirates"
          "Muscat, Oman"
          "Tbilisi, Georgia"
          "Moscow, Russia"
          "Port Louis, Mauritius"
          ]
    "5":  [
          "Mawson Station, Antarctica"
          "Astana, Kazakhstan"
          "Ashgabat, Turkmenistan"
          "Baku, Azerbaijan"
          "Karachi, Pakistan"
          "Dushanbe, Tajikistan"
          "Samarkand, Uzbekistan"
          "Malé, Maldives"
          ]
    "6":  [
          "Thimphu, Bhutan"
          "Qyzylorda, Kazakhstan"
          "Vostok Station, South Magnetic Pole"
          "Bishkek, Kyrgyzstan"
          "Dhaka, Bangladesh"
          ]
    "7":  [
          "Davis Station, Antarctica"
          "Bangkok, Thailand"
          "Saigon, Vietnam"
          "Jakarta, Indonesia"
          "Phnom Penh, Cambodia"
          "Vientiane, Laos"
          "Flying Fish Cove, Christams Island"
          ]
    "8":  [
          "Ulaanbaatar, Mongolia"
          "Casey Station, Antarctica"
          "Bandar Seri Begawan, Brunei"
          "Hong Kong"
          "Lhasa, Tibet"
          "Kuala Lumpur, Malaysia"
          "Macau"
          "Manila, Philippines"
          "Shanghai, China"
          "Singapore"
          "Taipei, Taiwan"
          "Perth, Australia"
          ]
    "9":  [
          "Dili, East Timor"
          "Pyongyang, North Korea"
          "Seoul, South Korea"
          "Tokyo, Japan"
          ]
    "10": [
          "Brisbane, Australia"
          "Chuuk State, Micronesia"
          "Hagåtña, Guam"
          "Port Moresby, Papua New Guinea"
          "Saipan, Northern Mariana Islands"
          ]
    "11": [
          "Sydney, Australia"
          "Nouméa, New Caledonia"
          "Pohnpei, Micronesia"
          "Sakhalin, Russia"
          "Jewish Autonomous Oblast, Russia"
          "Khabarovsk Krai, Russia"
          "Primorsky Krai, Russia"
          "Macquarie Island, Australia"
          ]
    "12": [
          "Anadyr, Russia"
          "Kamchatka Krai, Russia"
          "Magadan, Russia"
          "Kwajalein Island, Marshall Islands"
          "Funafuti, Tuvalu"
          "Majuro, Marshall Islands"
          "Nauru, Micronesia"
          "Tarawa, Republic of Kiribati"
          "Wake Island, United States of America"
          "Mata-Utu, Wallis and Futuna"
          ]
    "-1": [
          "Praia, Cape Verde"
          ]
    "-2": [
          "Nuuk, Greenland"
          "Saint Pierre and Miquelon"
          "Montevideo, Uruguay"
          "São Paulo, Brazil"
          "the South Sandwich Islands"
          ]
    "-3": [
          "Araguaína, Brazil"
          "Buenos Aires, Argentina"
          "San Fernando del Valle de Catamarca, Argentina"
          "Cordoba, Argentina"
          "Jujuy, Argentina"
          "La Rioja, Argentina"
          "Mendoza, Argentina"
          "Río Gallegos, Argentina"
          "Salta, Argentina"
          "San Juan, Argentina"
          "San Luis, Argentina"
          "San Miguel de Tucumán, Argentina"
          "Ushuaia, Argentina"
          "Asunción, Paraguay"
          "Belém, Brazil"
          "Campo Grande, Brazil"
          "Cayenne, French Guiana"
          "Cuiabá, Brazil"
          "Fortaleza, Brazil"
          "Glace Bay, Canada"
          "Happy Valley-Goose Bay, Canada"
          "Halifax, Canada"
          "Maceió, Brazil"
          "Moncton, Canada"
          "Paramaribo, Suriname"
          "Recife, Brazil"
          "Santarém, Brazil"
          "Santiago, Chile"
          "Thule Air Base, Greenland"
          "Palmer Station, Antarctica"
          "Rothera Research Station, Antarctica"
          "Hamilton, Bermuda"
          "Stanley, Falkland Islands"
          ]
    "-4": [
          "The Valley, Anguilla"
          "St. John's, Antigua and Barbuda"
          "Oranjestad, Aruba"
          "Bridgetown, Barbados"
          "Blanc-Sablon, Canada"
          "Willemstad, Curaçao"
          "Detroit, United States of America"
          "Roseau, Dominica"
          "Eirunepé, Brazil"
          "Indianapolis, United State of America"
          "Providenciales, Caicos Islands"
          "Cockburn Town, Grand Turk Island"
          "St. George's, Grenada"
          "Guadeloupe"
          "Georgetown, Guyana"
          "Havana, Cuba"
          "Marengo, United States of America"
          "New York City, United States of America"
          ]
    "-5": [
          "Chicago, United States of America"
          "Mexico City, Mexico"
          "Panama City, Panama"
          "Winnipeg, Canada"
          "Kingston, Jamaica"
          ] 
    "-6": [
          "Devner, United States of America"
          "Edmonton, Canada"
          "Belize City, Belize"
          "San José, Costa Rica"
          ]
    "-7": [
          "Los Angeles, United States of America"
          "Tijuana, Mexico"
          "Vancouver, Canada"
          "San José, Costa Rica"
          "Whitehorse, Canada"
          ] 
    "-8": [
          "Anchorage, United States of America"
          "Juneau, United States of America"
          "Noma, United States of America"
          "Adamstown, Pitcairn Islands"
          ] 
    "-9": [
          "Adak, United States of America"
          "the Mangareva Islands, French Polynesia"
          ] 
    "-10": [
          "Honolulu, United States of America"
          "the Johnston Atoll"
          "Rarotonga, Cook Islands"
          "Papeete, Tahiti"
          ]
    "-11": [
          "the Midway Islands"
          "Alofi, Niue"
          "Papeete, Tahiti"
          "Pago Pago, American Samoa"
          ] 




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

module.exports = ItsMidnightIn