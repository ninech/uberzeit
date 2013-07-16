do ($ = jQuery) ->
  customerChanged = ->
    project_select = $('#activity_project_id')
    project_select_row = project_select.closest('div.row')
    customer_id = $('#activity_customer_id').val()
    if customer_id
      console.info('Nuclear launch detected!')
      $.getJSON '/api/customers/' + customer_id + '/projects/', (projects) ->
        project_select.empty()
        if projects.length
          project_select_row.show()
          $.each projects, (index, project) ->
            option = $('<option>').attr('value', project.id).text(project.name)
            project_select.append(option)
        else
          project_select_row.hide()


  $(document).on 'change', '#activity_customer_id', customerChanged
