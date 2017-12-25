# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).bind 'mobileinit', ->
  $.mobile.ajaxLinksEnabled = false
  $.mobile.ajaxFormsEnabled = false
  $.mobile.ajaxEnabled = false
  return

refreshProjects = ()->
  for_research = $("#for_research").val( )
  anonymous = $("#anonymous").val( )
  url = "projects/" + for_research + '/' + anonymous
  # Maybe do some loading thing here?
  $.getJSON url, (data) ->
    $( '#project' ).children('option:not(:first)').remove()
    d3.selectAll( '#project' )
      .append( 'option' )
      .text( 'None selected' )
      .attr( 'value',  -1 )
    for option in data
      d3.selectAll( '#project' )
        .append( 'option' )
        .text( option.name )
        .attr( 'value', option.id )
    $( '#project' ).selectmenu( 'refresh' )
    $( '#subject' ).children('option:not(:first)').remove()
    d3.selectAll( '#subject' )
    $( '#subject' ).selectmenu( 'refresh' )

# Hack to transform a rectangles coordinates to a line
rect_it = (element, outline, fill, x1, y1, x2, y2)->
  coords = [ ]
  coords.push( { x: x1, y: y1 } )
  coords.push( { x: x1, y: y2 } )
  coords.push( { x: x2, y: y2 } )
  coords.push( { x: x2, y: y1 } )
  raw_line = d3.line( )
    .x( (d)->
       d.x
    )
    .y( (d)->
       d.y
    )
    .curve(d3.curveLinearClosed)

  rect = element.append( 'path' )
    .datum( coords )
    .attr( 'fill', fill )
    .attr( 'stroke', outline )
    .attr( 'stroke-linejoin', 'round' )
    .attr( 'stroke-linecap', 'round' )
    .attr( 'stroke-width', 1 )
    .attr( 'd', raw_line )
  return rect

#Line dotted line rendering function
add_avg_line = ( chart_elem, target_id, target_name, factor_id,
                  factor_name, d, color, dash_length, dash_partial,
                  class_list, x, y, parseTime, comments, toolTipDiv )->
  target_class_id = 'u_' + target_id
  factor_class_id = 'f_' + factor_id
  dateStream = [ ]
  for date in Object.keys( d.avg_stream ).sort()
    dateStream.push d.avg_stream[ date ]

  line = d3.line( )
    .x( (d)->
      return x(parseTime( d.date ) )
    )
    .y( (d)->
      return y(d.sum / d.count )
    )
    .curve( d3.curveMonotoneX )
  path = chart_elem.append( 'path' )
    .datum( dateStream )
    .attr( 'fill', 'none' )
    .attr( 'class', class_list + ' ' + target_class_id + ' ' + factor_class_id )
    .attr( 'stroke', 'white' )
    .attr( 'stroke-linejoin', 'round' )
    .attr( 'stroke-linecap', 'round' )
    .attr( 'stroke-width', 3 )
    .attr( 'd', line )
  totalLength = path.node( ).getTotalLength( );
  path
    .attr('stroke-dasharray', totalLength + ' ' + totalLength )
    .attr('stroke-dashoffset', totalLength )
    .transition( )
      .duration( 2000 )
      .attr( 'stroke-dasharray', (d)->
        return '50, 1'#( dash_partial * 5 ) + "," + ( dash_length * 5 )
      )
      .attr( 'stroke', color )


