## Módulo de Articulações/coautorias

Este módulo é responsável por baixar, processar e retornar os dados de articulações dos parlamentares. Em especial, a geração de duas principais: com ambientalistas e com a ministra da Agricultura, Tereza Cristina.

As articulações dizem respeito às autorias em proposições que foram feitas conjuntas com outros parlamentares.

### Os dados

Os dados de autoria são obtidos a partir da raspagem da [página](https://www.camara.leg.br/proposicoesWeb/prop_autores?idProposicao=257161) no site da Câmara. A seguir são agrupados, por par de parlamentares, quantas proposições foram feitas e qual o peso total da relação, calculado de acordo com o número de autores: quanto mais autores teve uma proposição, menor será a relação entre seus autores (definida por 1/(número de autores)).

Para os dados de ambientalistas, foram filtrados os parlamentares que articulavam na autoria de proposições que ambientalistas, isto é, os 100 parlamentares que possuem maior índice de ativismo ambiental, explicado em `parlametria/processor`

Já para os dados de articulações com Tereza Cristina, filtramos apenas os parlamentares que autoraram em conjunto com a ministra em alguma proposição. 

### Uso

#### Articulações com ambientalistas

Para baixar os dados dos parlamentares que coautoraram proposições juntamente com ambientalistas, abra o terminal neste diretório e execute o seguinte comando:

```
Rscript export_articulacoes_ambientalistas.R -o <output_datapath>
```

O argumento -o <output_datapath> corresponde ao caminho e nome do arquivo de saída do dataframe. O valor default é `parlametria/raw_data/articulacoes/articulacoes_com_ambientalistas.csv`.

#### Articulações com Tereza Cristina

Para baixar os dados dos parlamentares que coautoraram proposições com a ministra da Agricultura, abra o terminal neste diretório e execute o seguinte comando:

```
Rscript export_articulacoes_tereza_cristina.R -o <output_datapath>
```

O argumento -o <output_datapath> corresponde ao caminho e nome do arquivo de saída do dataframe. O valor default é `parlametria/raw_data/articulacoes/articulacoes_tereza_cristina.csv`.
