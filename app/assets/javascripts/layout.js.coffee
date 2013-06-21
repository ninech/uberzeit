# ===> Event Listeners
$(document).on 'click', '.toggle', (element) ->
  $('#' + $(this).data('toggle-target')).toggle()

$(document).on 'click', '.remote-reveal', (event) ->
  element = $('#' + $(this).data('reveal-id'))
  element.find('div.ajax-content').remove()
  content_element = element.append('<div class="ajax-content"></div>')
  content_element.find('div.ajax-content').load $(this).data('reveal-url')

$(document).ajaxComplete () ->
  initControls()

$(document).ajaxError () ->
  initControls()

$(document).on 'mouseover', '.has-tip', ->
    $(this).popover
      trigger: 'hover'
      content: $(this).data('tooltip')
      fadeSpeed: 0

# Hacky hack
# Foundation adds styles to a functional class (close-reveal-modal)
# Adding the class to the button messes up with the style, cf. https://github.com/zurb/foundation/pull/1381
# Use a custom css class to work around
$(document).on 'click', '.close-reveal-modal-button', (event) ->
  $(this).closest(".reveal-modal").foundation "reveal", "close"
  false

# ===> Document Ready
$ ->
  $(document)
    .foundation('reveal')
    .foundation('tooltips')

  window.initControls = () ->
    initTimePicker()
    initDatePicker()

  window.initTimePicker = () ->
    # Timepicker
    $('input.time').timepicker({
      dropdown: false,
      timeFormat: 'HH:mm'
    })

  # Pickadate
  window.initDatePicker = () ->

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

        if to_moment.isBefore(from_moment) && picker_to.val().length > 0
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

  initControls()
