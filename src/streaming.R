library(config)
library(streamR)
library(tidyverse)
library(text2vec)
library(xgboost)

source('src/util.R')


config <-
  config::get(file = 'data/config.yml', use_parent = FALSE)

token <-
  createOAuthToken(
    config$consumer_key,
    config$consumer_secret,
    config$access_token,
    config$access_secret
  )

vocabulary <- readRDS('out/vocabulary.rds')

tweets <- filterStream(
  file.name = '',
  locations = c(-74, 40, -73, 41),
  language = 'en',
  timeout = 10,
  oauth = token
) %>% parseTweets()


itrtr <- create_itrtr(tweets$text, tweets$id_str)

dtm <- create_fit_dtm(itrtr, vocab_vectorizer(vocabulary))

labels <-
  c('toxic',
    'severe_toxic',
    'obscene',
    'threat',
    'insult',
    'identity_hate')

models <- sapply(labels, function(label) {
  xgb.load(paste('models', label, sep = .Platform$file.sep))
}, simplify = FALSE)

preds <- sapply(models, function(model)
  predict(model, dtm))
