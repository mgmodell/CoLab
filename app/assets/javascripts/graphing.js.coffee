# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
chrtCtx.margin = { top: 40, bottom: 40, left: 40, right: 40 }
chrtCtx.height = 400


#Line dotted line rendering function
add_avg_line = ( target_id, target_name, factor_id,
                  factor_name, d, color, class_list, dash_partial, comments, ctx ) -> 
  target_class_id = 'u_' + target_id
  factor_class_id = 'f_' + factor_id
  dateStream = [ ]
  for date in Object.keys( d.avg_stream ).sort()
    dateStream.push d.avg_stream[ date ]

  line = d3.line( )
    .x( (d)->
      return ctx.x(ctx.parseTime( d.date ) )
    )
    .y( (d)->
      return ctx.y(d.sum / d.count )
    )
    .curve( d3.curveMonotoneX )
  path = ctx.all_data.append( 'path' )
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
        return '50, 1'#( dash_partial * 5 ) + "," + ( ctx.user_count * 5 )
      )
      .attr( 'stroke', color )


# Render an averaged line
add_dotted_line = ( target_id, target_name, factor_id, factor_name,
                    d, color, class_list, dash_partial, comments, ctx ) ->
  
  target_class_id = 'u_' + target_id
  factor_class_id = 'f_' + factor_id
  line = d3.line( )
    .x( (d)->
      return ctx.x(ctx.parseTime( d.date) )
    )
    .y( (d)->
      return ctx.y(d.value)
    )
    .curve(d3.curveMonotoneX)
  path = ctx.all_data.append( 'path' )
    .datum( d )
    .attr( 'fill', 'none' )
    .attr( 'class', class_list + ' ' + target_class_id + ' ' + factor_class_id )
    .attr( 'stroke', 'white' )
    .attr( 'stroke-linejoin', 'round' )
    .attr( 'stroke-linecap', 'round' )
    .attr( 'stroke-width', 3 )
    .attr( 'd', line )

  ctx.all_data.selectAll( 'dot' )
    .data( d )
    .enter().append('circle')
    .attr( 'class', class_list + ' ' + target_class_id + ' ' + factor_class_id )
    .attr( 'r', 5 )
    .attr('cx', (d)->
      return ctx.x(ctx.parseTime( d.date ) )
    )
    .attr('cy', (d)->
      return ctx.y(d.value)
    )
    .attr( 'fill', color )
    .attr( 'stroke', 'black' )
    .attr( 'stroke-width', 2 )
    .attr( 'factor', factor_name )
    .attr( 'user', target_name )
    .on( 'mouseover', (d)->
      tip_text = ''
      #TODO: Move comments to their own, centered panel
      tip_text = '<strong>' + d3.select( this ).attr( 'user' ) + '</strong></br>'
      tip_text += '<strong>' + d3.select( this ).attr( 'factor' ) + ' '
      tip_text += ctx.value + ':</strong>' + d.value + '</br>'
      if comments[ d.installment_id ][ 'comment' ] != '<no comment>'
        tip_text += "<strong>" + comments[d.installment_id][ 'commentor' ]
        tip_text += ctx.wrote + ":</strong>"
        tip_text += comments[ d.installment_id ][ 'comment' ]
        tip_text += '</br><strong>' + ctx.clickForMore + '</strong>'

      ctx.toolTip.transition()
        .duration( 200 )
        .style( 'opacity', .9 )
      ctx.toolTip.html( tip_text )
        .style( 'left', (d3.event.pageX) + 'px' )
        .style( 'top', (d3.event.pageY - 28) + 'px' )
    )
    .on( 'click', (d)->
      tip_text = ''
      #TODO: Move comments to their own, centered panel
      tip_text = '<strong>' + d3.select( this ).attr( 'user' ) + '</strong></br>'
      tip_text += '<strong>' + d3.select( this ).attr( 'factor' ) + ' '
      tip_text += ctx.value + ':</strong>' + d.value + '</br>'
      if comments[ d.installment_id ][ 'comment' ] != '<no comment>'
        tip_text += "<strong>" + comments[d.installment_id][ 'commentor' ]
        tip_text += ctx.wrote + ":</strong>"
        tip_text += comments[ d.installment_id ][ 'comment' ]

      ctx.toolTip.transition()
        .duration( 200 )
        .style( 'opacity', .9 )
      parent = this.parentNode.getBoundingClientRect()
      console.log parent.x
      console.log parent.y
      console.log 'hello'
      ctx.toolTip.html( tip_text )
        .style( 'left', (parent.x + 25) + 'px' )
        .style( 'top', (window.scrollY + parent.y + 15) + 'px' )
        .style( 'width', '300px' )
        .style( 'height', '156' )
    )
    .on( 'mouseout', (d)->
      ctx.toolTip.transition()
        .duration( 1000 )
        .style( 'opacity', 0 )
        .style( 'width', '150px' )
        .style( 'height', '56' )
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
        return ( dash_partial * 5 ) + "," + ( ctx.user_count * 5 )
      )
      .attr( 'stroke', color )

