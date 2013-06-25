$(document)
  .foundation('reveal', {
    closeOnBackgroundClick: false
  })
  .foundation('tooltips')

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

# ===> Document Ready
$ ->

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

    picker_from_element = $('.from_to_date').find('input.from_date')
    picker_to_element = $('.from_to_date').find('input.to_date')

    picker_from = $(picker_from_element).pickadate
      onSet: () ->
        selected_from_date = moment(@get('select', 'yyyy-mm-dd'))
        selected_from_date_array = [selected_from_date.year(), selected_from_date.month(), selected_from_date.date()]
        to_date = moment(picker_to_element.data('pickadate').get('select', 'yyyy-mm-dd'))

        # set the min value for the to date
        picker_to_element.data('pickadate').set('min', selected_from_date_array)

        # set the selected from date as to date, if needed
        if to_date.isBefore(selected_from_date) and picker_to_element.val().length > 0
          picker_to_element.data('pickadate').set('select', selected_from_date_array)

    picker_to = $(picker_to_element).pickadate
      onStart: () ->
        selected_from_date = moment(picker_from_element.pickadate().data('pickadate').get('select', 'yyyy-mm-dd'))
        selected_from_date_array = [selected_from_date.year(), selected_from_date.month(), selected_from_date.date()]
        @set 'min', selected_from_date_array

    # Set initial dates (to isolate Rails' locale from Pickadate locale)
    $("input[data-month]").each (i, date_input) ->
      date_input = $(date_input)
      pickadate = date_input.data('pickadate')
      if(pickadate)
        pickadate.set('select', date_input.data('year'),date_input.data('month'),date_input.data('day'))

  initControls()
