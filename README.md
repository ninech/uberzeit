# uberZeit

## Development

1. Sync users:

        rake uberzeit:sync:ldap

2. Load seeds:

        rake db:seed

3. Login with your email address (`shortname`@nine.ch)
4. Party!

5. If you are annoyed by the JS-Integration tests, disable the js tests:

        rspec spec -t ~js


## API

curl -v -H 'X-Auth-Token: YourSuperSecretToken' -X GET uberzeit.dev/api/ping
