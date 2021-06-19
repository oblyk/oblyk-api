# Oblyk Migration 

## Mettre en maintenance Oblyk
/!\ À vérifier
```shell
ssh-oblyk
cd ~/www/oblyk.org/web/
php artisan down
```

## Récupération des anciennes données d'oblyk
- utilise PhpStorm pour faire un mysqldum de sql9097_1 (ajouter --column-statistics=0 dans le run)
- supprimer l'ancienne base de donée : `DROP DATABASE sql9097_1;`
- créer un nouvelle pour l'import : `CREATE DATABASE sql9097_1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
- sur RubyMine, au niveau de sql9097_1 faire "Run SQL script" et séléctionner le dump fait si dessus (prend environs 8 mintues)

## Upload du dossier image
Se connecter en ssh sur l'ancien serveur d'oblyk : `ssh-oblyk`
```shell
cd ~/www/oblyk.org/web/
tar -czvf import_storage.tar.gz storage/app/public
```

En puis en local
```shell
cd /home/lucien/www
scp -P 27597 p7597@p7597.phpnet.org:/home/www/oblyk.org/web/import_storage.tar.gz .
```

De nouveau sur le serveur d'oblyk -> supprimer le storage
```shell
cd ~/www/oblyk.org/web/
rm import_storage.tar.gz
```

Envoyer le storage sur le nouveau serveur et le décompresser
```shell
# en local
cd /home/lucien/www
scp -P 1622 import_storage.tar.gz lucien@next.oblyk.org:/var/www/oblyk/api/current

# sur le server
cd /var/www/oblyk/api/current/
tar -xvzf import_storage.tar.gz
```

## Désactivation des tâche de fond
```shell
# Sur le serveur
cd /var/www/oblyk/api/shared/config/
nano local_env.yml

# Passer à false les clés suivantes :
GAP_GRADABLE: 'false'
CRAG_ROUTE_ASCENTS_HISTORIZATION: 'false'
SEARCH_INGESTABLE: 'false'
FEEDABLE: 'false'
PAPER_TRAIL: 'false'
```

## Control des cotations
Avant de lancer les import, vérifier qu'il n'y a pas eu d'ajout de cotation chelou depuis le dernier inmport
```mysql
SELECT DISTINCT CONCAT(grade, sub_grade) FROM route_sections WHERE DATE(updated_at) > '2021-06-17';
```
Ajouter à la liste de normalisation dans la task d'import des voies si c'est le cas

## Tables

- [x] users `RAILS_ENV=production bundle exec rake import:users["production","/var/www/oblyk/api/current/storage/app/public"]`
- [x] subscribes `RAILS_ENV=production bundle exec rake import:subscribes["production"]`
----
- [x] conversations `RAILS_ENV=production bundle exec rake import:conversations["production"]`
- [x] conversation_users `RAILS_ENV=production bundle exec rake import:conversation_users["production"]`
- [x] conversation_messages `RAILS_ENV=production bundle exec rake import:conversation_messages["production"]`
----
- [x] words `RAILS_ENV=production bundle exec rake import:words["production"]`
----
- [x] crags `RAILS_ENV=production bundle exec rake import:crags["production"]`
- [x] crag_sectors `RAILS_ENV=production bundle exec rake import:crag_sectors["production"]`
- [ ] crag_routes `RAILS_ENV=production bundle exec rake import:crag_routes["production"]`
- [x] parks `RAILS_ENV=production bundle exec rake import:parks["production"]`
- [x] approaches `RAILS_ENV=production bundle exec rake import:approaches["production"]`
- [x] areas `RAILS_ENV=production bundle exec rake import:areas["production"]`
- [x] area_crags `RAILS_ENV=production bundle exec rake import:area_crags["production"]`
----
- [ ] ascents `RAILS_ENV=production bundle exec rake import:ascents["production"]`
- [ ] tick_lists `RAILS_ENV=production bundle exec rake import:tick_lists["production"]`
- [ ] ascent_users `RAILS_ENV=production bundle exec rake import:ascent_users["production"]`
----
- [ ] comments `RAILS_ENV=production bundle exec rake import:comments["production"]`
- [ ] links `RAILS_ENV=production bundle exec rake import:links["production"]`
- [ ] follows `RAILS_ENV=production bundle exec rake import:follows["production"]`
- [x] alerts `RAILS_ENV=production bundle exec rake import:alerts["production"]`
----  
- [x] guide_book_webs `RAILS_ENV=production bundle exec rake import:guide_book_webs["production"]`
- [x] guide_book_pdfs `RAILS_ENV=production bundle exec rake import:guide_book_pdfs["production","/var/www/oblyk/api/current/storage/app/public"]`
- [x] guide_book_papers `RAILS_ENV=production bundle exec rake import:guide_book_papers["production","/var/www/oblyk/api/current/storage/app/public"]`
- [x] guide_book_paper_crags `RAILS_ENV=production bundle exec rake import:guide_book_paper_crags["production"]`
- [x] place_of_sales `RAILS_ENV=production bundle exec rake import:place_of_sales["production"]`
----
- [ ] videos `RAILS_ENV=production bundle exec rake import:videos["production"]`
- [ ] photos `RAILS_ENV=production bundle exec rake import:photos["production","/var/www/oblyk/api/current/storage/app/public"]`
---
- [x] gyms `RAILS_ENV=production bundle exec rake import:gyms["production","/var/www/oblyk/api/current/storage/app/public"]`
- [x] gym_administrators `RAILS_ENV=production bundle exec rake import:gym_administrators["production"]`
- [x] gym_grades `RAILS_ENV=production bundle exec rake import:gym_grades["production"]`
- [x] gym_grade_lines `RAILS_ENV=production bundle exec rake import:gym_grade_lines["production"]`
- [x] gym_spaces `RAILS_ENV=production bundle exec rake import:gym_spaces["production","/var/www/oblyk/api/current/storage/app/public"]`
- [x] gym_sectors `RAILS_ENV=production bundle exec rake import:gym_sectors["production"]`

### function after import
- [x] refresh crag data `RAILS_ENV=production bundle exec rake refresh_data:crag`
- [x] refresh crag sector data `RAILS_ENV=production bundle exec rake refresh_data:crag_sector`
- [ ] refresh crag route data `RAILS_ENV=production bundle exec rake refresh_data:crag_route`
- [ ] refresh counters cache (see `reset_counters_cache` task)
