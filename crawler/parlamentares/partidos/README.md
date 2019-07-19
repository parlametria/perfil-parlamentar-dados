# Módulo Partidos

## Como exportar os dados de partidos políticos dos parlamentares

Para gerar o csv de com informações de partidos políticos dos parlamentares é necessário usar o script `export_partidos.R`

Para isso execute:

```
Rscript export_partidos.R -l <legislatures_ids> -o <output_path>
```
Com os seguintes argumentos:
     * `-l <legislatures_ids>`: Ids das legislaturas que se deseja baixar os partidos políticos, separados por vírgula. O default é a string "55,56", que baixa as informações das legislaturas 55 e 56.
     * `-o <output_path>`: Caminho para o arquivo de saída do csv contendo os dados dos mandatos dos candidatos. O caminho default é "../raw_data/partidos.csv"
     
Após a execução do script o csv será gerado no caminho especificado.