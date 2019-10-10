## Módulo de Resumo do parlamentar

Este módulo é responsável por recuperar informações dos parlamentares envolvendo dados de aderência em votações nominais realizadas no plenário da Câmara relacionada a proposições cujo tema é atrelado ao Meio Ambiente. Também recupera informações do investimento do partido durante as eleições de 2018 e o quanto, em termos proporcionais o deputado recebeu investimento do seu partido na unidade de campanhas médias.

Existem 3 submódulos:

**investimento_partidario:** Recupera informações do investimento partidário em parlamentares nas eleições de 2018. Calculamos a média das campanhas para deputados em cada Unidade Federativa (UF). Em seguida para cada deputado calculamos a proporção do total investido pelo partido dividido pela média das campanhas na UF). Esse valor mostra quantas campanhas médias o partido investiu no candidato durante a eleição. Depois somamos todas as campanhas médias de um partido e calculamos a proporção para o candidato. Ou seja, campanhas médias do candidato / soma de todas as campanhas médias do partido.

Para exportar os dados execute (do diretório investimento_partidario): `Rscript export_investimento_partidario.R`

**cargos_resumo:** Recupera informações de cargos em comissões e ldierenças em partidos para deputados e senadores.

Para exportar os dados execute (do diretório cargos_resumo): `Rscript export_cargos_resumo.R`

**aderencia:** Recupera informações de aderência ao governo em votações de Meio Ambiente.

Para exportar os dados execute (do diretório aderencia): `Rscript export_aderencia.R`
