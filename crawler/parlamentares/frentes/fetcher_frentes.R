#' @title Recupera frentes do Congresso
#' @description A partir do id e da casa, recupera dados de uma frente
#' @param id_prop ID de uma frente
#' @param casa Camara ou senado
#' @return Dataframe contendo informações de uma frente
#' @examples
#' frente <- fetch_frente(54012, "camara")
fetch_frente <- function(id_frente, casa) {
  print(paste0("Baixando informações da frente de id ", id_frente, "..."))
  frente <- rcongresso::fetch_frentes(id_frente, casa)
  return(frente)
}

#' @title Recupera informacoes de membros das frentes do Congresso
#' @description A partir do id e da casa, recupera dados de uma frente
#' @param id_prop ID de uma frente
#' @param casa Camara ou senado
#' @return Dataframe contendo informações de membros de uma frente
#' @examples
#' membro <- fetch_membros_frente(54012, "camara")
fetch_membros_frente <- function(id_frente, casa) {
  print(paste0("Baixando informações da frente de id ", id_frente, "..."))
  membro <- rcongresso::fetch_membros_frentes(id_frente, casa)
  return(membro)
}
