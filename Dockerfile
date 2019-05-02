FROM rocker/tidyverse:3.4.4

WORKDIR /app

## Adiciona client do postgres para atualização do banco de dados remoto
RUN apt-get update && apt-get install -y gnupg2
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >  /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN yes Y | apt-get install postgresql-client-10


## Cria arquivo para indicar raiz do repositório (Usado pelo pacote here)
RUN touch .here

## Instala dependências
RUN R -e "install.packages(c('here', 'optparse', 'RCurl', 'xml2'), repos='http://cran.rstudio.com/')"

RUN R -e "devtools::install_github('analytics-ufcg/leggoR', force = T)"
RUN R -e "devtools::install_github('analytics-ufcg/rcongresso', force = T)"
