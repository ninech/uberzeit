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


  # Pickadate
  window.init_pickdate = () ->
    $('input.date').pickadate
      format: 'yyyy-mm-dd'

    picker_from = $('.from_to_date').find('input.from_date').pickadate
      onSelect: () ->
        console.log this
        date = createDateArray(this.getDate('yyyy-mm-dd'))
        picker_to.data('pickadate').setDateLimit(date)

    picker_to = $('.from_to_date').find('input.to_date').pickadate
      onSelect: () ->
        date = createDateArray(this.getDate('yyyy-mm-dd'))
        picker_from.data('pickadate').setDateLimit(date)

    createDateArray = (date) ->
      date.split( '-' ).map (value) ->
        + value

  init_pickdate()


  # Ajax modals / reveal
  $(document).on 'click', '.remote-reveal', () ->
    element = $('#' + $(this).data('reveal-id'))
    element.find('span.ajax-content').remove()
    content_element = element.append('<span class="ajax-content"></span>')
    content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
      init_pickdate()
