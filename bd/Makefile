.DEFAULT_GOAL : help
help:
	@echo "Voz Ativa BD Makefile Help"
	@echo "This file is intended to ease your life using docker commands"	
	@echo "You just need to run 'make <command>'"
	@echo "    "	
	@echo "    help - Print this help message"
	@echo "    "	
	@echo "    up"
	@echo "        Start services."	
	@echo "    "
	@echo "    create"
	@echo "        Create Table and Import data to Postgres"	
	@echo "    "
	@echo "    logs"
	@echo "        See services logs."	
	@echo "    "
	@echo "    stop"
	@echo "        Stop services."
	@echo "    "		
	@echo "    clean"
	@echo "        stop and remove volumes."
	@echo "    "	
	@echo "    clean-all"
	@echo "        stop and remove all service containers, volumes and images."
	@echo "    "	
	@echo "    sh"
	@echo "        Open sh prompt inside container with name postgres.	"
.PHONY: help
create:
	docker-compose exec db psql -U postgres -d vozativa -1 -f scripts/create_table_bd_vozativa.sql
	docker-compose exec db psql -U postgres -d vozativa -1 -f scripts/import_csv_bd_vozativa.sql
.PHONY: create
logs:
	docker-compose logs --tail=100
.PHONY: logs
stop:
	docker-compose stop
.PHONY: stop
up:
	docker-compose up
.PHONY: up
clean:
	docker-compose down --volumes
.PHONY: clean
clean-all:
	docker-compose down --volumes
.PHONY: clean-all
sh:
	docker exec -it postgres sh
.PHONY: clean-all
