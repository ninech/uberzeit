# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  $('#shared_time_type').on 'change', () ->
    selected = $(this).find('option:selected')
    type = selected.data('type')

    switch type
      when 'both', 'timewise'
        $('#date_entry_form').hide()
        $('#time_entry_form').show()
      when 'daywise'
        $('#date_entry_form').show()
        $('#time_entry_form').hide()

    $('#date_entry_time_type_id').val(selected.val())
    $('#time_entry_time_type_id').val(selected.val())
