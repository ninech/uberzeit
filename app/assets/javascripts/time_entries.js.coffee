$(document).keyup (event) ->
  unless $("#time-modal").is(":visible")
    if event.which is 65 # 'a'
      $("a.button.add_time").first().click()
  return
