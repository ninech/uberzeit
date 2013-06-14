# uberZeit

## Development

1. Sync users:

        rake uberzeit:sync:ldap

2. Load seeds:

        rake db:seed

3. Login with your email address (`shortname`@nine.ch)
4. Party!


## API

curl -v -H 'X-Auth-Token: YourSuperSecretToken' -X GET uberzeit.dev/api/ping
