## Geração das tabelas de votos e de orientações

Estas tabelas possuem informações referentes aos votos dos deputados federais em todas as votações realizadas em plenário em 2019 e das orientações dos partidos para essas orientações.

Para gerar esta tabela, siga as seguintes etapas:

1. Execute o script que processa os dados
  * Para executar o script, entre neste diretório e rode o seguinte comando:
    ```
    Rscript export_votos_orientacoes.R -a 2019
    ```
    Com os seguintes argumentos:
     * `-a <ano>`: Ano de ocorrência das votações em plenário     
