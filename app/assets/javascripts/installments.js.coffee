#This code works for sliders only
window.isChanging = false
$ ->
  $('.val_container').change ->
    if !window.isChanging
      window.isChanging = true
      prev = $(this).attr('oldvalue')
      cur = $(this).val()
      step = $(this).attr('step')
      factor = $(this).attr('factor')
      member_count = $('input[factor=\'' + factor + '\']').length
      delta = (cur - prev) / (member_count - 1)

      my_member = $(this).attr('member')
      $('input[factor=\'' + factor + '\']').each (index, item) ->
        comp_member = $(item).attr('member' )
        if comp_member != my_member
          newVal = $(item).val()  - delta
          $(item).attr 'oldvalue', newVal
          $(item).val(newVal).slider 'refresh'
        else
          console.log( "Found myself!" )

      #$(this).val( cur ).slider 'refresh'
      #$(this).attr 'oldvalue', cur
      window.isChanging = false
    return
