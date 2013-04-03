$(document)
  .foundation('reveal', {
    closeOnBackgroundClick: false,
    opened: (e) ->
      if e.target.id == 'add-time-modal'
        $('#time_entry_from_time').val(moment().format('HH:mm'))
  })
  .foundation('tooltips')

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

    $('input.date').pickadate()

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

        if to_moment.isBefore(from_moment) && picker_to.not(":empty")
          picker_to.data('pickadate').setDate(from_moment.year(), from_moment.months() + 1, from_moment.date())

    picker_to = $(picker_to_element).pickadate
      onStart: () ->
        fromDate = createDateArray(picker_from.data('pickadate').getDate('yyyy-mm-dd'))
        this.setDateLimit(fromDate)

    # Set initial dates (to isolate Rails' locale from Pickadate locale)
    pickadate_from = picker_from.data('pickadate')
    if(pickadate_from && picker_from.data('year'))
      pickadate_from.setDate(picker_from.data('year'),picker_from.data('month'),picker_from.data('day'))

    pickadate_to = picker_to.data('pickadate')
    if(pickadate_to && picker_to.data('year'))
      pickadate_to.setDate(picker_to.data('year'),picker_to.data('month'),picker_to.data('day'))

  init_pickdate()

  # Ajax modals / reveal
  $(document).on 'click', '.remote-reveal', () ->
    element = $('#' + $(this).data('reveal-id'))
    element.find('span.ajax-content').remove()
    content_element = element.append('<span class="ajax-content"></span>')
    content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
      init_pickdate()
