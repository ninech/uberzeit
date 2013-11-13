do($ = jQuery) ->
  $ ->
    resource_select = $('#user_role_resource')
    if resource_select.length
      do ->
        role_select = $('#user_role_role')
        role_changed = () ->
          resource_select.closest('div.row')[if role_select.val() in role_select.data('resourcable-roles') then 'show' else 'hide']()
        role_changed()
        role_select.on('change', role_changed)

