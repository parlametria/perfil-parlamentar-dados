## Módulo de autores de requerimentos de informação sobre Meio Ambiente e Agricultura
Este módulo é responsável por baixar e processar os autores de requerimentos de informação sobre Agricultura e Meio Ambiente.

### Os dados

Os dados foram obtidos a partir da obtenção de um conjunto de proposições (todas as de [2019](https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv), por exemplo). Depois, são filtrados os requerimentos de informação (RIC) que possuem em sua ementa ou inteiro teor (com pdf "raspável") palavras que encaixem com a expressão regular `"agricultura|meio ambiente"`. A seguir são recuperados os autores destes requerimentos e, por últimos, sumarizados com a quantidade total de RIC por autor.

### Uso

Para exportar os dados com os autores de requerimentos de informação sobre Meio Ambiente e Agricultura, abra o terminal neste diretório e execute o seguinte comando:


```
Rscript export_req_informacao_por_assunto.R -o <output_datapath>
```

O argumento -o <output_datapath> corresponde ao caminho e nome do arquivo de saída do dataframe. O valor default é `parlametria/raw_data/autorias/req_info_meio_ambiente_agricultura.csv`.