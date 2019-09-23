## Módulo de votações importantes para deputados

Este módulo é responsável por capturar votos de votações importantes a partir de uma lista e em seguida filtrar para obter as votações dos deputados atualmente em exercício.

Mais detalhes sobre o módulo:

O arquivo `analyzer_votacoes_importantes.R` contém duas funções:

- `process_votacoes_importantes`: recupera os votos a partir de uma lista de votações importantes para o meio ambiente na legislatura 55 disponível [aqui](https://docs.google.com/spreadsheets/d/e/2PACX-1vTI6--KJSsbQEtFSHBC6cWoc_jcvGx9oKgnPHedOIDsPMH43UrnSPSd-qauxIV0HpcFA3s9C2D3ubok/pub?gid=0&single=true&output=csv). O formato dos dados é wide, cada linha é um deputado e existe uma coluna para cada votação importante da lista. Os votos foram obtidos usando a API da Câmara dos Deputados ([exemplo](https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=MPV&numero=756&ano=2016)).
- `filter_deputados_atuais_votacoes`: filtra dos dados processados pela função anterior com o objetivo de obter apenas os deputados atualmente em exercício na Câmara dos Deputados.

