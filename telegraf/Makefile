up:
	docker-compose build --pull
	docker-compose up --remove-orphans -d

down:
	docker-compose down

destroy:
	docker-compose down -v --remove-orphans

shell:
	docker-compose exec telegraf /bin/bash

logs:
	docker-compose logs -f --tail=100
