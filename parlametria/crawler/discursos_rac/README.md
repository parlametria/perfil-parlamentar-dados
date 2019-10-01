## Módulo de discursos analisados pela RAC

Este módulo é responsável por baixar e processar os dados de quão ambientalista são os discursos dos parlamentares, de acordo com a análise feita pela RAC.

### Os dados

Os dados foram obtidos a partir da [planilha](https://docs.google.com/spreadsheets/d/e/2PACX-1vTSsosKOoLys4UpQ4FnPWQBswj5JvFHZ282HCC1Drh21F2nPknX4ieY6NUX8n8dfQR53HCVfWezKUXy/pub?gid=1003410603&single=true&output=csv) feita pela RAC, contendo um número associado ao discursos de cada parlamentar, que representa o quão ambientalista ou não são as falas dele.

### Uso

Para exportar os dados com o score dos discursos dos parlamentares, abra o terminal neste diretório e execute o seguinte comando:


```
Rscript export_discursos_rac.R -o <output_datapath>
```

O argumento -o <output_datapath> corresponde ao caminho e nome do arquivo de saída do dataframe. O valor default é `parlametria/raw_data/discursos_rac/discursos_parlamentares.csv`.