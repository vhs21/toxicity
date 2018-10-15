library(readr)
library(tidyverse)
library(tidytext)
library(ggplot2)


train_data <- read_csv('data/train.csv')

train_words <- train_data %>%
	unnest_tokens(word, comment_text) %>%
	count(id, word, sort = TRUE) %>%
	bind_tf_idf(word, id, n)

ggplot(data = train_words) +
	geom_point(mapping = aes(x = n, y = tf_idf))
