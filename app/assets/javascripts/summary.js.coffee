$ ->
  $('.has-tip').hover (e) ->
    $(this).popover
      trigger: 'hover'
      content: $(this).data('tooltip')
      fadeSpeed: 0
