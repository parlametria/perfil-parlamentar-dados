## Geração da tabela de votações do DIAP

O DIAP - Departamento Intersindical de Assessoria Parlamentar divulgou um mapa de Votações na Câmara dos Deputados e no Senado Federal durante a 55ª Legislatura (2015-2019), reunindo as principais votações nominais ocorridas no período na Câmara dos Deputados e no Senado Federal. O arquivo em pdf está disponível neste [link](http://www.diap.org.br/index.php/publicacoes/viewcategory/97-mapa-de-votacoes-camara-dos-deputados-e-senado-federal-2015-a-2019-55-legislatura).

Para gerar a tabela com as informações das votações na Câmara dos Deputados, siga os seguintes passos:

1. Converta o arquivo pdf para xml, utilizando qualquer ferramenta de conversão. Caso não deseje fazer este paso, existe uma versão xml do arquivo neste repositório chamada `mapa_votacoes_2015_2019.xml`.
2. Execute o script que extrai os dados das votações da Câmara do xml e retorna um arquivo csv contendo as seguintes informações: link_votacao, id_votacao, titulo, tipo, votos_sim, votos_nao e votos_abstencao.

  * Para executar o script, entre neste diretório e rode o seguinte comando:
    ```
    Rscript fetcher_votacoes_diap.R -v <arquivo_xml_diap_datapath> -o <output_datapath> 
    ```
    Com os seguintes argumentos:
     * `-v <arquivo_xml_diap_datapath>`: Caminho para o arquivo xml do mapa de votações do diap. O caminho default é "./mapa_votacoes_2015_2019.xml
     * `-o <output_datapath>`: Caminho para o arquivo de saída do csv contendo os dados das votações. O caminho default é "./votacoes_diap.csv"
    