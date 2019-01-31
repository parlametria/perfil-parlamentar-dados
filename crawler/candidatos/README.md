## Como importar os dados de candidatos do TSE

Este tutorial explica como importar os dados do TSE para os candidatos e exportá-los como csv.

### 1. Baixe os dados e execute a limpeza

Execute o script get-data-candidatos-tse.sh para fazer o download dos dados do repositório de dados abertos do TSE.

```
./fetcher_data_candidatos_tse.sh
```

Lembre-se de dar permissão de execução ao arquivo.

```
chmod +x ./fetcher_data_candidatos_tse.sh
```

Após baixar é necessário fazer uma limpeza nos dados para que a leitura aconteça sem erros. Para isto, execute:

```
./clean_data_candidatos_tse.sh
```

Lembre-se de dar permissão de execução ao arquivo.

Você deve observar ao final da execução que houve a criação de diretórios com arquivos (.txt ou .csv) dentro desses diretórios.

### 2. Execute o processamento dos dados e exporte

#### 2.1 Gerando dados para os candidatos em eleições passadas (2018, 2014, 2010)
Caso você queira executar para os valores usados como padrão (eleições de 2010, 2014 e 2018; cargo de Deputado Federal) execute o seguinte comando:

```
Rscript export_data_candidatos_eleicoes.R
```

Caso você queira modificar os parâmetros de entrada e o local de saída do arquivo. Execute o seguinte comando:

```
Rscript export_data_candidatos_eleicoes.R -a anos.csv -c cargos.csv -o output.csv
```

1. anos.csv : é um csv que deve ser criado com apenas uma coluna composta pelos anos para recuperação dos dados das eleições. O nome da coluna deve ser ano. 
Exemplo:
```
ano
2010
2014
```

2. cargos.csv : é um csv que deve ser criado com apenas uma coluna composta pelos cargos para recuperação dos dados das eleições. Os candidatos serão filtrados considerando esta lista de cargos. O nome da coluna deve ser cargo
Exemplo:
```
cargo
5
6
```

Obs: Execute ```Rscript export_data_candidatos_eleicoes.R -h``` para exibir informações sobre a execução do arquivo, incluindo os valores default. Estes valores consideram os anos (2010, 2014, 2018) e o cargo 6 (Deputado Federal).

#### Lista de Cargos

| Código | Cargo              |
|--------|--------------------|
| 1      | PRESIDENTE         |
| 2      | VICE-PRESIDENTE    |
| 3      | GOVERNADOR         |
| 4      | VICE-GOVERNADOR    |
| 5      | SENADOR            |
| 6      | DEPUTADO FEDERAL   |
| 7      | DEPUTADO ESTADUAL  |
| 8      | DEPUTADO DISTRITAL |
| 9      | 1º SUPLENTE        |
| 10     | 2º SUPLENTE        |

O arquivo com as informações dos candidatos estará no arquivo definido como parâmetro ou em output_candidatos.csv caso o parâmetro não for passado.

#### 2.2 Gerando dados para todos candidatos a deputado federal nas eleições de 2018

Nesta subseção o objetivo é gerar os dados dos candidatos a deputado federal nas eleições de 2018. Estes dados possuem mais informações do que na subseção anterior. Para gerá-los utilize o seguinte comando:

```
Rscript export_info_candidados_2018.R
```

Neste caso o caminho de saída default utilizado é `../raw_data/candidatos.csv`. Caso você queira alterar o caminho para a saída do arquivo, utilize o seguinte comando:

```
Rscript export_info_candidados_2018.R -o ./output.csv
```

Troque `./output.csv` por um caminho da sua preferência.

 Execute ```Rscript export_info_candidados_2018.R -h``` para exibir informações sobre a execução do arquivo

### Informações importantes
O script de processamento dos dados funciona, por enquanto, apenas para os anos de 2010, 2014 e 2018.

**Caso seja necessário adicionar mais anos:** será preciso editar o arquivo `fetcher_data_candidatos_tse.sh` para incluir os novos anos. Caso estes anos se refiram a arquivos que possuem extensão .txt quando extraídos, será preciso também incluir o ano no arquivo `clean_data_candidatos_tse.sh` para que a limpeza seja realizada. Também deverá ser criada uma função (no arquivo `export_data_candidatos.R`) que importe os dados conforme o modelo do TSE adotado para aquele ano.
