library(readr)
library(tidyverse)
library(xgboost)
library(text2vec)
library(stopwords)


train <- read_csv('data/train.csv')
test <- read_csv('data/test.csv')

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

vocabulary <- create_vocabulary(
	itrtr_train,
	ngram = c(1L, 3L),
	stopwords = stopwords('en')) %>%
	prune_vocabulary(term_count_min = 10)

vectorizer <- vocab_vectorizer(vocabulary)

tfidf <- TfIdf$new()

dtm_train <- create_dtm(itrtr_train, vectorizer) %>%
	fit_transform(tfidf)

dtm_test <- create_dtm(create_itrtr(test), vectorizer) %>%
	fit_transform(tfidf)


labels <- c('toxic', 'severe_toxic', 'obscene', 'threat', 'insult', 'identity_hate')

models <- sapply(labels, function(label) xgboost(
	data = dtm_train,
	label = unname(unlist(train[label])),
	objective = 'binary:logistic',
	nrounds = 10,
	early_stopping_rounds = 10)
)

preds <- sapply(models[1,], function(model) predict(model, dtm_test))

