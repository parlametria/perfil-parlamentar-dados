## Módulo de empresas agrícolas relacionadas aos parlamentares

Este módulo é responsável por extrair, processar e retornar os dados das empresas agrícolas relacionadas aos parlamentares em atuais.

Essa relação pode ocorrer de três formas, gerando diferentes dados:
 1. Os parlamentares são sócios das empresas;
 2. Os parlamentares receberam doações no período eleitoral. 
 3. As próprias empresas que doaram para a campanha dos parlamentares. Isso foi possível até as eleições de 2014, depois disso as doações só podem ser de pessoas físicas.

Os dados utilizados estão descritos na lista abaixo.
- Receitas de doações declaradas pelos candidatos e disponibilizados pelo [TSE](http://www.tse.jus.br/eleicoes/estatisticas/repositorio-de-dados-eleitorais-1/repositorio-de-dados-eleitorais);
- Cadastros das empresas brasileiras, disponíveis na [Receita Federal](http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj) e disponibilzados em uma API por [Cuducos](https://github.com/cuducos/minha-receita);
- Sócios de empresas, também disponíveis na Receita Federal e processados por [Turicas](https://github.com/turicas/socios-brasil);

Filtramos as empresas de acordo com o seu CNAE - Classificação Nacional de Atividades Econômicas. 
Nesta [planilha](https://cnae.ibge.gov.br/images/concla/documentacao/CNAE_Subclasses_2_3_Estrutura_Detalhada.xlsx), disponibilizada pela CONCLA no site do IBGE, estão mapeadas os cógidos do CNAE com as atividades desempenhadas pelas empresas. Consideramos empresas agrícolas as da seção `A: AGRICULTURA, PECUÁRIA, PRODUÇÃO FLORESTAL, PESCA E AQUICULTURA`.

### Uso 

As instruções de uso estão disponíveis dentro de cada submódulo neste diretório.