# Render an averaged line
add_dotted_line = ( chart_elem, target_id, target_name, factor_id, factor_name,
                    d, color, dash_length, dash_partial, class_list, x, y,
                    parseTime, comments, toolTipDiv )->
  
  target_class_id = 'u_' + target_id
  factor_class_id = 'f_' + factor_id
  line = d3.line( )
    .x( (d)->
      return x(parseTime( d.date) )
    )
    .y( (d)->
      return y(d.value)
    )
    .curve(d3.curveMonotoneX)
  path = chart_elem.append( 'path' )
    .datum( d )
    .attr( 'fill', 'none' )
    .attr( 'class', class_list + ' ' + target_class_id + ' ' + factor_class_id )
    .attr( 'stroke', 'white' )
    .attr( 'stroke-linejoin', 'round' )
    .attr( 'stroke-linecap', 'round' )
    .attr( 'stroke-width', 3 )
    .attr( 'd', line )

  chart_elem.selectAll( 'dot' )
    .data( d )
    .enter().append('circle')
    .attr( 'class', class_list + ' ' + target_class_id + ' ' + factor_class_id )
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
    .attr( 'factor', factor_name )
    .attr( 'user', target_name )
    .on( 'mouseover', (d)->
      tip_text = ''
      #TODO: Move comments to their own, centered panel
      tip_text = '<strong>' + d3.select( this ).attr( 'user' ) + '</strong> reported</br>'
      tip_text += '<strong>' + d3.select( this ).attr( 'factor' ) + ' Value:</strong>' + d.value + '</br>'
      if comments[ d.installment_id ][ 'comment' ] != '<no comment>'
        tip_text += comments[ d.installment_id ][ 'comment' ]

      toolTipDiv.transition()
        .duration( 200 )
        .style( 'opacity', .9 )
      toolTipDiv.html( tip_text )
        .style( 'left', (d3.event.pageX) + 'px' )
        .style( 'top', (d3.event.pageY - 28) + 'px' )
    )
    .on( 'mouseout', (d)->
      toolTipDiv.transition()
        .duration( 1000 )
        .style( 'opacity', 0 )
    )
    .transition( )
      .duration( 5000 )
      .attr( 'stroke', (d)->
        tip_text = comments[ d.installment_id ]
        pulse_color = 'yellow'
        if comments[ d.installment_id ][ 'comment' ] == '<no comment>'
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

#Structuring Unit of Analysis
unitOfAnalysisOpts =
  i:
    ad: 
      code: 'ad'
      name: 'All Data'
      line_proc: add_dotted_line
      fcn: (data, line_func, chart_elem, user_count, class_id, xFcn, 
            yFcn, parseTimeFcn, comments, toolTipDiv )->
        for id, stream of data.streams
          target_id = id
          for sub_id, sub_stream of stream.sub_streams
            assessor_id = sub_stream.assessor_id
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]
            for factor_id, factor_stream of sub_stream.factor_streams
              color = data.factors[ factor_id ][ 'color' ]
              line_func chart_elem, assessor_id,
                        data[ 'users'][ assessor_id ][ 'name' ], factor_id, 
                        data[ 'factors' ][ factor_id ][ 'name' ], factor_stream.values,
                        color, user_count, user_index, class_id, xFcn, yFcn, parseTimeFcn, 
                        comments, toolTipDiv
    ab: 
      code: 'ab'
      name: 'Average by Behavior'
      line_proc: add_avg_line
      fcn: (data, line_func, chart_elem, user_count, class_id, xFcn, 
            yFcn, parseTimeFcn, comments, toolTipDiv )->
        for id, stream of data.streams
          for sub_id, sub_stream of stream.sub_streams
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]
            assessor_id = sub_stream.assessor_id
            for factor_id, factor_stream of sub_stream.factor_streams
              factor_avg = data.factors[ factor_id ][ 'avg_stream' ]
              if(!factor_avg?)then factor_avg = { }
              for value in factor_stream.values
                avg_val = factor_avg[ value.close_date ]
                if(!avg_val?)then avg_val = 
                  sum: 0
                  count: 0
                  date: value.date
                  factor_id: factor_id
                avg_val[ 'sum' ] = avg_val[ 'sum' ] + value.value
                avg_val[ 'count' ] = avg_val[ 'count' ] + 1
                factor_avg[ value.date ] = avg_val
                data.factors[ factor_id ][ 'avg_stream' ] = factor_avg

        for factor_id, factor_coll of data.factors
          color = data.factors[ factor_id ][ 'color' ]
          target_id = factor_id
          line_func chart_elem, assessor_id, 
                    data[ 'users' ][ assessor_id ][ 'name' ], factor_id,
                    data[ 'factors' ][factor_id ][ 'name' ], factor_coll, color,
                    user_count, user_index, class_id, xFcn, yFcn, parseTimeFcn,
                    comments, toolTipDiv

    ao: 
      code: 'ao'
      name: 'Overall Average'
      fcn: ()->
        return 'All Data'
    ag_g: 
      code: 'ag_g'
      name: 'Group Agreement'
      fcn: ()->
        return 'All Data'
    ag_s: 
      code: 'ag_s'
      name: 'Agreement with Self'
      fcn: ()->
        return 'All Data'
    ag_m: 
      code: 'ag_m'
      name: 'Agreement without Self'
      fcn: ()->
        return 'All Data'
  g:
    ad: 
      code: 'ad'
      name: 'All Data'
      line_proc: add_dotted_line
      fcn: (data, line_func, chart_elem, user_count, class_id, xFcn, 
            yFcn, parseTimeFcn, comments, toolTipDiv )->
        for id, stream of data.streams
          target_id = id
          for sub_id, sub_stream of stream.sub_streams
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]
            for factor_id, factor_stream of sub_stream.factor_streams
              color = data.factors[ factor_id ][ 'color' ]
              line_func chart_elem, target_id,
                        data[ 'users' ][ target_id ][ 'name' ], factor_id,
                        data[ 'factors' ][ factor_id ][ 'name' ], 
                        factor_stream.values, color, user_count, 
                        user_index, class_id, xFcn, yFcn, parseTimeFcn, 
                        comments, toolTipDiv
    am: 
      code: 'am'
      name: 'Average by Member'
      fcn: ()->
        return 'All Data'
    vb: 
      code: 'vb'
      name: 'Variance by Behavior'
      fcn: ()->
        return 'All Data'
    vm: 
      code: 'vm'
      name: 'Variance by Member'
      fcn: ()->
        return 'All Data'
    ag_b: 
      code: 'ag_b'
      name: 'Agreement by Behavior'
      fcn: ()->
        return 'All Data'
    ag_m: 
      code: 'ag_m'
      name: 'Agreement by Member'
      fcn: ()->
        return 'All Data'

