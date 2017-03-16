$(document).ready ->
  $('#basicTable').tablesorter sortList: [
    [
      0
      0
    ]
    [
      1
      0
    ]
  ]
  return

#This code works for sliders only
window.isChanging = false
$ ->
  $('.val_container').change ->
    if !window.isChanging
      window.isChanging = true
      prev = $(this).attr('oldvalue')
      cur = $(this).val()
      max = $(this).attr( 'max' )
      factor = $(this).attr('factor')
      my_member = $(this).attr('member')
      delta = cur - prev 

      positive = false
      if delta > 0
        positive = true
      delta = Math.abs( delta )

      #build an array of sliders
      sliders_array = []
      $('input[factor=\'' + factor + '\']').each (index, item) ->
        comp_member = $(item).attr('member' )
        if comp_member != my_member
          sliders_array.push( [item, $(item).val() ] )

      #Let's run through the delta and allocate those points
      while delta > 0
        index = 0
        while index < sliders_array.length
          item = sliders_array[ index++ ]
          if positive && item[ 1 ] > 0
            adjusted = parseInt( item[ 1 ] ) - 1
          else if item[ 1 ] < max
            adjusted = parseInt( item[ 1 ] ) + 1
          item[ 1 ] = adjusted
          delta--

      index = 0
      while index < sliders_array.length
        item = sliders_array[ index++ ]
        $(item[0]).val(item[1])

      $(this).attr 'oldvalue', $(this).val()

      total = 0
      $('input[factor=\'' + factor + '\']').each (index, item) ->
        member_alloc = parseInt $(item).val()
        total += member_alloc

      proportion = max / total 

      #Now, let's update the UI
      $('input[factor=\'' + factor + '\']').each (index, item) ->
        adjusted = proportion * $(item).val()
        $(item).val( adjusted )
        $(item).attr 'oldvalue', adjusted
        $(item).slider 'refresh'
            

      window.isChanging = false
