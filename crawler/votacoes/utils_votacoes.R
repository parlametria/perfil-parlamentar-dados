#' @title Enumera votações
#' @description Recebe um dataframe com coluna orientacao e enumera o valor para um número
#' @param df Dataframe com a coluna orientacao
#' @return Dataframe com coluna orientacao enumerada
#' @examples
#' enumera_votacoes(df)
enumera_voto <- function(df) {
  df %>%
    mutate(
      voto = case_when(
        str_detect(voto, "Não") ~ -1,
        str_detect(voto, "Sim") ~ 1,
        str_detect(voto, "Obstrução") ~ 2,
        str_detect(voto, "Abstenção") ~ 3,
        str_detect(voto, "Art. 17") ~ 4,
        TRUE ~ 0
      )
    )
}

#' @title Padroniza siglas de partidos
#' @description Recebe uma sigla de partido como input e retorna seu valor padronizado
#' @param sigla Sigla do partido
#' @return Dataframe com sigla do partido padronizada
padroniza_sigla <- function(sigla) {
  sigla = toupper(sigla)
  
  sigla_padronizada <- case_when(
    str_detect(tolower(sigla), "ptdob") ~ "AVANTE",
    str_detect(tolower(sigla), "pcdob") ~ "PCdoB",
    str_detect(tolower(sigla), "ptn") ~ "PODEMOS",
    str_detect(tolower(sigla), "pmdb") ~ "MDB",
    str_detect(sigla, "SOLID.*") ~ "SOLIDARIEDADE",
    str_detect(sigla, "PODE.*") ~ "PODEMOS",
    str_detect(sigla, "GOV.") ~ "GOVERNO",
    str_detect(sigla, "PHS.*") ~ "PHS",
    TRUE ~ sigla
  ) %>%
    stringr::str_replace("REPR.", "") %>% 
    trimws(which = c("both"))
  
  return(sigla_padronizada)
}