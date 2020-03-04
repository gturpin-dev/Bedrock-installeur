.PHONY: dev deploy dbdeploy import dbimport help update fulldeploy delete_revisions get_wpcli fullimport

# path to local project
path=~/public_html/www/folder-name/
# ssh adress to prod server
ssh=user@ipadress
# domain name of prod server
domain=https://domain.com
# localhost
dev=http://localhost:8000

# if wp-cli is installed we use him, if don't, we use wp-cli.phar
WPCLI_INSTALLED=true
ifeq ($(WPCLI_INSTALLED), true)
	prefix = wp
else
	prefix = php wp-cli.phar
endif

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dev: ## Lance le serveur de développement
	php -S localhost:8000 -d display_errors=1 -t web

import: ## Importe les fichiers distants
	rsync -av $(ssh):$(path) ./ \
	    --exclude wp-config.php

deploy: ## Déploie les fichiers locaux
	rsync -av ./ $(ssh):$(path) \
        --exclude Makefile \
        --exclude wp-config.php \
        --exclude .git \
        --exclude .idea \
		--exclude node_modules/ \

# --exclude wp-content/uploads \

dbdeploy: ## Envoie la base de données sur le serveur
	$(prefix) db export --add-drop-table dump.sql
	rsync -av ./dump.sql $(ssh):$(path)
	ssh $(ssh) "cd $(path); $(prefix) db import dump.sql; $(prefix) search-replace '$(dev)' '$(domain)';rm	dump.sql"
	rm dump.sql

dbimport: ## Récupère la base de données depuis le serveur
	ssh $(ssh) "cd $(path); $(prefix) db export --add-drop-table dump.sql"
	rsync -av $(ssh):$(path)dump.sql ./
	ssh $(ssh) "rm $(path)dump.sql"
	$(prefix) db import dump.sql
	$(prefix) search-replace '$(domain)' '$(dev)'
	rm dump.sql

update: ## Met a jour wordpress
	wp core update
	wp core update-db
	wp plugin update --all

fulldeploy: deploy dbdeploy ## Déploie le site complet sur le serveur

fullimport: import dbimport ## Importe le site complet en local

delete_revisions: ## Supprime les révisions
	$(prefix) post delete \$\($(prefix) post list --post_type='revision' --format=ids\)

get_wpcli: ## Télécharge wp-cli.phar
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
