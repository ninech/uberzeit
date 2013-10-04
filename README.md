# uberZeit

## Rules

### Planned Working Time

* Is calculated by summing up `Day`s.planned_working_time

### Worktime

* Is calculated by summing up `TimeSpan`s.duration
* Only sum `TimeSpan`s which have a `TimeType` with the following settings:
** `exclude_from_calculation: true`

### Absence

* Is calculated by summing up `TimeSpan`s.credited_duration
* Exclude `TimeSpan`s which belong to an `Adjustment` and its `TimeType.is_vacation` is true
* Exclude `TimeSpan`s which have a `TimeType` with the following settings:
** `is_work: true`


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
