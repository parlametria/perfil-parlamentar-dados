## Geração da tabela Votações com link para inteiro teor

Esta tabela possui informações referentes às votações ocorridas em um intervalo de tempo (parametrizado em anos) juntamente com o link para o inteiro teor do objeto de votação, que pode ser emenda, substitutivo ou a própria proposição.

Para gerar esta tabela, siga as seguintes etapas:

1. Execute o script que processa os dados de votações.
  * Para executar o script, entre neste diretório e rode o seguinte comando:
    ```
    Rscript export_votacoes_com_inteiro_teor.R -i <iniyear> -e <endyear> -o <output_datapath> 
    ```
    Com os seguintes argumentos:
     * `-i <iniyear>`: Ano inicial das votações. O ano default é "2015".
     * `-e <endyear>`: Ano final das votações. O ano default é "2019".
     * `-o <output_datapath>`: Caminho para o arquivo de saída do csv contendo os dados das votações. O caminho default é "../raw_data/votacoes_nominais_15_a_19.csv"