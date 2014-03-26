$ ->
  # calendar tooltips
  $('.has-click-tip').click (e) ->
    $('.popover').hide()
    e.preventDefault()
    e.stopPropagation()
    $(this).popover
      content: $(this).data('tooltip')
      trigger: 'click'
      hideOnHTMLClick: true
      stopChildrenPropagation: false,
      afterInit: (e) ->
        e.data('popover').popover.click (event) ->
          unless $(event.target).is('a')
            event.stopPropagation()
    .popover('show')

  $('[data-add-absence-url]').css('cursor', 'pointer')
  $('[data-add-absence-url]').click (e) ->
    self.location.href = $(this).data('add-absence-url')
