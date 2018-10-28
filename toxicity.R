library(readr)
library(tidyverse)
library(xgboost)
library(text2vec)
library(stopwords)
library(parallel)


train <- read_csv('data/train.csv')

create_itrtr <- function(data) {
  itoken(
    data$comment_text,
    ids = data$id,
    preprocessor = tolower,
    tokenizer = word_tokenizer,
    progressbar = FALSE
  )
}

itrtr_train <- create_itrtr(train)

vocabulary <- create_vocabulary(itrtr_train,
                                ngram = c(1L, 3L),
                                stopwords = stopwords('en')) %>%
  prune_vocabulary(term_count_min = 10)

vectorizer <- vocab_vectorizer(vocabulary)

tfidf <- TfIdf$new()

dtm_train <- create_dtm(itrtr_train, vectorizer) %>%
  fit_transform(tfidf)

labels <-
  c('toxic',
    'severe_toxic',
    'obscene',
    'threat',
    'insult',
    'identity_hate')


models <- mclapply(labels, function(label) {
  model <- xgboost(
    data = dtm_train,
    label = unname(unlist(train[label])),
    objective = 'binary:logistic',
    nrounds = 500,
    early_stopping_rounds = 5
  )
  xgb.save(model, paste('models', label, sep = .Platform$file.sep))
  model
}, mc.silent = TRUE, mc.cores = 6)


test <- read_csv('data/test.csv')

dtm_test <- create_dtm(create_itrtr(test), vectorizer) %>%
  fit_transform(tfidf)

preds <- sapply(models, function(model)
  predict(model, dtm_test))
