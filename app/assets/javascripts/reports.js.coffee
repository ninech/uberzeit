$ ->
  $('#summary_header_submit').click ->
    customer = $('#customer').val()
    summary_type = $('#summary_type').val()
    team_id = $('#team').val()
    group_by = $('#group_by').val()
    year = $('#date_year').val()
    month = $('#date_month').val()
    date = $('input[type=hidden][name=date]').val()
    append_to_url = $('#append_to_url').val()

    base_url =  $('#base_url').val()
    url = base_url.replace(':year', year)
    if month
      url = url + '/:month'.replace(':month', month)
    if team_id
      url = url + '/team/:team_id'.replace(':team_id', team_id)
    if group_by
      url = url + '/:group_by'.replace(':group_by', group_by)
    if customer
      url = url + '/:customer_id'.replace(':customer_id', customer.match(/\d+/)?[0])
    if date
      url = url + '/:date'.replace(':date', date)

    url = url + append_to_url

    window.location = url
