## Spin up verify my identity

`docker-compose up -d verifymyidentity vmi_db`

`docker-compose exec verifymyidentity python manage.py migrate`

modify your `/etc/hosts` file such that there is a line that looks like the following.

```
127.0.0.1       verifymyidentity
```



Now a user and oauth application needs to be setup in verifymyidentity. For the purposes of this readme the user that owns the application and the user we'll use throughout the rest of the system will be the same, this is just for simplicity and _does not_ have to be the case.

Go to [verifymyidentity](http://verifymyidentity:8001) in the browser of your choice. Click signup and create an account. 



## Spin up share my health

Share my health needs application credentials from verify my identity so that it can use vmi as it's identity provider.

To do this [register an application](http://verifymyidentity:8001/o/applications/register/) for share my health on verify my identity. Set the redirect url to `http://sharemyhealth:8000/social-auth/complete/verifymyidentity-openidconnect/`. Click save and copy the values from `Client id` and `Client secret` into the `VMI_KEY` and `VMI_SECRET` variables in the `.env` respectively.

Now smh is ready to be spun up.

`docker-compose up -d sharemyhealth smh_db`

`docker-compose exec sharemyhealth python manage.py migrate`

modify your `/etc/hosts` file such that the line you created before looks like the following.



```
127.0.0.1       verifymyidentity sharemyhealth
```



You should now be able to point a browser at [sharemyhealth](http://sharemyhealth:8000) and login with the credentials you created earlier. *magic*



## Spin up smh_app

This system depends on the previous two systems. It uses VMI as an identity provider, and SMH as a resource for data. Those are both oauth (well VMI is oidc but oauth's a superset) so this system needs to register itself in both VMI and SMH.

[Register an application with VMI](http://verifymyidentity:8001/o/applications/register/) and set the redirect url to `http://sharemyhealthapp:8002/social-auth/complete/vmi/`. Click save and copy the values from `Client id` and `Client secret` into the `APP_VMI_KEY` and `APP_VMI_SECRET` variables in the `.env` respectively.

[Register an application with SMH](http://sharemyhealth:8000/o/applications/register/) and set the redirect url to `http://sharemyhealthapp:8002/social-auth/complete/sharemyhealth/`. Click save and copy the values from `Client id` and `Client secret` into the `SMH_KEY` and `SMH_SECRET` variables in the `.env` respectively.

Now smh_app is ready to be spun up.

`docker-compose up -d sharemyhealth_app smh_app_db`

`docker-compose exec sharemyhealth_app python manage.py migrate`

modify your `/etc/hosts` file such that the line you created before looks like the following.

```
127.0.0.1       verifymyidentity sharemyhealth sharemyhealthapp
```

Make sure that nodejs is available in your environment and build the static assets for smh_app:

	cd smh_app/assets
	make build

You can now go to [sharemyhealthapp](http://sharemyhealthapp:8002) and login. Once logged in you can [connect share my health as a data source](http://sharemyhealthapp:8002/resources/).

## Trouble shooting

Often an app server can be spun up before it's db is ready by docker compose. So try `docker-compose restart <verifymyidentity, sharemyhealth, sharemyhealth_app>` .