## Parlametria

Este módulo contém funções para captura, tratamento e disponibilização de dados relacionados aos parlamentares, suas atuações na Câmara e no Senado, seu histórico político, seus patrimônios e receitas eleitorais.

Para atualizar os dados deste módulo (usados como base para o cálculo do índice dos parlamentares) execute (assumindo que você executou `docker-compose up` na raiz desse respositório)

```
docker exec -it r-updater sh -c "cd parlametria/processor/ && Rscript update_data_parlametria.R"
```