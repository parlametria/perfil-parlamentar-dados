## Como inserir novos dados de votações no banco

1. Atualiza planilha TabelaAuxVotações
2. Roda script que processa os dados de candidatos e votações e retorna um arquivo csv contendo informações dos votos dos candidatos nas votações
  * Para executar o script, deve-se rodar o seguinte comando:
    ```
    Rscript processa_votacoes.R -c <candidatos_datapath> -v <votacoes_datapath> -o <output_datapath> 
    ```
    Com os seguintes argumentos:
     * `-c <candidatos_datapath>`: Caminho para o arquivo csv contendo os dados dos candidatos. O caminho default é "candidatos/output.csv"
     * `-v <votacoes_datapath>`: Caminho para o arquivo csv contendo os dados das votações. O caminho default é "dados\ congresso/TabelaAuxVotacoes.csv"
     * `-o <output_datapath>`: Caminho para o arquivo de saída do csv contendo os dados dos votos dos candidatos. O caminho default é "dados\ congresso/votacoes.csv"
    
3. Roda script escreve_json_vot.py
4. Para colocar no db roda script votacoes2db.py na pasta vozativa-monkey-ui
