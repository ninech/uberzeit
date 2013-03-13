$ ->
  $('#time_entry_start_date').pickadate({
    monthsFull: [ 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember' ],
    monthsShort: [ 'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez' ],
    weekdaysFull: [ 'Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag' ],
    weekdaysShort: [ 'So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa' ],
    today: 'Heute',
    clear: 'Löschen',
    firstDay: 1,
    format: 'dddd, dd. mmmm yyyy',
    formatSubmit: 'yyyy-mm-dd'
    hiddenSuffix: ''
  })

  $('#time_entry_to_time').bind 'keyup', ->
    startEl = $('#time_entry_from_time')
    endEl   = $('#time_entry_to_time')

    if endEl.val()
      $('#time_entry_submit').val('Add Entry')
    else
      $('#time_entry_submit').val('Add Timer')


    startValue = $.fn.timepicker.parseTime startEl.val()
    endValue   = $.fn.timepicker.parseTime endEl.val()

    if startValue and endValue
      start = startEl.timepicker().format(startValue)
      end   = endEl.timepicker().format(endValue)

      diffHours = moment.duration(moment(end, 'HH:mm').diff(moment(start, 'HH:mm'))).hours()
      diffMinutes = moment.duration(moment(end, 'HH:mm').diff(moment(start, 'HH:mm'))).minutes()
      console.log 'diffHours', diffHours

      if diffHours < 0
        diffHours = 23 - diffHours * -1

      if diffMinutes < 0
        diffMinutes = diffMinutes * -1

      console.log diffHours, diffMinutes

      if diffHours < 10
        diffHours = "0#{diffHours}"

      if diffMinutes < 10
        diffMinutes = "0#{diffMinutes}"

      value = "#{diffHours}:#{diffMinutes}"
    else
      value = ""

    $('.time-difference').html(value)
