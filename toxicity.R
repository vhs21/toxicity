library(readr)
library(tidyverse)
library(xgboost)
library(text2vec)
library(stopwords)


train <- read_csv('data/train.csv')
test <- read_csv('data/test.csv')

create_it <- function(data) {
	itoken(
		data$comment_text,
		ids = data$id,
		preprocessor = tolower,
		tokenizer = word_tokenizer
	)
}

it_train <- create_it(train)

vocabulary <- create_vocabulary(
	it_train,
	ngram = c(1L, 3L),
	stopwords = stopwords('en')) %>%
	prune_vocabulary(term_count_min = 10)

vectorizer <- vocab_vectorizer(vocabulary)

tfidf <- TfIdf$new()

dtm_train <- create_dtm(it_train, vectorizer) %>%
	fit_transform(tfidf)

dtm_test <- create_dtm(create_it(test), vectorizer) %>%
	fit_transform(tfidf)

model <- xgboost(
	data = dtm_train,
	label = train$toxic,
	objective = 'binary:logistic',
	nrounds = 500,
	early_stopping_rounds = 10)

pred <- predict(model, dtm_test)

sample(test$comment_text[pred > 0.99], 5)
