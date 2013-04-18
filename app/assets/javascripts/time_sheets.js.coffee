$ ->

  # global functions
  window.timeDiff = (start_time, end_time, start_date, end_date, countdown = true) ->
    if typeof start_date == 'undefined'
      start_date = moment().format('YYYY-MM-DD')

    if typeof end_date == 'undefined'
      end_date = moment().format('YYYY-MM-DD')


    start = moment("#{start_date} #{start_time}")
    end   = moment("#{end_date} #{end_time}")

    if start >= end && countdown == false
      end.add('days', 1)

    diffHours = Math.floor(moment.duration(end.diff(start)).asHours())
    diffMinutes = moment.duration(end.diff(start)).minutes()
    prefix = ""

    if diffHours < 0
      diffHours = diffHours * -1
      prefix = "−"

    if diffMinutes < 0
      diffMinutes = diffMinutes * -1
      prefix = "−"

    if diffHours < 10
      diffHours = "0#{diffHours}"

    if diffMinutes < 10
      diffMinutes = "0#{diffMinutes}"

    "#{prefix}#{diffHours}:#{diffMinutes}"


  window.updateTimes = ->
    $.getJSON $('.ajax.time').attr('href'), (data) ->
      $('.time.active').text data.time

    $.getJSON $('.ajax.timer').attr('href'), (data) ->
      $('.timer-current').text data.timer
      # disable stop timer link if there is no timer duration (e.g. timer in future)
      if $('.timer-current').text() == "00:00"
        $('.stop-timer').addClass 'disabled'
        $('.stop-timer').bind 'click', (e) ->
          e.preventDefault()
          false
      else
        $('.stop-timer').removeClass 'disabled'
        $('.stop-timer').unbind 'click'


  # on page load
  updateTimes()
  if $('.timer-current').length > 0 && window.timerStarted != true
    window.timerStarted = true
    setTimeout((->
      updateTimes()
      setTimeout arguments.callee, 30000
      ), 0)

  # summary
  $('.unhider').click ->
    $('.' + $(this).data('hide-class')).hide()
    $('.' + $(this).data('unhide-class')).show()
    false

  # events
  $(document).on 'keyup', '.reveal-modal.time form #time_entry_to_time, .reveal-modal.time form #time_entry_from_time', ->
    form_id = "#" + $(this).parents('form').attr('id')
    startEl = $("#{form_id} #time_entry_from_time")
    endEl   = $("#{form_id} #time_entry_to_time")

    unless $("#{form_id} #time_entry_submit").val() == I18n.t('time_entries.form.save')
      if endEl.val()
        $("#{form_id} #time_entry_submit").val(I18n.t('time_entries.form.add_entry'))
      else
        $("#{form_id} #time_entry_submit").val(I18n.t('time_entries.form.start_timer'))

    startValue = $.fn.timepicker.parseTime startEl.val()
    endValue   = $.fn.timepicker.parseTime endEl.val()

    if startValue and endValue
      start = startEl.timepicker().format(startValue)
      end   = endEl.timepicker().format(endValue)

      value = timeDiff(start, end, undefined, undefined, false)
    else
      value = ""

    $("#{form_id} .time-difference").html(value)

  $('.reveal-modal.time form').on 'ajax:error', (xhr, status, error) ->
    console.log xhr, status, error

  $(document).on 'ajax:success', '.reveal-modal.time form', (data, status, xhr) ->
    $(this).foundation('reveal', 'close')
    Turbolinks.visit(window.location)

  $('.stop-timer').bind 'click', ->
    unless $('.stop-timer').hasClass 'disabled'
      $('.stop-timer i').removeClass('icon-spin')

  $('.stop-timer').bind 'ajax:complete', (xhr, status) ->
    Turbolinks.visit(window.location)

  $('.delete-time-entry-link').bind 'ajax:complete', (xhr, status) ->
    Turbolinks.visit(window.location)

  $('.entries ul li').hover (->
    $(this).find('a.edit-time-entry-link').show()
  ), ->
    $(this).find('a.edit-time-entry-link').hide()
