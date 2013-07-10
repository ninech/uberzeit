$ ->
  $('.api-show-token').click ->
    $toggler = $(this)
    $popup = $('.api-token-popup').clone()
    $popup.detach().appendTo 'body'
    $popup.show()
    $popup.css 'position', 'absolute'
    $popup.css 'left', $toggler.offset().left
    $popup.css 'top', $toggler.offset().top
    $toggler.hide()
    $('.token', $popup).hide()

    animatedAttributes = {
      fontSize: '400px'
      left: '50%'
      top: '50%'
      marginLeft: '-200px'
      marginTop: '-200px'
    }

    $popup.animate animatedAttributes, 500, 'swing', ->
      $('.token', $popup).show()

      $('html').one 'click', ->
        $toggler.show()
        $popup.remove()

      $popup.click (evt) ->
        evt.stopPropagation()
