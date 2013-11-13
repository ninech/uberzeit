do ($ = jQuery) ->
  $ ->
    chartContainer = $('.content-comparison #chart')
    if chartContainer.length
      data = [
        {
          key: I18n.t('comparison.show.chart.time_entries')
          color: '#009AD7'
          values: chartContainer.data('time-entries')
        },
        {
          key: I18n.t('comparison.show.chart.activities')
          color: '#66717E'
          values: chartContainer.data('activities')
        }
      ]
      nv.addGraph ->
        chart = nv.models.multiBarChart().x((d) ->
          d[0]
        ).y((d) ->
          d[1]
        ).forceY([0, 8.5])

        chart.xAxis.tickFormat (d) ->
          d3.time.format("%a, %d") new Date(d)

        chart.reduceXTicks false
        chart.showControls false

        chart.margin({right: 40})

        chart.yAxis.tickFormat (d) ->
          f = d3.format("02")
          h = Math.floor(d)
          m = Math.round((d - h) * 60)
          f(h) + ":" + f(m)

        d3.select("#chart svg").datum(data).transition().duration(500).call chart
        nv.utils.windowResize chart.update
        return chart
