# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  $(document).on 'click', '.remote-reveal', () ->
    element = $('#' + $(this).data('reveal-id'))
    element.find('span.ajax-content').remove()
    content_element = element.append('<span class="ajax-content"></span>')
    content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
      $('.date').pickadate()
