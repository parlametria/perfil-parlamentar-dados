FROM rocker/tidyverse:3.6.1

WORKDIR /app

## Adiciona client do postgres para atualização do banco de dados remoto
RUN apt-get update && apt-get install -y gnupg2
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >  /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN yes Y | apt-get install postgresql-client-10

RUN apt-get install -y libpoppler-cpp-dev

## Cria arquivo para indicar raiz do repositório (Usado pelo pacote here)
RUN touch .here

## Instala dependências
RUN R -e "install.packages(c('here', 'optparse', 'RCurl', 'xml2', 'ellipsis'), repos='http://cran.rstudio.com/')"

RUN R -e "devtools::install_github('analytics-ufcg/rcongresso', force = T)"
RUN R -e "devtools::install_github('analytics-ufcg/leggoR', force = T)"
RUN R -e "install.packages('pdftools')"

## Configura cron para execução automática da atualização
ENV TZ=America/Recife

RUN apt-get update && apt-get -y install cron

RUN echo "0 7 * * 2 /bin/sh /app/bd/update.sh >> /app/bd/cron-job.log 2>&1" > /etc/cron.d/cron-job

RUN chmod 0644 /etc/cron.d/cron-job

RUN crontab /etc/cron.d/cron-job

COPY .env .env

RUN cp .env /etc/environment 

ENTRYPOINT ["cron", "-f"]
