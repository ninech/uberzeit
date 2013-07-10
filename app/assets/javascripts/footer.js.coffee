$ ->
  $('.api-show-token').click ->
    $toggler = $(this)
    $toggler.css 'visibility', 'hidden'

    $popup = $('.api-token-popup').clone()
    $popup.detach().appendTo 'body'
    $popup.show()
    $popup.css
      position: 'absolute'
      left: $toggler.offset().left
      top: $toggler.offset().top

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
        $toggler.css 'visibility', ''
        $popup.remove()

      $popup.click (evt) ->
        evt.stopPropagation()
