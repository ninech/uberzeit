$(document)
  .foundation('reveal', { closeOnBackgroundClick: false })

$ ->

  # Timepicker
  $('input.time').timepicker({
    dropdown: false,
    timeFormat: 'HH:mm'
  })


  # Toggler
  $(document).on 'click', '.toggle', (element) ->
    $('#' + $(this).data('toggle-target')).toggle()


  # Tooltip
  $('.has-click-tip').tooltipster
    interactive: true
    position: 'bottom'
    fixedWidth: 300
    speed: 250


  # Pickadate
  window.init_pickdate = () ->
    $('input.date').pickadate
      format: 'yyyy-mm-dd'

  init_pickdate()


  # Ajax modals / reveal
  $(document).on 'click', '.remote-reveal', () ->
    element = $('#' + $(this).data('reveal-id'))
    element.find('span.ajax-content').remove()
    content_element = element.append('<span class="ajax-content"></span>')
    content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
      init_pickdate()
