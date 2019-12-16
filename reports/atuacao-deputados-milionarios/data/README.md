## Sobre os dados

**aderencia_parlamentares_governo.csv**: contém informações de aderência para os parlamentares que receberam altas doações na campanha de 2018.

Colunas
- aderencia: número de vezes que seguiu a orientação do governo dividido pelo número de vezes que seguiu somado com o número de vezes que não seguiu.
- liberado: O governo não apresentou orientação.
- aderencia_temas_governo: Aderência calculada filtrando apenas as proposições do tema de Agenda Nacional ou proposições que sejam MPV.

A orientação do governo é obtida através da indicação explícita da orientação disponibilizada pela Câmara. Caso essa orientação não esteja disponível o voto do líder do governo é considerado orientação.

Esse csv foi gerado pela função `processa_aderencia_parlamentares_lista` do arquivo `reports/atuacao-deputados-milionarios/scripts/aderencia_parlamentares.R`
