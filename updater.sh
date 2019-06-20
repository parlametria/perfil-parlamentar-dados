#!/bin/bash

docker exec -it r-updater sh -c "Rscript bd/update_data.R"

docker exec -it r-updater sh -c "cd /app/bd && Rscript update_bd.R"