$ ->
  $(".project_select").change ->
    subject_select = $(this).parents("form").find("#subject")
    unit_of_analysis = $(this).parents("form").find("#unit_of_analysis").val()
    project_id = $(this).val()
    for_research = $("#for_research").val()
    anonymous = $("#anonymous").val()
    url = "subjects/" + unit_of_analysis + "/" + project_id + "/" + for_research + '/' + anonymous
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

  $("#for_research").on( 'slidestop', ->
    for_research = $("#for_research").val( )
    if for_research is 'true'
      if confirm ( 'This will remove all the charts below. Are you sure?' )
        d3.selectAll( 'svg' ).remove( )
        $( '.project_select' ).children( ).remove( )
        option = document.createElement( 'option' )
        option.text = 'Not Available'
        $( '.project_select' ).add option
        refreshProjects( )
      else
        $("#for_research").val( 'false' )
        $("#for_research").slider( 'refresh' )
    else
      $("#for_research").val( 'false' )
      refreshProjects( )

  )
  $("#anonymous").on( 'slidestop', ->
    anonymous = $("#anonymous").val( )
    if anonymous is 'true'
      if confirm ( 'This will remove all the charts below. Are you sure?' )
        d3.selectAll( 'svg' ).remove( )
        $( '.project_select' ).children( ).remove( )
        option = document.createElement( 'option' )
        option.text = 'Not Available'
        refreshProjects( )
      else
        $("#anonymous").val( 'false' )
        $("#anonymous").slider( 'refresh' )
        
    else
      $("#anonymous").val( 'false' )
      refreshProjects( )
  
  )
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
    anonymous = $("#anonymous").val()
    if subject isnt "-1"
      url = "data/" + unit_of_analysis + "/" + subject + "/" + project + "/" + for_research + '/' + anonymous
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

        identifier = data.unitOfAnalysisCode + '_' + data.project_id + '_' + data.subject_id
        chart = chart_div.append( "svg" )
          .attr( 'class', 'chart ' + identifier )
          .attr( "height", height )
          .attr( "width", targetWidth )
          .attr( 'version', 1.1)
          .attr( 'xmlns', 'http://www.w3.org/2000/svg' )

        bg_color = rect_it( chart, 'white', 'white', 0, 0, targetWidth, height )

        g = chart.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')' )
          .attr('width', '90%' )
          

        zoom = d3.zoom( )
          .scaleExtent( [ 0.9, 8 ] )
          .on( 'zoom', ->
            g.attr( 'zoomed', 'true' )
            g.attr( 'transform', d3.event.transform )
          )

        g.call( zoom )
        g.on( 'click', ()->
            if g.attr( 'zoomed' ) is 'true'
              g.attr( 'zoomed', 'false' )
              g.attr( 'transform', d3.zoomIdentity )
        )

        chart_bg = rect_it( g, 'white', 'white', 0, 0, ( targetWidth - margin.right - margin.left ), (height - margin.top -
        margin.bottom ) )

        xStretch = g.append( 'g' )
          .attr( 'class', 'hData' )
          .attr('original_width', (targetWidth - margin.left - margin.right ) )

        all_data = g.append( 'g' )
          .attr( 'class', 'hData' )
          .attr('original_width', (targetWidth - margin.left - margin.right ) )
        
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

        #Create a close button
        lbw = 170 #legend base width
        lbh = 20 #legend base height
        factor_legend_width = if Object.keys( data.factors ).length > 1 then (2 * lbw ) else lbw
        factor_legend_rows = Math.round( Object.keys( data.factors ).length / 2 )
        factor_legend = chart.append( 'g' )
          .attr( 'class', 'factorLegend' )
          .attr( 'transform', 'translate( ' + ( targetWidth - 50 - factor_legend_width ) + ', 40)')
          .attr( 'factorLegendWidth', factor_legend_width )
          .attr( 'opacity', .7 )

        # below is a hack for rectangles because crowbar (svg export) seems
        # not to like them.
        rect_it( factor_legend, 'black', 'oldlace', 0, 0, factor_legend_width, ( factor_legend_rows * lbh ) )


        for key, index in Object.keys( data.factors )
          index_off = Number( index )
          factor_legend.append( 'circle' )
            .attr( 'cx', 10 + ( index_off %2 * lbw ) )
            .attr( 'cy', 10 + Math.floor( index_off /2 ) * lbh ) 
            .attr( 'r', 7 )
            .attr( 'fill', data.factors[ key ].color )
            .attr( 'parent_chart', identifier )
            .attr( 'class', 'f_' + key )
            .attr( 'factor_tag', 'f_' + key )
            .on( 'click', (d)->
              id = d3.select( this ).attr( 'parent_chart' )
              factor_tag = d3.select( this ).attr( 'factor_tag' )
              spec_opacity = d3.select( this ).attr( 'opacity' )

              if Number( spec_opacity ) == .1
                spec_opacity = 1
              else
                spec_opacity = .1

              d3.select( '.' + id ).selectAll( '.' + factor_tag )
                .attr( 'opacity', spec_opacity )
              
            )
          factor_legend.append( 'text' )
            .attr( 'x', 24 + (  index_off %2 * lbw ) )
            .attr( 'y', 13 + Math.floor( index_off /2 ) * lbh ) 
            .attr( 'fill', 'black' )
            .style( 'font-size', '10px' )
            .text( data.factors[ key ].name )
            .attr( 'parent_chart', identifier )
            .attr( 'class', 'f_' + key )
            .attr( 'factor_tag', 'f_' + key )
            .on( 'click', (d)->
              id = d3.select( this ).attr( 'parent_chart' )
              factor_tag = d3.select( this ).attr( 'factor_tag' )
              spec_opacity = d3.select( this ).attr( 'opacity' )

              if Number( spec_opacity ) == .1
                spec_opacity = 1
              else
                spec_opacity = .1

              d3.select( '.' + id ).selectAll( '.' + factor_tag )
                .attr( 'opacity', spec_opacity )
              
            )

        user_legend_width = if Object.keys( data.users ).length > 1 then (2 * lbw ) else lbw
        user_legend_rows = Math.round( Object.keys( data.users ).length / 2 )
        user_legend = chart.append( 'g' )
          .attr( 'class', 'userLegend' )
          .attr( 'transform', 'translate( 50 , 40)')
          .attr( 'userLegendWidth', user_legend_width )
          .attr( 'opacity', .7 )

        rect_it( user_legend, 'black', 'oldlace', 0, 0, user_legend_width, ( user_legend_rows * lbh ) )

        for key, index in Object.keys( data.users )
          index_off = Number( index )
          user_legend.append( 'line' )
            .attr( 'x1', 10 + ( index_off %2 * lbw ) )
            .attr( 'y1', 15 + Math.floor( index_off /2 ) * lbh )
            .attr( 'x2', ( lbw + ( index_off %2 * lbw ) - 30 ) )
            .attr( 'y2', 15 + Math.floor( index_off /2 ) * lbh )
            .attr( 'stroke', 'black' )
            .attr( 'stroke-width', 3 )
            .attr( 'stroke-dasharray', ( user_index * 5 ) + ' ' + (index * 5 ))
            .attr( 'parent_chart', identifier )
            .attr( 'opacity', .5 )
            .attr( 'class', 'u_' + key )
            .attr( 'user_tag', 'u_' + key )
            .on( 'click', (d)->
              id = d3.select( this ).attr( 'parent_chart' )
              user_tag = d3.select( this ).attr( 'user_tag' )
              spec_opacity = d3.select( this ).attr( 'opacity' )

              if Number( spec_opacity ) == .1
                spec_opacity = 1
              else
                spec_opacity = .1

              d3.select( '.' + id ).selectAll( '.' + user_tag )
                .attr( 'opacity', spec_opacity )
              
            )

          user_legend.append( 'text' )
            .attr( 'x', 10 + (  index_off %2 * lbw ) )
            .attr( 'y', 13 + Math.floor( index_off /2 ) * lbh ) 
            .attr( 'fill', 'black' )
            .attr( 'parent_chart', identifier )
            .attr( 'class', 'u_' + key )
            .attr( 'user_tag', 'u_' + key )
            .style( 'font-size', '10px' )
            .text( data.users[ key ].name )
            .on( 'click', (d)->
              id = d3.select( this ).attr( 'parent_chart' )
              user_tag = d3.select( this ).attr( 'user_tag' )
              spec_opacity = d3.select( this ).attr( 'opacity' )

              if Number( spec_opacity ) == .1
                spec_opacity = 1
              else
                spec_opacity = .1

              d3.select( '.' + id ).selectAll( '.' + user_tag )
                .attr( 'opacity', spec_opacity )
              
            )

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
            # Add a warning because of crowbar strangeness
            warning_msg = 'This chart download function is experimental.'
            warning_msg += 'You may need to reload the chart afterwards. Proceed?'
            if confirm( warning_msg )
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
        rect_it( export_button, 'black', 'black', -2.5, -12, 2.5, 2 )

        rect_it( export_button, 'black', 'black', -9, 8, 9, 11 )

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
          .attr( 'transform', 'translate( 0, 100)')

        #Create the output beam
        arrow_pts = [ { x: -40, y: 0 }, { x: 0, y: -1.5 }, { x: 0, y: 1.5 } ]
        arrow_line = d3.line( )
          .x( (d)->
            return d.x
          )
          .y( (d)->
            return d.y
          )
          .curve(d3.curveLinearClosed)
        focus_button.append( 'path' )
          .datum( arrow_pts )
          .attr( 'fill', 'orange' )
          .attr( 'stroke-linejoin', 'round' )
          .attr( 'stroke-linecap', 'round' )
          .attr( 'stroke-width', 1 )
          .attr( 'd', arrow_line )


        #Create the rainbow coming in
        π = Math.PI
        τ = .35 * π
        n = 500
        focus_button.selectAll( 'path' )
          .data( d3.range( 0, τ, τ / n ) )
          .enter( ).append( 'path' )
          .attr( 'rainbow', 'true' )
          .attr( 'transform', 'rotate( 45 0 0 )' )
          .attr( 'd', d3.arc( )
          .outerRadius(40)
          .innerRadius(3)
          .startAngle (d)->
            d
          .endAngle (d)->
            d + τ / n * 1.1
          )
          .style("fill", (d)-> 
            return d3.hsl(d * 360 / τ, 1, .5)
          )

        prizm_pts = [ { x: 0, y: -15 }, { x: 3, y: 18 }, { x: -18, y: 13 } ]
        focus_line = d3.line( )
          .x( (d)->
            return d.x
          )
          .y( (d)->
            return d.y
          )
          .curve(d3.curveLinearClosed)
        focus_button.append( 'path' )
          .datum( prizm_pts )
          .attr( 'fill', 'steelblue' )
          .attr( 'opacity', .6 )
          .attr( 'stroke', 'black' )
          .attr( 'stroke-linejoin', 'round' )
          .attr( 'stroke-linecap', 'round' )
          .attr( 'stroke-width', 1 )
          .attr( 'd', focus_line )


        prizm_pts = [ { x: 0, y: -15 }, { x: 3, y: 18 }, { x: 18, y: 13 } ]
        focus_line = d3.line( )
          .x( (d)->
            return d.x
          )
          .y( (d)->
            return d.y
          )
          .curve(d3.curveLinearClosed)
        focus_button.append( 'path' )
          .datum( prizm_pts )
          .attr( 'fill', 'lightsteelblue' )
          .attr( 'opacity', .4 )
          .attr( 'stroke', 'black' )
          .attr( 'stroke-linejoin', 'round' )
          .attr( 'stroke-linecap', 'round' )
          .attr( 'stroke-width', 1 )
          .attr( 'd', focus_line )

        index = 0
        for a_code, a_method of unitOfAnalysisOpts[ data.unitOfAnalysisCode ]
          index++
          focus_button.append( 'text' )
            .attr( 'class', a_code )
            .attr( 'parent_chart', identifier )
            .attr( 'data_code', a_code )
            .attr( 'x', -60 )
            .attr( 'y', 20 + (10 * index ) )
            .attr( 'font-size', '8px' )
            .text( a_method.name )
            .on( 'click', (d)->
              id = d3.select( this ).attr( 'parent_chart' )
              spec_code = d3.select( this ).attr( 'data_code' )
              spec_opacity = d3.select( this ).attr( 'opacity' )
              processed = d3.select( this ).attr( 'processed' )

              block = unitOfAnalysisOpts[ data.unitOfAnalysisCode ][spec_code]
              if !processed? || !processed
                block.fcn( data, block.line_proc, all_data, user_count, 
                           block.code, x, y, parseTime, data.comments, toolTip )
                d3.select( this ).attr( 'processed', true )

              else
                if Number( spec_opacity ) == .1
                  spec_opacity = 1
                else
                  spec_opacity = .1

                d3.select( '.' + id ).selectAll( '.' + spec_code )
                  .attr( 'opacity', spec_opacity )
              
            )


        # Let's build the text
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

        #add analysis processing here
        block = unitOfAnalysisOpts[ data.unitOfAnalysisCode ]['ad']
        block.fcn( data, block.line_proc, all_data, user_count, 
                   block.code, x, y, parseTime, data.comments, toolTip )
        d3.selectAll( '.ad' ).attr( 'processed', true )


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
            factorLegendWidth = factor_legend.attr( 'factorLegendWidth' )
            d3.selectAll( '.factorLegend' )
              .attr( 'transform', 'translate( ' + ( targetWidth - 50 - factorLegendWidth ) + ', 40)')

            # Relocate the title
            titleX = targetWidth / 2
            d3.selectAll( '.title' )
              .attr( 'transform', 'translate( ' + titleX + ', ' + titleY + ')')

            scaleFactor = ( targetWidth - margin.right - margin.left ) / xStretch.attr( 'original_width' )
            bg_color
              .attr( 'transform', 'matrix(' + scaleFactor + ' 0 0 1 0 0)')

            d3.selectAll( '.hData' ).each( (d)->
              obj = d3.select this
              originalWidth = obj.attr( 'original_width' )
              scaleFactor = (targetWidth - margin.right - margin.left) / originalWidth
              obj.attr( 'transform', 'matrix(' + scaleFactor + ' 0 0 1 0 0 )' )

            )  
          )

# http://bl.ocks.org/deanmalmgren/22d76b9c1f487ad1dde6
