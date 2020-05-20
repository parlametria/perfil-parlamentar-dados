## Sobre os dados

Este documento irá explicar sobre os dados capturados e processados das coautorias em documentos relacionados à proposições com o tema de Meio Ambiente que foram apresentadas a partir do dia 2 de fevereiro de 2019.

### Dados importantes 

**autores.csv**: Lista de autores dos documentos. Cada linha deste CSV é um documento (id_req) ligado a seu autor (id) e a um peso (peso_arestas). O peso indica o quão forte é a ligação entre os autores de um mesmo documento considerando a quantidade de autores do documento. Quanto mais coautores em um documento, menos forte será as relações entre os autores, e por isso o peso da ligação será menor.

**coautorias.csv**: Ligações entre dois autores de um documento. Para cada documento, se apresentará a ligação entre dois coautores. Este csv possui
o id do documento (id_req), o peso dessa ligação (peso_arestas), os coautores (id.x, id.y), o número de coautorias entre os coautores (num_coautorias) e o nome dos coautores (nome_eleitoral.x,nome_eleitoral.y).

**parlamentares.csv**: Informações dos parlamentares incluindo identificador (id), nome eleitoral, partido e UF.
