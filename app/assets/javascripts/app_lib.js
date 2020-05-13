$(document).bind("mobileinit", function(){
  $.mobile.ajaxLinksEnabled = false;
  $.mobile.ajaxFormsEnabled = false;
  $.mobile.ajaxEnabled = false;
});

//Add some code to the page.
$(document).ready(function(){

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
  $("#responsesTable").tablesorter( {sortList: [[3,0]]});
  $("#course_table").tablesorter( {sortList: [[0,0]]} );
  $("#candidates_table").tablesorter( {sortList: [[0,0]]} );
  $("#history_table").tablesorter( {sortList: [[0,0]]} );

});


