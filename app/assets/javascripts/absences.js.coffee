# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  $('[data-reveal-id=add-absence-modal]').on 'click', () ->
    $('#add-absence-modal span.ajax-content').remove()
    content_element = $('#add-absence-modal').append('<span class="ajax-content"></span>')
    content_element.find('span.ajax-content').load $(this).data('reveal-url'), () ->
      $('.date').pickadate()
