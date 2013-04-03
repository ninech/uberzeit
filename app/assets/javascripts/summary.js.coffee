$ ->
  $(document).on 'mouseover', '.content-summary .has-tip', ->
    $(this).popover
      trigger: 'hover'
      content: $(this).data('tooltip')
      fadeSpeed: 0
