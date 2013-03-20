$(document)
  .foundation('reveal', { closeOnBackgroundClick: false })
  .foundation('tooltips')

$ ->
  $('input.time').timepicker({
    dropdown: false,
    timeFormat: 'HH:mm'
  })

  $('input.date').pickadate
    format: 'yyyy-mm-dd'

  $('.toggle').on 'click', (element) ->
    $('#' + $(this).data('toggle-target')).toggle()
