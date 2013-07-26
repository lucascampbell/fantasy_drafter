$(function() {
 // Handler for .ready() called.
 $(".submit_player").click(function(e){
   e.preventDefault();
   var id = $("#player").val();
   $("#" + id.replace(/\s+/g, '')).attr("class","grey_out");
   var url = this.form.action;
   //$("#" + )
   $.ajax({
     type: "GET",
     url: url,
     data: {name: id}, // serializes the form's elements.
     success: function(data){
        alert(data.player);
     }
   });
   return false;
 });

$('.typeahead').typeahead();

$('#player_search').typeahead();
});

