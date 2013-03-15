$(document)
  .foundation('reveal', { closeOnBackgroundClick: false })

$ ->
  $('input.time').timepicker({
    dropdown: false,
    timeFormat: 'HH:mm'
  })

  $('input.date').pickadate
    format: 'yyyy-mm-dd'

