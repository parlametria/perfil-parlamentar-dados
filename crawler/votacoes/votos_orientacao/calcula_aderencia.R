#' @title Compara voto de deputado com orientação do partido
#' @description Verifica a aderência do deputado ao voto do partido
#' @param voto_deputado Voto do deputado
#' @param voto_partido Orientação do partido
#' @return Valor de match calculado (detalhes abaixo)
#' @examples
#' orientacao <- compara_voto_com_orientacao(1, -1)
#' Voto deputado e voto partido possibilidades
#' "Faltou" ~ 0
#' "Não" ~ -1
#' "Sim" ~ 1
#' "Obstrução" ~ 2
#' "Abstenção" ~ 3
#' "Art. 17" ~ 4
#' "Liberado" ~ 5
#'
#' match (retorno) possibilidades
#' 1 seguiu orientação
#' -1 não seguiu orientação
#' 0 não calculado (deputado não estava em exercício)
#' -2 deputado faltou
#' 2 partido liberou 
compara_voto_com_orientacao <- function(voto_deputado, voto_partido) {
  
  if (!is.na(voto_deputado)) {
    if (!is.na(voto_partido)) {
      if (voto_partido != 5 && voto_deputado != 0) {
        if(voto_deputado == voto_partido) {
          return(1) ## deputado seguiu orientação
        } else {
          return(-1) ## deputado não seguiu orientação
        }
      } else {
        if (voto_deputado == 0) {
          return(-2) ## deputado faltou
        }
        
        if (voto_partido == 5) {
          return(2) ## partido liberou
        }
      }
    } else {
      if (voto_deputado == 0) {
        return(-2) ## deputado faltou
      } else {
        return(2) ## partido liberou
      }
    }
  } else {
    return(0) ## deputado não estava em exercício
  }
}
