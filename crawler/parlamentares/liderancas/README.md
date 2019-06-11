# Módulo Lideranças

## Como exportar os dados das lideranças dos blocos e partidos

Para gerar o csv de com informações das lideranças dos blocos e partidos é necessário usar o script `export_liderancas.R`

Para isso execute:

```
Rscript export_liderancas.R -o <output_path>
```
Com os seguintes argumentos:
     * `-o <output_path>`: Caminho para o arquivo de saída do csv contendo os dados das lideranças dos blocos e partidos. O caminho default é "../raw_data/liderancas.csv"
     
Após a execução do script o csv será gerado no caminho especificado.