$(document).bind("mobileinit", function(){
  $.mobile.ajaxLinksEnabled = false;
  $.mobile.ajaxFormsEnabled = false;
  $.mobile.ajaxEnabled = false;
});

// This function enables copy course functionality
function popCopyPop( courseNumber, courseId, courseStartDate )
{
  $('#copyPop #number').val( courseNumber );
  $('#copyPop #id').val( courseId );
  $('#copyPop #orig_date').text( courseStartDate );
  $('#copyPop #start_date').val( courseStartDate );
  $('#copyPop').popup( 'open' );

}
// This function builds the trend graphs for student data responses
function init_me( obj, data ){
  var graph = d3.select( obj );
  var margin = {top: 10, right: 0, bottom: 10, left: 0};

  var width = +graph.attr( 'width' ) - margin.left - margin.right;
  var height = +graph.attr( 'height' ) - margin.top - margin.bottom;
  // X scale will fit all values from data[] within pixels 0-w
  var x = d3.scaleLinear().domain([0, data.length]).range([0, width]);
  var y = d3.scaleLinear().domain([0, 100]).range([height, 0]);

  graph.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var line = d3.line().curve( d3.curveMonotoneX )
      // assign the X function to plot our line as we wish
      .x(function(d,i) { 
        // return the X coordinate where we want to plot this datapoint
        return x(i); 
      })
      .y(function(d) { 
        // return the Y coordinate where we want to plot this datapoint
        return y(d); 
      })
      // Add the line by appending an svg:path element with the data
      // line we created above
      // do this AFTER the axes above so that the line is above the
      // tick-lines
      var path = graph.append("path")
        .attr("d", line(data))
        .attr("stroke", "steelblue")
        .attr("stroke-width", "1")
        .attr("fill", "none" )
        .style("opacity", .5);

      // From http://bl.ocks.org/benvandyke/8459843
      // get the x and y values for least squares
      var xSeries = d3.range(1, data.length + 1);
      var ySeries = data;

      var leastSquaresCoeff = leastSquares(xSeries, ySeries);

      // apply the reults of the least squares regression
      var x1 = 0;
      var y1 = leastSquaresCoeff[1];
      var x2 = data.length - 1;
      var y2 = leastSquaresCoeff[1] + (data.length * leastSquaresCoeff[0]);
      var trendData = [[x1,y1,x2,y2]];

      var trendLineColor = "green";
      if( leastSquaresCoeff[ 0 ] < 0 ){
        trendLineColor="red";
      }
      var trendline = graph.selectAll(".trendline")
        .data(trendData);
      trendline.enter()
        .append("line")
        .attr("class", "trendline")
          .attr("x1", function(d) { return x(d[0]); })
          .attr("y1", function(d) { return y(d[1]); })
          .attr("x2", function(d) { return x(d[2]); })
          .attr("y2", function(d) { return y(d[3]); })
          .attr("stroke", trendLineColor )
          .attr("stroke-width", 2);
}

// returns slope, intercept and r-square of the line
function leastSquares(xSeries, ySeries) {
  var reduceSumFunc = function(prev, cur) { return prev + cur; };
  
  var xBar = xSeries.reduce(reduceSumFunc) * 1.0 / xSeries.length;
  var yBar = ySeries.reduce(reduceSumFunc) * 1.0 / ySeries.length;

  var ssXX = xSeries.map(function(d) { return Math.pow(d - xBar, 2); })
    .reduce(reduceSumFunc);
    
  var ssYY = ySeries.map(function(d) { return Math.pow(d - yBar, 2); })
    .reduce(reduceSumFunc);
      
  var ssXY = xSeries.map(function(d, i) { return (d - xBar) * (ySeries[i] - yBar); })
    .reduce(reduceSumFunc);
      
  var slope = ssXY / ssXX;
  var intercept = yBar - (xBar * slope);
  var rSquare = Math.pow(ssXY, 2) / (ssXX * ssYY);
    
  return [slope, intercept, rSquare];
}


