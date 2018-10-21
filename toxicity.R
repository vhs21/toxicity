library(readr)
library(tidyverse)
library(xgboost)
library(text2vec)
library(stopwords)


train <- read_csv('data/train.csv')

it_train <- itoken(
	train$comment_text,
	ids = train$id,
	preprocessor = tolower,
	tokenizer = word_tokenizer)

vocabulary <- create_vocabulary(
	it_train,
	ngram = c(1L, 3L),
	stopwords = stopwords('en')) %>%
	prune_vocabulary(term_count_min = 10)

dtm_train <- create_dtm(
	it_train,
	vocab_vectorizer(vocabulary)) %>%
	fit_transform(TfIdf$new())

model <- xgboost(
	data = dtm_train,
	label = train$toxic,
	nrounds = 1000,
	early_stopping_rounds = 10)
