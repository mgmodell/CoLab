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
    toolTip = d3.select '.tooltip'
    if toolTip.size( ) < 1
      toolTip = d3.select( 'body' ).append( 'div' )
        .attr( 'class', 'tooltip' )
        .style( 'position', 'absolute' )
        .style( 'width', '150px' )
        .style( 'height', '56' )
        .style( 'text-align', 'center' )
        .style( 'background', 'lightsteelblue' )
        .style( 'font', '12px sans-serif' )
        .style( 'border', '0px' )
        .style( 'border-radius', '8px' )
        .style( 'pointer-events', 'none' )
        .style( 'opacity', 0 )

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
          .attr( 'class', 'chart' )
          .attr( "height", height )
          .attr( "width", targetWidth )
          .attr( 'version', 1.1)
          .attr( 'xmlns', 'http://www.w3.org/2000/svg' )

        g = chart.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')' )
          .attr('width', '90%' )

        xStretch = g.append( 'g' )
          .attr( 'class', 'hData' )
          .attr('original_width', (targetWidth - margin.left - margin.right ) )
        all_data = g.append( 'g' )
          .attr( 'class', 'hData' )
          .attr('original_width', (targetWidth - margin.left - margin.right ) )


        add_line = ( target, d, color, dash_length, dash_partial )->
          
          line = d3.line( )
            .x( (d)->
              return x(parseTime( d.date) )
            )
            .y( (d)->
              return y(d.value)
            )
            .curve(d3.curveMonotoneX)
          path = target.append( 'path' )
            .datum( d )
            .attr( 'fill', 'none' )
            .attr( 'stroke', 'white' )
            .attr( 'stroke-linejoin', 'round' )
            .attr( 'stroke-linecap', 'round' )
            .attr( 'stroke-width', 3 )
            .attr( 'd', line )

          target.selectAll( 'dot' )
            .data( d )
            .enter().append('circle')
            .attr( 'r', 5 )
            .attr('cx', (d)->
              return x(parseTime( d.date ) )
            )
            .attr('cy', (d)->
              return y(d.value)
            )
            .attr( 'fill', color )
            .attr( 'stroke', 'black' )
            .attr( 'stroke-width', 2 )
            .on( 'mouseover', (d)->
              tip_text = data.comments[ d.installment_id ]
              toolTip.transition()
                .duration( 200 )
                .style( 'opacity', .9 )
              toolTip.html( '<strong>Value: </strong>' + d.value + '</br>' + tip_text )
                .style( 'left', (d3.event.pageX) + 'px' )
                .style( 'top', (d3.event.pageY - 28) + 'px' )
            )
            .on( 'mouseout', (d)->
              toolTip.transition()
                .duration( 1000 )
                .style( 'opacity', 0 )
            )
            .transition( )
              .duration( 5000 )
              .attr( 'stroke', (d)->
                tip_text = data.comments[ d.installment_id ]
                pulse_color = 'yellow'
                if tip_text == '<no comment>'
                  pulse_color = 'black'
                
                return pulse_color
              )

          totalLength = path.node( ).getTotalLength( );
          path
            .attr('stroke-dasharray', totalLength + ' ' + totalLength )
            .attr('stroke-dashoffset', totalLength )
            .transition( )
              .duration( 2000 )
              .attr( 'stroke-dasharray', (d)->
                return ( dash_partial * 5 ) + "," + ( dash_length * 5 )
              )
              .attr( 'stroke', color )

        
        xStretch.append( 'g' )
          .attr( 'class', 'axis axis--x' )
          .attr( 'transform', 'translate(0, ' + (height - margin.top - margin.bottom ) + ')' )
          .call( d3.axisBottom( x ) )

        xLabelWidth = ( targetWidth - margin.left ) / 2
        xLabelHeight = height - margin.top

        xStretch.append( 'text' )
          .attr( 'transform',
                 'translate(' + xLabelWidth + ' ,' + xLabelHeight + ')' )
          .style( 'text-anchor', 'middle' )
          .text( 'Date' )
                                
        g.append( 'g' )
          .attr( 'class', 'axis axis--y' )
          .call( d3.axisLeft(y).ticks( 2 ).tickFormat( (d)->
            label = ''
            switch d
              when 0
                label = 'Low'
              when 6000
                label = 'High'
              
            return label
          ) )
        g.append( 'text' )
          .attr('transform', 'rotate(-90)' )
          .attr('y', 0 - margin.left )
          .attr('x', 0 - ( height/2 ) )
          .attr('dy', '1em' )
          .style('text-anchor', 'middle' )
          .text('Contribution Level')


        # https://bl.ocks.org/EfratVil/903d82a7cde553fb6739fe55af6103e2
        # http://bl.ocks.org/jfreyre/b1882159636cc9e1283a
        # maybe use Quantize
        factorColor = d3.scaleLinear( )
          .domain([ 0, Object.keys( data.factors ).length ] )
          .range([ 'red', 'green', 'yellow', 'purple', 'blue' ] )

        index = 0
        for id, factor of data.factors
          factor[ 'color' ] = factorColor( index )
          index++

        index = 0
        for id, user of data.users
          user[ 'index' ] = index
          index++

        user_count = index

        for id, stream of data.streams
          for sub_id, sub_stream of stream.sub_streams
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]
            for factor_id, factor_stream of sub_stream.factor_streams
              color = data.factors[ factor_id ][ 'color' ]
              add_line all_data, factor_stream.values, color, user_count, user_index

        #Create a close button
        lbw = 175 #legend base width
        lbh = 20 #legend base height
        legend_width = if Object.keys( data.factors ).length > 1 then (2 * lbw ) else lbw
        legend_rows = Math.round( Object.keys( data.factors ).length / 2 )
        legend = chart.append( 'g' )
          .attr( 'class', 'legend' )
          .attr( 'transform', 'translate( ' + ( targetWidth - 50 - legend_width ) + ', 15)')
          .attr( 'legendWidth', legend_width )
          .attr( 'opacity', .7 )

        legend.append( 'rect' )
          .attr( 'x', 0 )
          .attr( 'y', 0 )
          .attr( 'width', legend_width )
          .attr( 'height', lbh * legend_rows )
          .attr( 'stroke', 'black' )
          .attr( 'stroke-width', 2 )
          .style( 'fill', 'white' )

        for key, index in Object.keys( data.factors )
          index_off = Number( index )
          legend.append( 'circle' )
            .attr( 'cx', 10 + ( index_off %2 * lbw ) )
            .attr( 'cy', 10 + Math.floor( index_off /2 ) * lbh ) 
            .attr( 'r', 7 )
            .attr( 'fill', data.factors[ key ].color )
          legend.append( 'text' )
            .attr( 'x', 24 + (  index_off %2 * lbw ) )
            .attr( 'y', 13 + Math.floor( index_off /2 ) * lbh ) 
            .attr( 'fill', 'black' )
            .style( 'font-size', '10px' )
            .text( data.factors[ key ].name )

        #build and add our close button
        buttonBar = chart.append( 'g' )
          .attr( 'class', 'buttonBar' )
          .attr( 'transform', 'translate( ' + ( targetWidth - 25 ) + ', 25)')

        close_button = buttonBar.append( 'g' )
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

        #Create a export button
        export_button = buttonBar.append( 'g' )
          .attr( 'transform', 'translate( 0, 45)')
          .on( 'click', () ->
            # from http://bl.ocks.org/deanmalmgren/22d76b9c1f487ad1dde6
            svg_el = chart
              .node( )

            svg_crowbar( chart.node( ),
              filename: data.project_name + '_' + data.subject + '.png',
              width: targetWidth,
              height: height,
              crowbar_el: d3.select( '#crowbar-workspace' ).node( )
            )

          )
        export_button.append( 'circle' )
          .attr( 'cx', 0 )
          .attr( 'cy', 0 )
          .attr( 'r', 17 )
          .style( 'stroke', 'red' )
          .style( 'fill', 'white' )
        export_button.append( "rect" )
          .attr( 'x', -2.5 )
          .attr( 'y', -12 )
          .attr( 'width', 5 )
          .attr( 'height', 17 )
          .attr( 'stroke-width', 2 )
          .style( 'fill', 'black' )
        export_button.append( "rect" )
          .attr( 'x', -9 )
          .attr( 'y', 8 )
          .attr( 'width', 18 )
          .attr( 'height', 3 )
          .attr( 'stroke-width', 2 )
          .style( 'fill', 'black' )

        arrow_pts = [ { x: -8, y: -3 }, { x: 0, y: 6 }, { x: 8, y: -3 } ]
        arrow_line = d3.line( )
          .x( (d)->
            return d.x
          )
          .y( (d)->
            return d.y
          )
          .curve(d3.curveLinearClosed)
        export_button.append( 'path' )
          .datum( arrow_pts )
          .attr( 'fill', 'black' )
          .attr( 'stroke', 'black' )
          .attr( 'stroke-linejoin', 'round' )
          .attr( 'stroke-linecap', 'round' )
          .attr( 'stroke-width', 1 )
          .attr( 'd', arrow_line )

        #Create a export button
        focus_button = buttonBar.append( 'g' )
          .attr( 'transform', 'translate( 0, 70)')

        arc = d3.arc( )
          .innerRadius( 5 )
          .outerRadius( 200 )
          .startAngle( 0 )
          .endAngle( 45 )
          
        t = 2 * Math.PI
        focus_button.append( 'path' )
          .datum(
            endAngle: (2 * Math.I )
          )
          .style( 'fill', 'green' )
          .append( 'd', arc )

        # Let's build the chart
        titleX = targetWidth / 2
        titleY = 0 + ( margin.top / 2 )
        title = chart.append( "g" )
          .attr( 'class', 'title' )
        title.attr( 'transform', 'translate( ' + titleX + ', ' + titleY + ' )')
          .append( 'text' )
          .attr( 'x', 0 )
          .attr( 'y', 0 )
          .attr( 'text-anchor', 'middle' )
          .style( 'font-size', '16px' )
          .style( 'text-decoration', 'underline' )
          .text( data.unitOfAnalysis + ' chart for ' + data.subject)
        title
          .append( 'text' )
          .attr( 'x', 0 )
          .attr( 'y', 15 )
          .attr( 'text-anchor', 'middle' )
          .style( 'font-size', '10px' )
          .style( 'text-decoration', 'underline' )
          .text( 'for project: ' + data.project_name)

        d3.select( window )
          .on( 'resize', ()->
            targetWidth = chart_div.node( ).offsetWidth
            # Resize the charts
            d3.selectAll( '.chart' )
              .attr( 'width', targetWidth )

            # Relocate the button bar
            d3.selectAll( '.buttonBar' )
              .attr( 'transform', 'translate( ' + ( targetWidth - 25 ) + ', 25)' )

            # Relocate the legend
            legendWidth = legend.attr( 'legendWidth' )
            d3.selectAll( '.legend' )
              .attr( 'transform', 'translate( ' + ( targetWidth - 50 - legendWidth ) + ', 20)')

            # Relocate the title
            titleX = targetWidth / 2
            d3.selectAll( '.title' )
              .attr( 'transform', 'translate( ' + titleX + ', ' + titleY + ')')

            scaleFactor = ( targetWidth - margin.right - margin.left ) / xStretch.attr( 'original_width' )
            d3.selectAll( '.hData' ).each( (d)->
              obj = d3.select this
              originalWidth = obj.attr( 'original_width' )
              scaleFactor = (targetWidth - margin.right - margin.left) / originalWidth
              obj.attr( 'transform', 'matrix(' + scaleFactor + ' 0 0 1 0 0 )' )

            )  
          )

# http://bl.ocks.org/deanmalmgren/22d76b9c1f487ad1dde6
