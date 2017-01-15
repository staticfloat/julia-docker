run:
	docker-compose build --pull
	docker-compose run --entrypoint=buildbot buildbot upgrade-master /buildbot/master
	docker-compose up -d

clean:
	docker-compose down
