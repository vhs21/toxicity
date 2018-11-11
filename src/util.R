library(text2vec)


create_itrtr <- function(data, ids) {
  itoken(
    data,
    ids = ids,
    preprocessor = tolower,
    tokenizer = word_tokenizer,
    progressbar = FALSE
  )
}

create_fit_dtm <- function(itrtr, vectorizer) {
  tfIdf = TfIdf$new()
  tfIdf$fit_transform(create_dtm(itrtr, vectorizer))
}
