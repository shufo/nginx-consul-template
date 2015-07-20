# boot virtual machine and containers
install:
	@echo "Verify no other virtual machines are booting. \n\n"
	vagrant up
	docker-compose -f docker-compose.yml -p nodes up -d
	make restart nginx
# remove virtual machine
uninstall:
	vagrant destroy -f

.PHONY: build
ifeq (build,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
build:
	docker-compose -f docker-compose.yml -p nodes build $(RUN_ARGS)

.PHONY: logs
ifeq (logs,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
logs:
	docker-compose -f docker-compose.yml -p nodes logs $(RUN_ARGS)

.PHONY: run
ifeq (run,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
run:
	docker-compose -f docker-compose.yml -p nodes run $(RUN_ARGS)

.PHONY: up
ifeq (up,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
up:
	docker-compose -f docker-compose.yml -p nodes up -d $(RUN_ARGS)

.PHONY: rm
ifeq (rm,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
rm:
	docker-compose -f docker-compose.yml -p nodes kill $(RUN_ARGS) && \
	docker-compose -f docker-compose.yml -p nodes rm -f $(RUN_ARGS)

ps:
	docker-compose -f docker-compose.yml -p nodes ps

.PHONY: restart
ifeq (restart,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
restart:
	docker-compose -f docker-compose.yml -p nodes kill $(RUN_ARGS) && \
	docker-compose -f docker-compose.yml -p nodes rm -f $(RUN_ARGS) && \
	docker-compose -f docker-compose.yml -p nodes up -d $(RUN_ARGS)

.PHONY: recreate
ifeq (recreate,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
recreate:
	docker-compose -f docker-compose.yml -p nodes kill $(RUN_ARGS) && \
	docker-compose -f docker-compose.yml -p nodes rm -f $(RUN_ARGS) && \
	docker-compose -f docker-compose.yml -p nodes build $(RUN_ARGS) && \
	docker-compose -f docker-compose.yml -p nodes up -d $(RUN_ARGS)

.PHONY: attach
ifeq (attach,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif
attach:
	docker exec -it nodes_$(RUN_ARGS)_1 /bin/bash
