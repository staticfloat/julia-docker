run:
	docker-compose build --pull
	docker-compose run buildbot "buildbot upgrade-master /buildbot/master"
	docker-compose up -d

clean:
	docker-compose down
