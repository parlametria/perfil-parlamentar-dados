library(tidyverse)
source(here::here("scripts/generate-graph.R"))
source(here::here("scripts/fetcher_autorias.R"))

process_parlamentares <- function(df) {
 df <- df %>%
    mutate(nome_eleitoral = paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido) %>%
    mutate(id = as.character(id))
 
 return(df)
} 

process_autores <- function(df, parlamentares_df, ids_relacionadas_df) {
  df <- df %>%
    mutate(idProposicao = as.character(idProposicao)) %>% 
    processa_autores_proposicoes(ids_relacionadas_df) %>%
    select(id_req = idProposicao, id = idDeputadoAutor, peso_arestas) %>%
    filter(!is.na(id)) %>%
    group_by(id) %>%
    ungroup() %>%
    mutate(id = as.character(id))
  
  df <- inner_join(df, parlamentares_df, by = "id")
  
  return(df)
}

add_url <- function(df) {
  link_para_detalhes_camara <-
    "https://www.camara.leg.br/proposicoesWeb/fichadetramitacao?idProposicao="
  
  df <- df %>%
    ungroup() %>% 
    mutate(
      url = paste0(link_para_detalhes_camara,
                   id_req),
      nome_eleitoral.y =
        if_else(id.x == id.y,
                '-',
                nome_eleitoral.y),
      id.y =
        if_else(id.x == id.y,
                '-',
                id.y)
    )
  
  return(df)
}

generate_autorias_conjuntas <- function(id, min_peso, autores, parlamentares) {
  ids_relacionadas <- fetch_relacionadas(id)
  
  autores <- process_autores(autores, parlamentares, ids_relacionadas)
  
  nodes <- generate_nodes(autores)
  
  autores <- autores %>%
    select(-sg_partido)
  
  autores <- autores %>% 
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter((id.x != id.y &
              peso_arestas != 1) | (peso_arestas == 1))
  
  autores <- autores %>%
    filter(min_peso <= peso_arestas) %>%
    remove_duplicated_edges() %>%
    distinct() %>%
    mutate(id_req = as.character(id_req))

  edges <-
    generate_edges(autores %>% select(id_req, id.x, id.y, peso_arestas), nodes)
  
  autores <- autores %>% 
    add_url()
  
 
  return(list(autores, nodes, edges))
}

paste_cols <- function(x, y, sep = ":") {
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i) {
    paste0(sort(c(x[i], y[i])), collapse = ":")
  }) %>%
    unlist())
}

remove_duplicated_edges <- function(df) {
  df %>%
    mutate(col_pairs =
             paste_cols(id.x,
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

processa_autores_proposicoes <- function(autores, proposicoes) {
  autores <-
    autores %>%
    group_by(idProposicao) %>%
    mutate(num_autores = n(),
           peso_arestas = 1/num_autores)

  return(join_autores_proposicoes(autores, proposicoes))
}

join_autores_proposicoes <- function(autores, proposicoes) {
  df <-
    inner_join(autores, proposicoes,
               by = c("idProposicao" = "id"))
  
  return(df)
}