//Add some code to the page.
$(document).ready(function(){
  var concept_url = '/bingo/concepts_for_game/0.json?search_string='
  var apMinChars = 3;
  $(".awesomplete-ajax").each( function( index, conceptField ) {
    var ap = new Awesomplete( conceptField, {
      minChars: apMinChars,
      autoFirst: true
    } );
    ap.list = [ ]
    $( conceptField ).data( "ac", ap );
  });

  $(".awesomplete-ajax").on( "keyup", function(e){
    var code = (e.keyCode || e.which);
    if( code === 37 || code === 38 || code === 39 || code === 40 ||
        code === 27 || code === 13 || this.value.length < apMinChars )
    {
      //reserved
    }
    else
    {
      var x = this;
      $.getJSON( concept_url + this.value, function (data)
      {
        var list = [ ];
        $.each( data, function( key, value ) {
          list.push( value.name );
        } );
        $(x).data( "ac" ).list = list;
      });
    }

  });


  $("#calc_diversity").click(function() {
    var emails;
    emails = $("#emails_for_ds").val( );
    url = "/infra/diversity_score_for?emails=";
    url += encodeURIComponent( emails );
    $.getJSON(url, function(data) {
      var i, user_list;
      i = 0;
      user_list = "<ol>"
      while (i < data.found_users.length){
        var user = data.found_users[ i ];
        user_list += "<li><a href='mailto:" + user.email + "'>";
        user_list += user.name; 
        user_list += "</a></li>";
        i++;
      }
      user_list += "</ol>";
      console.log( user_list );
      $("#users").html( user_list );
      $("#diversity_score").html( data.diversity_score );
      $("#results").show( );
    });
    return false;
  });

  $(".country_select").change(function() {
    var country_code, state_select, url;
    country_code = $(this).val();
    url = "/infra/states_for_country/" + country_code;
    $.getJSON(url, function(data) {
      state_select = $("#user_home_state_id");
      var i, newOption, results;
      i = void 0;
      newOption = void 0;
      $(state_select).empty();
      i = 0;
      results = [];
      while (i < data.states.length) {
        newOption = new Option( data.states[i].name,
              data.states[i].id, i < 1, i < 1 );

        $(state_select).append(newOption);
        results.push(i++);
      }
      return results;
    });
    return $(state_select).selectmenu('refresh', true);
  });

  /*
    This code (next two functions) enacts the 
    JavaScript-based reveal.
    It is game-able in case anyone truly cares, but 
    hopefully the text does not entice participants 
    to do so.
  */
  $("input:radio[name='instructor_conclusion[behavior_id]']").change(function(){
    $("#reveal").removeClass( 'ui-state-disabled' );
  });

  $("#reveal").click(function(){
    if( $("input:radio[name='instructor_conclusion[behavior_id]']").is(":checked") )
    {
      var behavior = null;
      $("input:radio[name='instructor_conclusion[behavior_id]']").attr('disabled',true );
      behavior = $("input:radio[name='instructor_conclusion[behavior_id]']").val( );
      $("<input type='hidden' name='instructor_conclusion[behavior_id]' value='" + behavior + "'/>" )
        .appendTo("#new_instructor_conclusion");
      $("#reveal_panel").show( );
      $("#reveal").attr('disabled', true );
      $("#interested").hide( );
      $("#final_submit_panel").show( );
    }
  });


  /*
    Show/hide the alternative behavior text panel (for diagnoses)
  */
  $("input:radio[name='diagnosis[behavior_id]']").change(function(){
    if ($("input:radio[name='diagnosis[behavior_id]']:checked").val() == '6')
    {
      $("#other_name_panel").show();
    }
    else
    {
      $("#other_name_panel").hide();
    }
  });

  /*
    Show/hide the alternative behavior text panel (for reactions)
  */
  $("input:radio[name='reaction[behavior_id]']").change(function(){
    if ($("input:radio[name='reaction[behavior_id]']:checked").val() == '6')
    {
      $("#other_name_panel").show();
    }
    else
    {
      $("#other_name_panel").hide();
    }
  });

  /*
    Show/hide the group options
  */
  $("input:checkbox[id=bingo_game_group_option]").change(function(){
    if ($("input:checkbox[id=bingo_game_group_option]:checked").length > 0)
    {
      $("table #group_options").show();
    }
    else
    {
      $("table #group_options").hide();
    }
  });

  $("#basicTable").tablesorter( {sortList: [[0,0],[1,0]]} );
  $("#groups_table").tablesorter( {sortList: [[0,0],[1,0]]} );
  $("#bingo_table").tablesorter( {sortList: [[0,0]]} );
  $("#projects_table").tablesorter( {sortList: [[0,0]]} );
  $("#experiences_table").tablesorter( {sortList: [[0,0]]} );
  $("#course_table").tablesorter( {sortList: [[0,0]]} );
  $("#candidates_table").tablesorter( {sortList: [[0,0]]} );
  $("#concepts_table").tablesorter( {sortList: [[0,0]]} );
  $("#history_table").tablesorter( {sortList: [[0,0]]} );

  $( "[data-role='header'], [data-role='footer']" ).toolbar();

});


