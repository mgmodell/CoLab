# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).bind 'mobileinit', ->
  $.mobile.ajaxLinksEnabled = false
  $.mobile.ajaxFormsEnabled = false
  $.mobile.ajaxEnabled = false
  return


$ ->
  $(".project_select").change ->
    subject_select = $(this).parents("form").find("#subject")
    unit_of_analysis = $(this).parents("form").find("#unit_of_analysis").val()
    project_id = $(this).val()
    for_research = $("#for_research").val()
    url = "subjects/" + unit_of_analysis + "/" + project_id + "/" + for_research
    $.getJSON url, (data) ->
      i = undefined
      newOption = undefined
      $(subject_select).empty()
      newOption = "<option value=\"-1\">None Selected</option>"
      $(subject_select).append newOption
      i = 0
      while i < data.length
        newOption = "<option value=" + data[i][1] + ">" + data[i][0] + "</option>"
        $(subject_select).append newOption
        i++
    $(subject_select).selectmenu 'refresh', true

  $("#for_research").change ->
    for_research = $("#for_research").val( )
    $("[id$='_panel']").each ->
      subject_select = $(this).parents("form").find("#subject")
      chart_num = parseInt($(this).find(".chart").attr("chart_num"))
      detail_container = $(this).find("#detail_container")
      unit_of_analysis = $(this).find("#unit_of_analysis").val()
      assessment = $(this).find("#assessment").val()
      subject = $(this).find("#subject").val()
      data_processing = $(this).find("#data_processing").val()
      if assessment isnt "-1"
        url = "subjects/" + unit_of_analysis + "/" + assessment + "/" + for_research
        $.getJSON url, (data) ->
          i = undefined
          newOption = undefined
          $(subject_select).empty()
          $(subject_select).refresh
          i = 0
          while i < data.subjects.length
            newOption = "<option value=" + data.subjects[i][1] + ">" + data.subjects[i][0] + "</option>"
            $(subject_select).append newOption
            i++
          $(subject_select).selectmenu 'refresh', true
        if subject isnt "-1"
          url = "data/" + unit_of_analysis + "/" + subject + "/" + assessment + "/" + data_processing + "/" + for_research
          window.charts[chart_num].showLoading()
          $.getJSON url, (data) ->
            chart = window.charts[chart_num]
            index = 0
            chart.series[index].remove()  while index < chart.series.length
            chart.setTitle
              text: data.details.name
            ,
              text: "Individual Data"
  
            index = 0
            while index < data.series.length
              chart.addSeries
                name: data.series[index].label
                data: data.series[index].data
  
              index++
            
            #Now let's handle the html bits
            key_arr = Object.keys(data.details)
            index = 0
            text = "<h3>Details and Statistics:</h3><UL>"
            while index < key_arr.length
              text += "<LI>" + key_arr[index] + ":" + data.details[key_arr[index]] + "</LI>"
              index++
            text += "</ul>"
            $(detail_container).html text
            chart.hideLoading()
  
  $(".submitting_select").change ->
    chart_div = $(this).parents("form").find("#graph_div")
    unit_of_analysis = $(this).parents("form").find("#unit_of_analysis").val()
    project = $(this).parents("form").find("#project").val()
    subject = $(this).parents("form").find("#subject").val()
    data_processing = $(this).parents("form").find("#data_processing").val()
    for_research = $("#for_research").val()
    if subject isnt "-1"
      url = "data/" + unit_of_analysis + "/" + subject + "/" + project + "/" + for_research
      # Maybe do some loading thing here?
      $.getJSON url, (data) ->
        chart_div = d3.select( chart_div.get( 0 ) )
        margin = { top: 40, bottom: 40, left: 40, right: 40 }
        height = 400
        targetWidth = chart_div.node( ).offsetWidth

        parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%L%Z")
        x = d3.scaleTime( )
          .domain( [ parseTime( data.start_date ), parseTime( data.end_date ) ])
          .rangeRound( [ 0, ( targetWidth - margin.left - margin.right ) ] )
        y = d3.scaleLinear( )
          .domain( [0, 6000] )
          .rangeRound( [ ( height - margin.top - margin.bottom ), 0 ] )

        chart = chart_div.append( "svg" )
          .attr( "height", height ).attr( "width", targetWidth )
        g = chart.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')' )

        add_line = ( d )->
          
          line = d3.line( )
            .x( (d)->
              return x(parseTime( d.date) )
            )
            .y( (d)->
              return y(d.value)
            )
          g.append( 'path' )
            .datum( d )
            .attr( 'fill', 'none' )
            .attr( 'stroke', 'steelblue' )
            .attr( 'stroke-linejoin', 'round' )
            .attr( 'stroke-linecap', 'round' )
            .attr( 'stroke-width', 1.5 )
            .attr( 'd', line )

        
        g.append( 'g' )
          .attr( 'class', 'axis axis--x' )
          .attr( 'transform', 'translate(0, ' + (height - margin.top - margin.bottom ) + ')' )
          .call( d3.axisBottom( x ) )
        g.append( 'g' )
          .attr( 'class', 'axis axis--y' )
          .call( d3.axisLeft(y).ticks( 6 ).tickFormat( (d)->
            return ''
          ) )


        // https://bl.ocks.org/EfratVil/903d82a7cde553fb6739fe55af6103e2
        // http://bl.ocks.org/jfreyre/b1882159636cc9e1283a
        // maybe use Quantize
        console.log Object.keys( data.users ).length
        console.log Object.keys( data.factors ).length
        for id, stream of data.streams
          for sub_id, sub_stream of stream.sub_streams
            for factor_id, factor_stream of sub_stream.factor_streams
              add_line factor_stream.values

        #Create a close button
        close_button = chart.append( 'g' )
          .attr( 'transform', 'translate( ' + ( targetWidth - 25 ) + ', 25)')
          .on( 'click', () ->
            chart.remove( )
          )
        close_button.append( 'circle' )
          .attr( 'cx', 0 )
          .attr( 'cy', 0 )
          .attr( 'r', 17 )
          .style( 'stroke', 'red' )
          .style( 'fill', 'white' )
        close_button.append( "line" )
          .attr( 'x1', 10 )
          .attr( 'y1', -10 )
          .attr( 'x2', -10 )
          .attr( 'y2', 10 )
          .attr( 'stroke-width', 2 )
          .attr( 'stroke', 'black' )
        close_button.append( "line" )
          .attr( 'x1', -10 )
          .attr( 'y1', -10 )
          .attr( 'x2', 10 )
          .attr( 'y2', 10 )
          .attr( 'stroke-width', 2 )
          .attr( 'stroke', 'black' )

        titleX = targetWidth / 2
        titleY = 0 + ( margin.top / 2 )
        title = chart.append( "g" )
        title.attr( 'transform', 'translate( ' + titleX + ', ' + titleY + ' )')
          .append( 'text' )
          .attr( 'x', 0 )
          .attr( 'y', 0 )
          .attr( 'text-anchor', 'middle' )
          .style( 'font-size', '16px' )
          .style( 'text-decoration', 'underline' )
          .text( data.unitOfAnalysis + ' chart for ' + data.subject)

        d3.select( window )
          .on( 'resize', ()->
            targetWidth = chart_div.node( ).offsetWidth
            chart.attr( 'width', targetWidth )
            close_button.attr( 'transform', 'translate( ' + ( targetWidth - 25 ) + ', 25)')
            titleX = targetWidth / 2
            title.attr( 'transform', 'translate( ' + titleX + ', ' + titleY + ')')
          )
  
  
  
