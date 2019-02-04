#!/bin/bash

echo "Baixando dados do TSE"
for ano in 2010 2014 2018; do 
	echo "Eleição de $ano"
	curl -o consulta_cand_${ano}.zip http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_${ano}.zip
	mkdir -p consulta_cand_${ano}
	unzip -o consulta_cand_${ano}.zip -d consulta_cand_${ano}/
	rm consulta_cand_${ano}.zip
done
