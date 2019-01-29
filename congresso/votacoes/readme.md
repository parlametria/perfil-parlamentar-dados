## Geração da planilha TabelaAuxVotações

1. Roda script que processa os dados das votações da Câmara levantadas pela DIAP e retorna um arquivo csv contendo informações detalhadas destas votações
  * Para executar o script, deve-se rodar o seguinte comando:
    ```
    Rscript pega_votacoes_diap.R -v <arquivo_xml_diap_datapath> -o <output_datapath> 
    ```
    Com os seguintes argumentos:
     * `-v <arquivo_xml_diap_datapath>`: Caminho para o arquivo csv contendo os dados das votações. O caminho default é "./mapa_votacoes_2015_2019.xml
     * `-o <output_datapath>`: Caminho para o arquivo de saída do csv contendo os dados das votações. O caminho default é "./votacoes_diap.csv"
    