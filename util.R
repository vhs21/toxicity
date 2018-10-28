library(text2vec)


create_itrtr <- function(data) {
  itoken(
    data$comment_text,
    ids = data$id,
    preprocessor = tolower,
    tokenizer = word_tokenizer,
    progressbar = FALSE
  )
}

create_fit_dtm <- function(itrtr, vectorizer) {
  create_dtm(itrtr, vectorizer) %>%
    fit_transform(TfIdf$new)
}
