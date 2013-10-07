# uberZeit

## Rules

### Planned Working Time

* Is calculated by summing up `Day`s.planned_working_time

### Effective Work Time

This is the real time which a user has spent working.

* Sum up all `TimeSpan`s which belong to a `TimeType` which has `is_work` = `true`

### Worktime

This is the time which will be compared to the planned working time to
determine the overtime.

* Is calculated by summing up `TimeSpan`s.credited_duration

### Absence

* Is calculated by summing up `TimeSpan`s.credited_duration
* Only sum `TimeSpans` of `Absence` and `Adjustment`
* Exclude `Adjustment` which belongs to a `TimeType` with `is_vacation` = `true`

### Vacation

#### Total days which a user can redeem

* `UberZeit.config[:vacation_per_year]` adjusted by
  * the workload of the `User`s `Employment` during the year
  * `TimeSpan`s which belong to an `Adjustment` and its `TimeType.is_vacation` is `true`

#### Redeemed Vacation days

* `TimeSpan` which belong to an `Absence` and `TimeType.is_vacation` is `true`

#### Not yet redeemed Vacation days

* Total of the vacation days minus redeemed vacation days

### Bonus

* Sum up all `TimeSpan`s.duration_bonus

### Overtime

* Worktime minus Planned Working Time

### Adjustment

* Sum up all `TimeSpan`s which belong to an `Adjustment`

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
