$(document).on 'keydown', 'input:not(.from_date, .to_date, .date, .tt-query)', (event) ->
  if event.which == 13
    event.preventDefault()
    $(event.target).closest('form').submit()
