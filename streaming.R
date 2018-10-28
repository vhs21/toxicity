library(config)
library(streamR)


config <- config::get(file = 'data/config.yml', use_parent = FALSE)

token <-
  createOAuthToken(
    config$consumer_key,
    config$consumer_secret,
    config$access_token,
    config$access_secret
  )

tweets <- filterStream(
  file.name = "",
  locations=c(-74,40,-73,41),
  language = 'en',
  timeout = 10,
  oauth = token
)
