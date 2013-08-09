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

  $('input[name="activity_billable_toggle"]').change ->
    ajax_indicator = $('<i class="icon-spinner icon-spin ajax-ownage">')
    $(this).after(ajax_indicator)
    update_activity $(this).data('action'), $(this).data('method'), { billable: $(this).is(':checked') }, =>
      ajax_indicator.replaceWith ->
        $('<i class="icon-ok green-tick">').delay(ACTIVITY_FADE_TIME).fadeOut()

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
