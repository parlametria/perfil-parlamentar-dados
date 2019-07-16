# Módulo Votações nas Comissões

## Como exportar os dados das votações nas comissões

Para gerar o csv de com informações das votações nas comissões é necessário usar o script `export_votacoes_comissoes.R`

Para isso execute:

```
Rscript export_votacoes_comissoes.R -i <input_path> -y <year> -o <output_path>
```
Com os seguintes argumentos:
     * `-i <input_path>`: Caminho para o arquivo csv contendo os dados dos parlamentares. O caminho default é "../raw_data/parlamentares.csv"
     * `-y <year>`: Ano das votações. O ano default é 2019
     * `-o <output_path>`: Caminho para o arquivo de saída do csv contendo os dados das votações nas comissões dos deputados. O caminho default é "../raw_data/mandatos.csv"
     
Após a execução do script o csv será gerado no caminho especificado.