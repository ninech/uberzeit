$ ->
  ACTIVITY_FADE_TIME          = 500
  ACTIVITY_FADE_TO_OPACITY    = 0.5

  update_activity = (action, method, activity, success) ->
    $.ajax
      url: action
      type: method
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify
        activity: activity
      error: (xhr, status, error) ->
        alert error
      success: success

  update_activity_sum = (sum_element) ->
    type = $(sum_element).data('activity-sum-type')
    customer = $(sum_element).data('activity-sum-customer')
    activity = $(sum_element).data('activity-sum-activity')

    filter_billable = $(sum_element).data('activity-sum-only-billable')
    hide_zero = $(sum_element).data('activity-sum-hide-zero')

    duration_elements = $("[data-activity-duration]")
    if type?
      duration_elements = duration_elements.filter("[data-activity-type=#{type}]")
    if customer?
      duration_elements = duration_elements.filter("[data-activity-customer=#{customer}]")
    if activity?
      duration_elements = duration_elements.filter("[data-activity=#{activity}]")

    sum = 0
    duration_elements.each (index, duration_element) ->
      activity_id = $(duration_element).data('activity')
      effective_duration = $(duration_element).data('activity-duration')
      billable = $("input[name=activity_billable_toggle][data-activity=#{activity_id}]").is(":checked")
      sum += effective_duration if !filter_billable? || (filter_billable? && billable)

    $(sum_element).text window.formatDuration(sum)
    $(sum_element).show()
    $(sum_element).hide() if hide_zero? && sum == 0

  update_activity_sums = ->
    $('[data-activity-sum-durations]').each (index, element) ->
      update_activity_sum element

  $('input[name=activity_billable_toggle]').change ->
    ajax_indicator = $('<i class="icon-spinner icon-spin">')
    $(this).after(ajax_indicator)
    update_activity $(this).data('action'), $(this).data('method'), { billable: $(this).is(':checked') }, =>
      ajax_indicator.replaceWith ->
        $('<i class="icon-ok green-tick">').delay(ACTIVITY_FADE_TIME).fadeOut()

    update_activity_sums()

  $('form[name=activity_billability]').submit ->
    # disable submit button
    $(this).find('input[type=submit]').hide()
    activities = $(this).find('input[name="activity_billable_toggle"]')
    activities.attr('disabled', 'disabled')
    activities.each (index, element) =>
      update_activity $(element).data('action'), $(element).data('method'), { locked: true }, =>
        $(element).closest('tr').fadeTo(ACTIVITY_FADE_TIME, ACTIVITY_FADE_TO_OPACITY)

    section = $(this).closest('section')
    section.find('.customer-status').append('<i class="icon-ok green-tick">')
    section.find('.customer-title').fadeTo(ACTIVITY_FADE_TIME, ACTIVITY_FADE_TO_OPACITY)

    false # do not submit

  update_activity_sums()
