#' @title Mapeia sigla de partido para id
#' @description Recebe um dataframe contendo uma coluna 'partido' com a sigla de um partido e retorna o id correspondente
#' @param df Dataframe com uma coluna 'partido'
#' @param parlamentares_path Caminho para o arquivo de dados dos parlamentares
#' @param partidos_path Caminho para o arquivo dos dados do partidos
#' @return Dataframe com nova coluna id_partido
map_sigla_to_id <- function(df, 
                            parlamentares_path = here::here("crawler/raw_data/parlamentares.csv"),
                            partidos_path = here::here("crawler/raw_data/partidos.csv")) {
  
  deputados <- read_csv(parlamentares_path, col_types = cols(id = "c")) %>% 
    filter(casa == "camara") %>% 
    select(id_partido = num_partido, sg_partido)
  
  partidos <- 
    read_csv(partidos_path, col_types = cols(.default = "c", id = "i")) %>% 
    select(-c(situacao, tipo))
  
  partidos <- partidos %>% 
    rbind(
      anti_join(deputados, 
                partidos, 
                by = c("sg_partido" = "sigla")) %>% 
        unique() %>% 
        rename(id = id_partido, sigla = sg_partido))
  
  df <- df %>% 
    left_join(partidos, by = c("partido" = "sigla")) %>% 
    unique() %>% 
    rename(id_partido = id)
  
  return(df)
  
}
