.PHONY: dev deploy dbdeploy import dbimport help update fulldeploy
	
# path to local project
path=~/public_html/www/general-concept/
# ssh adress to prod server
ssh=webmaster@krealab.ds.planet-work.net
# domain name of prod server
domain=https://krealab.agency/general-concept
# localhost
dev=http://localhost:8000

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dev: ## Lance le serveur de développement
	php -S localhost:8000 -d display_errors=1 -t web

import: ## Importe les fichiers distants
	rsync -av $(ssh):$(path) ./ \
	    --exclude wp-config.php

deploy: ## Déploie une nouvelle version de l'application
	rsync -av ./ $(ssh):$(path) \
        --exclude Makefile \
        --exclude wp-config.php \
        --exclude .git \
        --exclude .idea \
		--exclude node_modules/ \

# --exclude wp-content/uploads \

dbdeploy: ## Envoie la base de données sur le serveur
	php wp db export --add-drop-table dump.sql
	rsync -av ./dump.sql $(ssh):$(path)
	ssh $(ssh) "cd $(path); php wp db import dump.sql; php wp search-replace '$(dev)' '$(domain)';rm	dump.sql"
	rm dump.sql

dbimport: ## Récupère la base de données depuis le serveur
	ssh $(ssh) "cd $(path); php wp db export --add-drop-table dump.sql"
	rsync -av $(ssh):$(path)dump.sql ./
	ssh $(ssh) "rm $(path)dump.sql"
	php wp db import dump.sql
	php wp search-replace '$(domain)' '$(dev)'
	rm dump.sql

update:
	wp core update
	wp plugin update --all

fulldeploy: deploy dbdeploy
