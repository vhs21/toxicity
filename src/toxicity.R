library(readr)
library(tidyverse)
library(xgboost)
library(text2vec)
library(stopwords)
library(parallel)

source('src/util.R')


train <- read_csv('data/train.csv')

itrtr_train <- create_itrtr(train$comment_text, train$id)

vocabulary <- create_vocabulary(itrtr_train,
                                ngram = c(1L, 3L),
                                stopwords = stopwords('en')) %>%
  prune_vocabulary(term_count_min = 10)
saveRDS(vocabulary, file = 'out/vocabulary.rds')

vectorizer <- vocab_vectorizer(vocabulary)

dtm_train <- create_fit_dtm(itrtr_train, vectorizer)


labels <-
  c('toxic',
    'severe_toxic',
    'obscene',
    'threat',
    'insult',
    'identity_hate')

models_directory <- 'models'
dir.create(models_directory, showWarnings = FALSE)

models <- mclapply(labels, function(label) {
  model <- xgboost(
    data = dtm_train,
    label = unname(unlist(train[label])),
    objective = 'binary:logistic',
    nrounds = 500,
    early_stopping_rounds = 5
  )
  xgb.save(model,
           paste(models_directory, label, sep = .Platform$file.sep))
  model
}, mc.silent = TRUE, mc.cores = 6)
