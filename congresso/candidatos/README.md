## Como importar os dados de candidatos do TSE

Este tutorial explica como importar os dados do TSE para os candidatos e exportá-los como csv.

### 1. Baixe os dados e execute a limpeza

Execute o script get-data-candidatos-tse.sh para fazer o download dos dados do repositório de dados abertos do TSE.

```
./get-data-candidatos-tse.sh
```

Lembre-se de dar permissão de execução ao arquivo.

```
chmod +x ./get-data-candidatos-tse.sh
```

Após baixar é necessário fazer uma limpeza nos dados para que a leitura aconteça sem erros. Para isto, execute:


```
./clean-data-candidatos-tse.sh
```

Lembre-se de dar permissão de execução ao arquivo.

Você deve observar ao final da execução que houve a criação de diretórios com arquivos (.txt ou .csv) dentro desses diretórios.

### 2. Execute o processamento dos dados e exporte

```
Rscript export-data-candidatos.R -a anos.csv -c cargos.csv -o output.csv
```

1. anos.csv : um csv com apenas uma coluna composta pelos anos para recuperação dos dados das eleições. O nome da coluna deve ser ano
2. cargos.csv : um csv com apenas uma coluna composta pelos cargos para recuperação dos dados das eleições. Os candidatos serão filtrados considerando esta lista de cargos. O nome da coluna deve ser cargo

Obs: Execute ```Rscript export-data-candidatos.R -h``` para exibir informações sobre a execução do arquivo, incluindo os valores default. Estes valores consideram os anos (2010, 2014, 2018) e o cargo 6 (Deputado Federal).

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

### Informações importantes
O script de processamento dos dados funciona, por enquanto, apenas para os anos de 2010, 2014 e 2016.

**Caso seja necessário adicionar mais anos:** será preciso editar o arquivo `get-data-candidatos-tse.sh` para incluir os novos anos. Caso estes anos se refiram a arquivos que possuem extensão .txt quando extraídos, será preciso também incluir o ano no arquivo `clean-data-candidatos-tse.sh` para que a limpeza seja realizada. Também deverá ser criada uma função (no arquivo `import-data-candidatos.R`) que importe os dados conforme o modelo do TSE adotado para aquele ano.