#Structuring Unit of Analysis
unitOfAnalysisOpts =
  i:
    ad: 
      code: 'ad'
      name: chrtCtx.indAd
      line_proc: add_dotted_line
      fcn: (data, line_func, ctx, class_id, comments ) ->
        for id, stream of data.streams
          target_id = id
          for sub_id, sub_stream of stream.sub_streams
            assessor_id = sub_stream.assessor_id
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]
            for factor_id, factor_stream of sub_stream.factor_streams
              color = data.factors[ factor_id ][ 'color' ]
              line_func assessor_id, data[ 'users'][ assessor_id ][ 'name' ], factor_id, 
                        data[ 'factors' ][ factor_id ][ 'name' ], factor_stream.values,
                        color, class_id, user_index, comments, ctx
    ab: 
      code: 'ab'
      name: chrtCtx.indAb
      line_proc: add_avg_line
      fcn: (data, line_func, ctx, class_id, comments ) ->
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
          line_func assessor_id, data[ 'users' ][ assessor_id ][ 'name' ], factor_id,
                    data[ 'factors' ][factor_id ][ 'name' ], factor_coll, color,
                    class_id, user_index, comments, ctx

    ao: 
      code: 'ao'
      name: chrtCtx.indAb
      fcn: ()->
        return 'All Data'
    ag_g: 
      code: 'ag_g'
      name: chrtCtx.indAgG
      fcn: ()->
        return 'All Data'
    ag_s: 
      code: 'ag_s'
      name: chrtCtx.indAgS
      fcn: ()->
        return 'All Data'
    ag_m: 
      code: 'ag_m'
      name: chrtCtx.indAgM
      fcn: ()->
        return 'All Data'
  g:
    ad: 
      code: 'ad'
      name: chrtCtx.gAd
      line_proc: add_dotted_line
      fcn: (data, line_func, ctx, class_id, comments ) ->
        for id, stream of data.streams
          target_id = id
          for sub_id, sub_stream of stream.sub_streams
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]
            for factor_id, factor_stream of sub_stream.factor_streams
              color = data.factors[ factor_id ][ 'color' ]
              line_func target_id, data[ 'users' ][ target_id ][ 'name' ], factor_id,
                        data[ 'factors' ][ factor_id ][ 'name' ], 
                        factor_stream.values, color, class_id, user_index,
                        comments, ctx
    am: 
      code: 'am'
      name: chrtCtx.gAm
      fcn: ()->
        return 'All Data'
    vb: 
      code: 'vb'
      name: chrtCtx.gVb
      fcn: ()->
        return 'All Data'
    vm: 
      code: 'vm'
      name: chrtCtx.gVm
      fcn: ()->
        return 'All Data'
    ag_b: 
      code: 'ag_b'
      name: chrtCtx.gAgB
      fcn: ()->
        return 'All Data'
    ag_m: 
      code: 'ag_m'
      name: chrtCtx.gAgM
      fcn: ()->
        return 'All Data'

  $(".submitting_select").change ->
    chart_div = $(this).parents("form").find("#graph_div")
    chrtCtx.toolTip = d3.select '.tooltip'
    if chrtCtx.toolTip.size( ) < 1
      chrtCtx.toolTip = d3.select( 'body' ).append( 'div' )
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

        ctx = Object.assign( {}, chrtCtx )
        chart_div = d3.select( chart_div.get( 0 ) )
        # ctx will be the specific chart context
        ctx.targetWidth = chart_div.node( ).offsetWidth

        ctx.parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%L%Z")
        ctx.x = d3.scaleTime( )
          .domain( [ ctx.parseTime( data.start_date ), ctx.parseTime( data.end_date ) ])
          .rangeRound( [ 0, ( ctx.targetWidth - ctx.margin.left - ctx.margin.right ) ] )
        ctx.y = d3.scaleLinear( )
          .domain( [0, 6000] )
          .rangeRound( [ ( ctx.height - ctx.margin.top - ctx.margin.bottom ), 0 ] )

        identifier = data.unitOfAnalysisCode + '_' + data.project_id + '_' + data.subject_id
        chart = chart_div.append( "svg" )
          .attr( 'class', 'chart ' + identifier )
          .attr( "height", ctx.height )
          .attr( "width", ctx.targetWidth )
          .attr( 'version', 1.1)
          .attr( 'xmlns', 'http://www.w3.org/2000/svg' )

        bg_color = rect_it( chart, 'white', 'white', 0, 0, ctx.targetWidth, ctx.height )

        g = chart.append('g')
          .attr('transform', 'translate(' + ctx.margin.left + ',' + ctx.margin.top + ')' )
          .attr('width', '90%' )
          

        chrtBgW = ctx.targetWidth - ctx.margin.right - ctx.margin.left
        chrtBgH = ctx.height - ctx.margin.top - ctx.margin.bottom
        chart_bg = rect_it( g, 'white', 'white', 0, 0, ( chrtBgW ), ( chrtBgH ) )

        xStretch = g.append( 'g' )
          .attr( 'class', 'hData' )
          .attr('original_width', ( chrtBgW ) )

        ctx.all_data = g.append( 'g' )
          .attr( 'class', 'hData' )
          .attr('original_width', ( chrtBgW ) )
        
        xStretch.append( 'g' )
          .attr( 'class', 'axis axis--x' )
          .attr( 'transform', 'translate(0, ' + ( chrtBgH ) + ')' )
          .call( d3.axisBottom( ctx.x ) )

        xLabelWidth = ( ctx.targetWidth - ctx.margin.left ) / 2
        xLabelHeight = ctx.height - ctx.margin.top

        xStretch.append( 'text' )
          .attr( 'transform',
                 'translate(' + xLabelWidth + ' ,' + xLabelHeight + ')' )
          .style( 'text-anchor', 'middle' )
          .text( chrtCtx.date )
                                
        g.append( 'g' )
          .attr( 'class', 'axis axis--y' )
          .call( d3.axisLeft(ctx.y).ticks( 2 ).tickFormat( (d)->
            label = ''
            switch d
              when 0
                label = chrtCtx.low
              when 6000
                label = chrtCtx.high
              
            return label
          ) )
        g.append( 'text' )
          .attr('transform', 'rotate(-90)' )
          .attr('y', 0 - ctx.margin.left )
          .attr('x', 0 - ( ctx.height/2 ) )
          .attr('dy', '1em' )
          .style('text-anchor', 'middle' )
          .text( chrtCtx.contributionLvl )


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

        ctx.user_count = index

        for id, stream of data.streams
          for sub_id, sub_stream of stream.sub_streams
            user_index = data.users[ sub_stream[ 'assessor_id' ] ][ 'index' ]

        #Create a close button
        lbw = 170 #legend base width
        lbh = 20 #legend base height

        # I AM HERE

        # Let's build the text
        titleX = ctx.targetWidth / 2
        titleY = 0 + ( ctx.margin.top / 2 )
        title = chart.append( "g" )
          .attr( 'class', 'title' )

        # Group label for individuals
        unless data.unitOfAnalysisCode == 'g'
          group_text = chrtCtx.group + data.groups[ Object.keys(data.groups)[ 0 ] ].group_name
          index = 1
          while( index < Object.keys( data.groups ).length )
            group_text+= chrtCtx.andGroup + data.groups[ Object.keys(data.groups)[ index ] ].group_name
            index++

          title
            .append( 'text' )
            .attr( 'x', 0 )
            .attr( 'y', 30 )
            .attr( 'text-anchor', 'middle' )
            .style( 'font-size', '10px' )
            .style( 'text-decoration', 'underline' )
            .text( group_text )

        #add analysis processing here
        block = unitOfAnalysisOpts[ data.unitOfAnalysisCode ]['ad']
        block.fcn( data, block.line_proc, ctx, block.code, data.comments )
        d3.selectAll( '.ad' ).attr( 'processed', true )



# http://bl.ocks.org/deanmalmgren/22d76b9c1f487ad1dde6
