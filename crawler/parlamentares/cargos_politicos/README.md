## Módulo de cargos políticos

Este módulo é responsável por baixar e processar os dados de histórico de cargos políticos dos atuais parlamentares em exercício. 

### Os dados

Os dados foram obtidos utilizando a biblioteca [cepespR](https://github.com/Cepesp-Fgv/cepesp-r) e filtrando os parlamentares que foram eleitos em cargos políticos nas eleições de 1998 a 2018.

### Uso

Para exportar os dados de cargos políticos dos parlamentares em exercício, abra o terminal neste diretório e execute o seguinte comando:


```
Rscript export_cargos_politicos.R -o <output_datapath>
```

O argumento -o <output_datapath> corresponde ao caminho e nome do arquivo de saída dos cargos políticos. O valor default é `crawler/raw_data/historico_parlamentares_cargos_politicos.csv`.