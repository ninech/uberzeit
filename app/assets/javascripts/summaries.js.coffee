$ ->
  $('#summary_header_submit').click ->
    summary_type = $('#summary_type').val()
    team_id = $('#team').val()
    year = $('#date_year').val()
    month = $('#date_month').val()
    append_to_url = $('#append_to_url').val()

    base_url =  $('#base_url').val()
    url = base_url.replace(':year', year)
    if month
      url = url + '/:month'.replace(':month', month)
    if team_id
      url = url + '/team/:team_id'.replace(':team_id', team_id)

    url = url + append_to_url

    window.location = url

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
        $('<i class="icon-ok green-tick">').delay(500).fadeOut()

  $('form[name=activity_billability]').submit ->
    # disable submit button
    $(this).find('input[type=submit]').hide()
    activities = $(this).find('input[name="activity_billable_toggle"]')
    activities.attr('disabled', 'disabled')
    activities.each (index, element) =>
      update_activity $(element).data('action'), $(element).data('method'), { locked: true }, =>
        $(element).closest('tr').fadeTo(500, 0.5)

    #$(this).closest('.customer-ok').removeClass('hidden')
    console.log $(this).closest('section').find('.customer-ok').removeClass('hidden')

    false # do not submit
