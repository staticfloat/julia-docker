# The hostname of build.julialang.org is "buildbot"
# The hostname of buildog.julialang.org is "buildog"
ENV_TEMPLATE=.env.$(HOSTNAME)
ifneq ($(shell [ -f $(ENV_TEMPLATE) ] && echo "exists"),exists)
ENV_TEMPLATE=.env.generic
endif

.env: $(ENV_TEMPLATE)
	@echo "Auto-generating .env from $<..."
	@echo "## This file autogeneated from $<" > "$@"
	@cat "$<" >> "$@"

deploy: .env
	docker-compose build --pull && \
	docker-compose up -d

shell:
	docker-compose exec buildbot bash

down:
	docker-compose down --remove-orphans

logs:
	docker-compose logs -f --tail=100

clean: down
