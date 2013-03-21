$ ->
  # calendar tooltips
  $('.has-click-tip').click (e) ->
    $('.popover').hide()
    e.preventDefault()
    e.stopPropagation()
    $(this).popover
      content: $(this).attr('title')
      trigger: 'click'
      hideOnHTMLClick: true
      stopChildrenPropagation: false
    .popover('show')

