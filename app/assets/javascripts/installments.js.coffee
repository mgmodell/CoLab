# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#Code for the basic slider-based page
window.isChanging = false
window.transactions = []
$(".slider").change ->
  console.log ( "Here!" )
  console.log ( evt )
  unless window.isChanging
    window.isChanging = true
    
    #Pull the values from the element
    newVal = parseInt($(this).val())
    oldVal = parseInt($(this).attr("oldValue"))
    
    #Figure out how many sliders we're working with here
    group_sliders = $(this).parents("div:first").find(".slider")
    slider_count = group_sliders.length
    other_slider_count = slider_count - 1
    
    #Conform the value to the number of elements over which we must
    #distribute our point total (other_slider_count)
    difference = newVal - oldVal
    if difference > 0
      newVal = Math.ceil(newVal / other_slider_count) * other_slider_count
    else newVal = Math.floor(newVal / other_slider_count) * other_slider_count  if difference < 0
    difference = newVal - oldVal
    
    #Set the new Value to the slider
    $(this).val newVal
    
    #
    point_change = difference / Math.abs(difference)
    window.transactions.push difference
    allocated_points = 0
    while Math.abs(allocated_points) < Math.abs(difference)
      i = 0
      while i < group_sliders.length
        if group_sliders[i] isnt this
          slider = group_sliders[i]
          sliderVal = parseInt($(slider).val())
          if not (point_change < 0 and sliderVal >= 0) or not (point_change > 0 and sliderVal <= 600)
            newVal = sliderVal - point_change
            $(slider).val newVal
            allocated_points += point_change
        i++
    i = 0
    while i < group_sliders.length
      curVal = parseInt($(group_sliders[i]).val())
      $(group_sliders[i]).attr "oldValue", curVal
      $(group_sliders[i]).val curVal
      $(group_sliders[i]).slider "refresh"
      i++
    window.isChanging = false


#Code for the basic grid-based page
updateTotals = ->
  fieldsToUpdate = $(".total")
  inputReady = true
  i = 0
  while i < fieldsToUpdate.length
    unless parseInt($(fieldsToUpdate[i]).val()) is 600
      $(fieldsToUpdate[i]).css "color", "red"
      inputReady = false
    else
      $(fieldsToUpdate[i]).css "color", "green"
    i++
  unless inputReady
    $("input:submit").button "disable"
  else
    $("input:submit").button "enable"
  $("input:submit").button "refresh"
$(':input[type="number"]').change ->
  behaviour = $(this).attr("behaviour")
  fieldsToUpdate = $("." + behaviour)
  i = 0
  total = 0
  while i < fieldsToUpdate.length
    total += parseInt($(fieldsToUpdate[i]).val())
    i++
  $("#" + behaviour + "_calc").val total
  updateTotals()

$(document).on "pagecreate", ->
  updateTotals( )
  $(".ui-slider-input").hide( )
