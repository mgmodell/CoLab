$(document).bind("mobileinit", function(){
   $.mobile.ajaxEnabled = false;
});

$(document).on("pageinit", function( ){
   $("#pupupTutorial iframe")
   .attr( "width", 0 )
   .attr( "height", 0 );

   $("#pupupTutorial").on({
      pupupbeforeposition: function( ){
         var size = scale( 655, 495, 15, 1 ),
         w = size.width,
         h = size.height;

         $( "#pupupTutorial iframe" )
         .attr( "width", w )
         .attr( "height", h );
      },
      popupafterclose: function( ){
         $("#pupupTutorial iframe")
         .attr("width", 0)
         .attr("height", 0);
      }
   });
});


var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-18765067-4']);
_gaq.push(['_trackPageview']);

(function() {
   var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
   ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

