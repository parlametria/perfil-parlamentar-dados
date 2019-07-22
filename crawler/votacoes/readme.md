## Geração da tabela Votações

Esta tabela possui informações referentes aos votos dos deputados federais em todas as votações levantadas pelo Voz Ativa, distribuídas nas seguintes colunas: id_votacao, cpf e voto.

Para gerar esta tabela, siga as seguintes etapas:

1. Execute o script que processa os dados de candidatos, das votações e baixa as informações dos votos correspondentes.
  * Para executar o script, entre neste diretório e rode o seguinte comando:
    ```
    Rscript fetcher_votos_camara.R -v <votacoes_datapath> -o <output_datapath> 
    ```
    Com os seguintes argumentos:
     * `-v <votacoes_datapath>`: Caminho para o arquivo csv contendo os dados das votações. O caminho default é "../raw_data/tabela_votacoes.csv"
     * `-o <output_datapath>`: Caminho para o arquivo de saída do csv contendo os dados dos votos dos candidatos. O caminho default é "../raw_data/votacoes.csv"
