

postgres:
	docker volume create --name pgdata
	docker run --name postgres -v pgdata:/var/lib/postgresql/data -p 5432:5432 -d postgres:9.5
	sleep 2
	docker exec postgres psql -U postgres template1 -c "create extension citext; \
	    create extension hstore; \
	    create extension fuzzystrmatch ; \
	    create extension cube; \
	    create extension tsearch2; \
	    create extension unaccent;"  


postgres-rebuild:
	docker stop postgres
	docker rm postgres
	docker volume rm pgdata
	make postgres
