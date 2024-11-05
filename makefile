# Makefile
db-up:
	docker-compose -f docker-compose.migrate.yaml run --rm database-up
db-down:
	docker-compose -f docker-compose.migrate.yaml run --rm database-down
app-up:
	docker-compose up -d trade-exportscore-trp-sql
	sleep 5
	docker-compose up trade-exportscore-trp
app-down:
	docker-compose down