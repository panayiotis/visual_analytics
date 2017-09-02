
$(document).on 'turbolinks:load', ->
  if $('#presentation2').length > 0
    #$('body').css('min-width', '100px')
    if $('#presentation-switch input').first().prop('checked')
      console.log 'turn notes on'
      $('.notes').show()
    else
      $('.notes').hide()
      console.log 'turn notes off'

    $('#presentation-switch').change (event)->
      if event.target.checked
        console.log 'turn notes on'
        $('.notes').fadeIn()
      else
        $('.notes').fadeOut()
        console.log 'turn notes off'

    $(document).find('#presentation2').not('.fullpage-wraper')
      .fullpage
        sectionsColor: [
          ''
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
        ],
        navigation: true,
        navigationPosition: 'right',
        navigationTooltips: [
          'Title'
          'Team'
          'Problem'
          'Solution'
          'Job demand analysis'
          'Job supply analysis'
          'Mobility'
          'Technology'
          'Pipeline'
        ],
        anchors: [
          'title'
          'team'
          'problem'
          'solution'
          'job-demand-analysis'
          'job-supply-analysis'
          'mobility'
          'technology'
          'pipeline'
        ]

    start=Math.floor(new Date() / 1000)

    $('#presentation-timer').click (event)->
      $('#presentation-timer').html 'reset'
      start=Math.floor(new Date() / 1000)

    #console.log new Date() - start

    setInterval ->
      now= Math.floor(new Date() / 1000)
      min=Math.floor((now - start)/60)
      sec=(now - start)%60
      if now - start > 0
        if min == 0
          $('#presentation-timer').html sec
        else
          $('#presentation-timer').html min+":"+sec
    ,1000

    PresentationVisualizations.cluster2 '#big-data-processing-engine-vis'
    
    MobilityVisualization.draw('#mobility-sankey')
    Map.summary_map '#summary-map', '/spark/2/data.csv', cedefop_names_map, 'jobsupply'

    Map.summary_map '#mobility-map', '/solr.json', eures_names_map, 'jobdemand'



$(document).on 'turbolinks:load', ->
  if $('#presentation3').length > 0
    #$('body').css('min-width', '100px')
    if $('#presentation-switch input').first().prop('checked')
      console.log 'turn notes on'
      $('.notes').show()
    else
      $('.notes').hide()
      console.log 'turn notes off'

    $('#presentation-switch').change (event)->
      if event.target.checked
        console.log 'turn notes on'
        $('.notes').fadeIn()
      else
        $('.notes').fadeOut()
        console.log 'turn notes off'

    $(document).find('#presentation3').not('.fullpage-wraper')
      .fullpage
        sectionsColor: [
          ''
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
          '#eeeeee'
        ],
        navigation: true,
        navigationPosition: 'right',
        navigationTooltips: [
          'Title'
          'Problem'
          'Solution'
          'Advantages'
          'Prototype'
        ],
        anchors: [
          'title'
          'problem'
          'solution'
          'advantages'
          'prototype'
        ]

    start=Math.floor(new Date() / 1000)

    $('#presentation-timer').click (event)->
      $('#presentation-timer').html 'reset'
      start=Math.floor(new Date() / 1000)

