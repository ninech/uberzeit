$(document)
  .foundation('reveal', { closeOnBackgroundClick: false })

$ ->
  $('input.time').timepicker({
    dropdown: false,
    timeFormat: 'HH:mm'
  })

  $('.toggle').on 'click', (element) ->
    $('#' + $(this).data('toggle-target')).toggle()

  $('.has-click-tip').tooltipster
    interactive: true
    position: 'bottom'
    fixedWidth: 300
    speed: 250

  window.init_pickdate = () ->
    $('input.date').pickadate
      format: 'yyyy-mm-dd'

  init_pickdate()
