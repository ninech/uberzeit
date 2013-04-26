$(document)
  .foundation('reveal', {
    closeOnBackgroundClick: false,
    opened: (e) ->
      if e.target.id == 'add-time-modal'
        $('#time_entry_from_time').val(moment().format('HH:mm'))
  })
  .foundation('tooltips')

# ===> Event Listeners
# Bind event listeneners OUTSIDE of $(document).ready (cf. Turbolinks Troubleshooting)
$(document).on 'click', '.toggle', (element) ->
  $('#' + $(this).data('toggle-target')).toggle()

$(document).on 'click', '.remote-reveal', (event) ->
  element = $('#' + $(this).data('reveal-id'))
  element.find('span.ajax-content').remove()
  content_element = element.append('<span class="ajax-content"></span>')
  content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
    init_pickdate()
    init_picktime()

$(document).on 'mouseover', '.has-tip', ->
    $(this).popover
      trigger: 'hover'
      content: $(this).data('tooltip')
      fadeSpeed: 0

# ===> Document Ready
$ ->

  window.init_picktime = () ->
    # Timepicker
    $('input.time').timepicker({
      dropdown: false,
      timeFormat: 'HH:mm'
    })

  window.init_picktime()

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
    $("input[data-month]").each (i, date_input) ->
      date_input = $(date_input)
      pickadate = date_input.data('pickadate')
      if(pickadate)
        pickadate.setDate(date_input.data('year'),date_input.data('month'),date_input.data('day'))

  init_pickdate()
