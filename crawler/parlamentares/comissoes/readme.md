## Geração das tabelas relacionadas às Comissões

As tabelas de comissões possuem informações referentes a Comissões e a composição dessas Comissões (quais os parlamentares que são membros).

Para gerar esta tabela, siga as seguintes etapas:

1. Execute o script que processa os dados de Comissões. Para isto **execute do mesmo diretório deste readme** o seguinte comando:

```
Rscript analyzer_comissoes.R --outComposicoes <composicao_composicoes_datapath> --outComissoes <comissoes_datapath> 
```

Com os seguintes argumentos:
* `--outComposicoes <composicao_composicoes_datapath>`: Caminho para o arquivo csv de saída contendo os dados das composições das Comissões. O caminho default é "../../raw_data/composicao_comissoes.csv"
* `--outComissoes <comissoes_datapath>`: Caminho para o arquivo csv de saída contendo os dados das Comissões. O caminho default é "../../raw_data/comissoes.csv"

Se preferir execute com os caminhos de saída default:
```
Rscript analyzer_comissoes.R
```
