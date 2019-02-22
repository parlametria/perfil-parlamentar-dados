# Módulo Parlamentares

## Como exportar dados de parlamentares

Para gerar o csv de com informações de parlamentares é necessário usar o script `export_parlamentares.R`

Para isso execute:

```
Rscript export_parlamentares.R
```

Neste caso o caminho de saída default utilizado é `../raw_data/parlamentares.csv`. Caso você queira alterar o caminho para a saída do arquivo, utilize o seguinte comando:

```
Rscript export_info_candidatos_2018.R -o ./output.csv
```

Troque `./output.csv` por um caminho da sua preferência.

Após a execução do script o csv será gerado no caminho especificado.
