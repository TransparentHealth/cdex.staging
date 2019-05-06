
up:
	docker-compose up -d
	docker-compose exec verifymyidentity python manage.py migrate
	docker-compose exec sharemyhealth python manage.py migrate
	docker-compose exec sharemyhealth_app python manage.py migrate
	docker-compose exec verifymyidentity python manage.py loaddata /fixtures/vmi.json
	docker-compose exec sharemyhealth python manage.py loaddata /fixtures/smh.json

down:
	docker-compose down
