$ ->
  d = new Date()
  if d.getDate() == 14 && d.getMonth() == 1 # YES 1 is february in javascript
    $('.api-show-token').parent().css
      'height': '20px'
      'line-height': '30px'
    $('.api-show-token').css
      'width': '20px'
      'display': 'inline-block'
    $('.token').append('<p><em>Happy Valentines Day!</em></p>')

    pulse = ->
      $('.api-show-token').animate {fontSize: '20px'}, 100, 'swing', ->
        $('.api-show-token').animate {fontSize: '13px'}, 1000, 'swing'

    setInterval pulse, 2500


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
