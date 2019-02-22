library(tidyverse)

votacoes_diap <- read_csv("votacoes_diap.csv")
pdf <- pdftools::pdf_text("~/Desktop/mapa_votacoes_2015_2019.pdf")
pages <- pdf[50:88]


install.packages("rJava")
devtools::install_github("ropensci/tabulizer", args="--no-multiarch")
devtools::install_github("ropensci/tabulizerjars", args="--no-multiarch")
tabulizer::extract_tables("~/Desktop/mapa_votacoes_2015_2019.pdf", encoding = "UTF-8") -> tables

