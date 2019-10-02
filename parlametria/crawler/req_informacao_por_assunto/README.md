## Módulo de autores de requerimentos de informação sobre Meio Ambiente e Agricultura
Este módulo é responsável por baixar e processar os autores de requerimentos de informação sobre Agricultura e Meio Ambiente.

### Os dados

Os dados foram obtidos a partir de uma requisição à API que gera os dados da Câmara, mais especificadamente a [ferramenta](https://www.camara.leg.br/busca-portal?contextoBusca=BuscaProposicoes&pagina=1&order=relevancia&abaEspecifica=true&filtros=%5B%7B%22ano%22%3A2019%7D%5D&q=meio%20ambiente&tipos=RIC) de busca. A chamada retorna as proposições que se encaixam em vários critérios de filtro, como ano, tipo da proposição e paravras-chaves, neste caso são requerimentos de informação (RIC) no ano de 2019 e com os termos "meio ambiente" e "agricultura". A seguir são recuperados os autores destes requerimentos e, por último, sumarizados com a quantidade total de RIC por autor.

### Uso

Para exportar os dados com os autores de requerimentos de informação sobre Meio Ambiente e Agricultura, abra o terminal neste diretório e execute o seguinte comando:


```
Rscript export_req_informacao_por_assunto.R -o <output_datapath>
```

O argumento -o <output_datapath> corresponde ao caminho e nome do arquivo de saída do dataframe. O valor default é `parlametria/raw_data/autorias/req_info_meio_ambiente_agricultura.csv`.