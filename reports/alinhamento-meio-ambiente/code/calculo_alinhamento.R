#' @title Compara votos para determinar match
#' @description Compara dois votos e verifica qual o match entre eles.
#' @param voto_a Voto a
#' @param voto_b Voto b
#' @return 1 se concordância, -1 se discordância real, -2 se discordância por falta de posição, 0 em qualquer outro caso
#' @examples
#' compara_votos(-1, 1)
compara_votos <- function(voto_a, voto_b) {
  resp_valida = c(-1, 1)
  
  if (!is.na(voto_a) && !is.na(voto_b)) {
    if (voto_a %in% resp_valida && voto_b %in% resp_valida) {
      res = dplyr::if_else(voto_a == voto_b, 1, -1)
      return(res)
    } else {
      if (voto_b == 2) {
        res = dplyr::if_else(voto_a == -1, 1, -1)
        return(res)
      }
      if(voto_b == 0) { ## b não se posicionou o que indica discordância
        return(-2)
      }
      return(0)
    }
  } else {
    return(0)
  }
  
}

#' @title Calcula alinhamento considerando conjunto de votações
#' @description Compara um conjunto de votaçẽos de duas posições e retorna informações sobre o alinhamento entre elas
#' @param posicao_a Dataframe com as votações da posição a
#' @param posicao_b Dataframe com as votações da posição b
#' @return id da posição a, id da posição b, número de pergunta que foram respondidas por ambos, número de respostas iguais
#' alinhamento
#' @examples
#' posicao_a <- tibble(id_votacao = c(16208), id_parlamentar_voz = c("0"), voto = c(-1))
#' posicao_b <- tibble(id_votacao = c(16208), id_parlamentar_voz = c("12345"), voto = c(1))
#' calcula_alinhamento(posicao_a, posicao_b)
calcula_alinhamento <- function(posicao_a, posicao_b) {
  posicao_merge <- posicao_a %>% 
    dplyr::full_join(posicao_b, by = c("id_votacao")) %>%
    dplyr::rowwise() %>% 
    dplyr::mutate(match = compara_votos(voto.x, voto.y))
  
  perguntas_iguais <- length(which(posicao_merge %>% dplyr::pull(match) %in% c(-1, 1)))
  respostas_iguais <- length(which(posicao_merge %>% dplyr::pull(match) == 1))
  perguntas_sem_posicao_b <- length(which(posicao_merge %>% dplyr::pull(match) == -2))
  
  alinhamento <- dplyr::if_else(perguntas_iguais <= 2, 0, respostas_iguais / (perguntas_iguais + perguntas_sem_posicao_b) )
  
  
  id_parlamentar_a <- posicao_a %>% dplyr::pull(id_parlamentar_voz) %>% dplyr::first()
  id_parlamentar_b <- posicao_b %>% dplyr::pull(id_parlamentar_voz) %>% dplyr::first()
  
  return(tibble::tibble(id_parlamentar_a, id_parlamentar_b, perguntas_iguais, respostas_iguais, 
                        perguntas_sem_posicao_b, alinhamento))
}

#' @title Compara votações entre um parlamentar específico e uma posição ideal
#' @description Compara votações entre um parlamentar específico e uma posição ideal
#' @param posicao_parlamentar_id Id do parlamentar de interesse
#' @param dados_votacoes Dataframe com os dados das votações
#' @param posicao_ideal Dataframe com votações da posição ideal
#' @return Dataframe com informações sobre o alinhamento entre o parlamentar e a posição ideal
#' @examples
#' dados_votacoes <- tibble(id_votacao = c(16208), id_parlamentar_voz = c("123"), voto = c(-1))
#' posicao_ideal <- tibble(id_votacao = c(16208), id_parlamentar_voz = c("0"), voto = c(-1))
#' calcular_alinhamento_parlamentar("123", posicoes, posicao_ideal)
calcular_alinhamento_parlamentar <- function(posicao_parlamentar_id, dados_votacoes, posicao_ideal) {
  posicao_parlamentar <- dados_votacoes %>% 
    filter(id_parlamentar_voz == posicao_parlamentar_id)
  
  return(calcula_alinhamento(posicao_ideal, posicao_parlamentar)) 
}
