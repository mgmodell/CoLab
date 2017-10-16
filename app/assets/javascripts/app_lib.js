$(document).bind("mobileinit", function(){
  $.mobile.ajaxLinksEnabled = false;
  $.mobile.ajaxFormsEnabled = false;
  $.mobile.ajaxEnabled = false;
});

//Add some code to the page.
$(document).ready(function(){
  var concept_url = '/bingo/concepts/0.json?search_string='
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

  $( "[data-role='header'], [data-role='footer']" ).toolbar();

});


