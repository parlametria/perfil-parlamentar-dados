#' @title Recupera dados sobre suplentes doadores e sócios de empresas
#' @description Retorna um dataframe contendo informações dos suplentes que doaram na campanha de 2018 e que são
#' sócios de empresas.
#' @return Dataframe contendo dados sobre doadores suplentes que são sócios de empresas.
process_suplentes_doadores_e_socios_senado <- function() {
  library(tidyverse)
  library(here)
  
  source(here("reports/atividades-economicas-doacoes/utils.R"))
  source(
    here(
      "parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_parlamentares.R"
    )
  )
  
  parlamentares <-
    read_csv(here("crawler/raw_data/parlamentares.csv"),
             col_types = cols(id = "c"))
  
  suplentes_senado <- parlamentares %>%
    filter(ultima_legislatura == 56,
           casa == 'senado',
           str_detect(tolower(condicao_eleitoral), 'suplente')) %>%
    process_cpf_parlamentares_senado() %>%
    mutate(nome_civil = padroniza_nome(nome_civil)) %>%
    rename(nome_doador = nome_civil)
  
  parlamentares_doadores <-
    read_csv(
      here(
        "parlametria/raw_data/receitas/parlamentares_doadores.csv"
      ),
      col_types = cols(id = "c")
    ) %>%
    filter(casa == 'senado') %>%
    rename(id_parlamentar = id)
  
  doadores_socios_empresas <-
    read_csv(
      here(
        "parlametria/raw_data/empresas/doadores_socios_empresas.csv"
      ),
      col_types = cols(id_parlamentar = "c")
    )
  
  doadores_suplentes_senado <- parlamentares_doadores %>%
    inner_join(suplentes_senado,
               by = c("cpf_cnpj_doador" = "cpf", "nome_doador")) %>%
    filter(casa == 'senado', em_exercicio == 1) %>%
    rename(id_senador_suplente_doador = id) %>%
    select(cpf_cnpj_doador,
           nome_doador,
           id_parlamentar,
           casa,
           valor_receita)
  
  
  suplentes_socios_senado <- doadores_suplentes_senado %>%
    inner_join(
      doadores_socios_empresas,
      by = c("cpf_cnpj_doador", "nome_doador", "id_parlamentar", "casa")
    ) %>%
    select(
      id_parlamentar,
      casa,
      nome_eleitoral,
      sg_partido,
      uf,
      cpf_cnpj_doador,
      nome_doador,
      cnpj,
      razao_social,
      grupo_atividade_economica,
      total_doado = valor_receita
    )
  
  return(suplentes_socios_senado)
}
