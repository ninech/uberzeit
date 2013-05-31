$ ->
  timedCount = (element, counter, interval, end, timeout) ->
    if counter <= parseFloat(end)
      counter = counter + interval
      setTimeout timedCount, timeout, element, counter, interval, end, timeout
    else
      counter = parseFloat(end)
    decimal_places = 1
    decimal_places = 0  if parseFloat(end) % 1 is 0
    suffix = ""
    suffix = "%"  if end.toString().indexOf("%") >= 0
    element.html counter.toFixed(decimal_places) + suffix
  $("[data-count-from][data-count-to]").each (index, element) ->
    element = $(element)
    start = element.data("count-from")
    end = element.data("count-to")
    timeout = element.data("count-timeout")
    timeout = 20  if timeout is `undefined`
    interval = parseFloat(end) / 90
    counter = parseFloat(start)
    element.html start
    timedCount element, counter, interval, end, timeout

