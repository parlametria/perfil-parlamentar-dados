#' @title Retorna as coautorias dos parlamentares nas proposições
#' @description Retorna as coautorias dos parlamentares nas proposições
#' @param parlamentares Dataframe de parlamentares
#' @param autores Dataframe de autores
#' @return Dataframe com id mapeado
get_coautorias <- function(parlamentares, autores) {
  coautorias <- autores %>%
    distinct() %>% 
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y) %>% 
    distinct()
  
  coautorias <- coautorias %>%
    .remove_duplicated_edges() %>%
    mutate(peso_arestas = sum(peso_arestas),
           num_coautorias = n()) %>%
    ungroup() %>%
    mutate(id.x = as.character(id.x),
           id.y = as.character(id.y))
  
  coautorias <- coautorias %>% 
    inner_join(parlamentares, by = c("id.x" = "id")) %>% 
    inner_join(parlamentares, by = c("id.y" = "id")) %>% 
    select(-c(sg_partido.x, sg_partido.y)) %>% 
    distinct()
  
  return(coautorias)
}

#' @title Ordena dois valores (usada para remover duplicação)
#' @description Ordena e retorna no formato 
#' <valor1><sep><valor2>
#' @param x Valor a ser ordenado
#' @param y Valor a ser ordenado
#' @param sep Caractere usado como separador.
#' @return Retorna valores ordenados e separados por um separador.
.paste_cols <- function(x, y, sep = ":") {
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i) {
    paste0(sort(c(x[i], y[i])), collapse = ":")
  }) %>%
    unlist())
}

#' @title Remove coautorias duplicadas
#' @description Retira duplicação do tipo: 
#' autor x coautorou com autor y na proposição z e
#' autor y coautorou com autor x na proposição z
#' @param df Dataframe de coautorias
#' @return Retorna coautorias únicas entre dois parlamentares 
#' para uma proposição.
.remove_duplicated_edges <- function(df) {
  df %>%
    mutate(col_pairs =
             .paste_cols(id.x,
                        id.y,
                        sep = ":")) %>%
    group_by(col_pairs) %>%
    tidyr::separate(col = col_pairs,
                    c("id.x",
                      "id.y"),
                    sep = ":") %>%
    group_by(id.x, id.y) %>%
    distinct()
}