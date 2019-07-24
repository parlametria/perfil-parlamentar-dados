#' @title Extrai o texto de um nó a partir do xpath
#' @description Recebe um nó XML e um xpath e retorna o texto do conteúdo
#' @param node Nó do XML
#' @param xpath Xpath onde o texto está
#' @return Texto extraído
extract_text_from_node <- function(node, xpath) {
  library(tidyverse)
  return(
    xml2::xml_find_first(node, xpath) %>%
      xml2::xml_text()
    )
}