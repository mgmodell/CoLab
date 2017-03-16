$(document).bind("mobileinit", function(){
  $.mobile.ajaxLinksEnabled = false;
  $.mobile.ajaxFormsEnabled = false;
  $.mobile.ajaxEnabled = false;
});

//Add some code to the page.
$(document).ready(function(){

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
    Show/hide the alternative behavior text panel
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
    Show/hide the alternative behavior text panel
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

  //$("#basicTable").tablesorter( {sortList: [[0,0],[1,0]]} );

  $( "[data-role='header'], [data-role='footer']" ).toolbar();

});


