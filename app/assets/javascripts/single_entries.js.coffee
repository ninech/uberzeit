# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  update_single_entry_form()

  if !!$("#single_entry_start_time").val()
    start = $("#single_entry_start_time").val().split(' ')
    $("input.start.date").val(start[0])
    $("input.start.time").val(start[1])
    $("input.start.date").datepicker('update') # for datepicker
    $("input.start.time, input.start.date").trigger('change') # for datepair

  if !!$("#single_entry_end_time").val()
    end = $("#single_entry_end_time").val().split(' ')
    $("input.end.date").val(end[0])
    $("input.end.time").val(end[1])
    $("input.end.date").datepicker('update') # for datepicker
    $("input.end.time, input.end.date").trigger('change') # for datepair

  $("form").submit ->
    # TODO
    # Picker DateFormat
    # Ferientyp, WholeDay Checks etc.
    start_time = $("input.start.time").val()
    start_date = $("input.start.date").val()
    end_time = $("input.end.time").val()
    end_date = $("input.end.date").val()

    $("#single_entry_start_time").val("#{start_date} #{start_time}")
    $("#single_entry_end_time").val("#{end_date} #{end_time}")

  $("#single_entry_whole_day").change -> update_single_entry_form()

update_single_entry_form = () ->
  console.log($("#single_entry_whole_day").is(':checked'))
  if $("#single_entry_whole_day").is(':checked')
    $('input.end.time, input.start.time, .to').hide()
  else
    $('input.end.time, input.start.time, .to').show()