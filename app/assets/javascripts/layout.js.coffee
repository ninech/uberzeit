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


    createDateArray = (date) ->
      date.split('-').map (value) ->
        + value

    picker_from_element = $('.from_to_date').find('input.from_date')
    picker_to_element = $('.from_to_date').find('input.to_date')

    picker_from = $(picker_from_element).pickadate
      onSelect: () ->
        fromDate = createDateArray(this.getDate('yyyy-mm-dd'))
        picker_to.data('pickadate').setDateLimit(fromDate)

        from_moment = moment(this.getDate(true))
        to_moment = moment(picker_to.data('pickadate').getDate(true))

        if to_moment.isBefore(from_moment)
          picker_to.data('pickadate').setDate(from_moment.year(), from_moment.months() + 1, from_moment.date())

    picker_to = $(picker_to_element).pickadate
      onStart: () ->
        fromDate = createDateArray(picker_from.data('pickadate').getDate('yyyy-mm-dd'))
        this.setDateLimit(fromDate)


  init_pickdate()


  # Ajax modals / reveal
  $(document).on 'click', '.remote-reveal', () ->
    element = $('#' + $(this).data('reveal-id'))
    element.find('span.ajax-content').remove()
    content_element = element.append('<span class="ajax-content"></span>')
    content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
      init_pickdate()
