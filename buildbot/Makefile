deploy:
	docker-compose build --pull && \
	docker-compose up -d

shell:
	docker-compose exec buildbot bash

down:
	docker-compose down --remove-orphans

logs:
	docker-compose logs -f

clean: down
