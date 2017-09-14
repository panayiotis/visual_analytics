window.loading =
  start: (msg) ->
    $('#loading-wrapper').remove()
    $('body').prepend(
      "<div id='loading-wrapper'>
      <p class='loading-message'>#{msg}</p>
      <div id='loading'></div>
      </div>"
    )
  stop: ->
    $('#loading-wrapper').remove()
