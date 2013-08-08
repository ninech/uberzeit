$ ->
  $("#summary_header_submit").click ->
    summary_type = $("#summary_type").val()
    team_id = $("#team").val()
    year = $("#date_year").val()
    month = $("#date_month").val()
    append_to_url = $("#append_to_url").val()

    base_url =  $("#base_url").val()
    url = base_url.replace(':year', year)
    if month
      url = url + '/:month'.replace(':month', month)
    if team_id
      url = url + '/team/:team_id'.replace(':team_id', team_id)

    url = url + append_to_url

    window.location = url

  $('input[name="activity_billable_toggle"]').change ->
    $.ajax
      type: $(this).data('method')
      url: $(this).data('action')
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify
        activity:
          billable: $(this).is(':checked')
      error: (xhr, status, error) ->
        alert error
