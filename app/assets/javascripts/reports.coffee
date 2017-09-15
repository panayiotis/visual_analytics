# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

interact('.resizable')
.draggable(onmove: window.dragMoveListener)
.resizable(
  preserveAspectRatio: false
  axis:'x'
  edges:
    left: false
    right: true
    bottom: false
    top: false)
.on 'resizemove', (event) ->
  target = event.target
  width = event.rect.width + 'px'

  # update the element's style
  target.style.width = width

  # update the position of the fixed reset button
  document.getElementById('fixed-reset-button').style.left = width
.on 'resizeend', (event) ->

  # send a window resize event so charts rerender themselves
  window.dispatchEvent new Event('resize')
