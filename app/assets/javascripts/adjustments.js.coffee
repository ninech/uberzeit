# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  update_adjustment_form = () ->
    is_absence = $(':selected', '#adjustment_time_type_id').data('is-absence')
    if is_absence
      $('.row.hours').hide()
      $('input', '.row.hours').attr('disabled','disabled')
      $('.row.work-days').show()
      $('input', '.row.work-days').removeAttr('disabled')
    else
      $('.row.work-days').hide()
      $('input', '.row.work-days').attr('disabled','disabled')
      $('.row.hours').show()
      $('input', '.row.hours').removeAttr('disabled')

  $('#adjustment_time_type_id').change () ->
    update_adjustment_form()

  update_adjustment_form()
