deploy:
	docker-compose build --pull && \
	docker-compose up -d

down:
	docker-compose down --remove-orphans

logs:
	docker-compose logs -f

clean: down
