do ($ = jQuery) ->
  addOption = (select, value, text) ->
    option = $('<option>').attr('value', value).text(text)
    select.append(option)

  customerChanged = ->
    project_select = $('#activity_project_id')
    project_select_row = project_select.closest('div.row')
    customer_id = $('#activity_customer_id').val().match(/\d+/)?[0]
    if customer_id
      console.info('Nuclear launch detected!')
      $.getJSON '/api/customers/' + customer_id + '/projects/', (projects) ->
        project_select.empty()
        if projects.length
          project_select_row.show()
          addOption(project_select, '', '-')
          $.each projects, (index, project) ->
            addOption(project_select, project.id, project.name)
        else
          project_select_row.hide()

  $(document).on 'typeahead:selected', '#activity_customer_id', customerChanged
  $(document).bind 'modal:activity-modal:form-loaded', (event) =>
    initTypeAhead()
