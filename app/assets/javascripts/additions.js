$(function() {
 // Handler for .ready() called.
 $(".submit_player").click(function(e){
   e.preventDefault();
   var id = $("#player").val();
   var btype = this.id.replace("_",'');
   $("#" + id.replace(/\s+/g, '').replace(/\./g, '')).attr("class","grey_out_" + btype);
   var url = this.form.action;
   $.ajax({
     type: "GET",
     url: url,
     data: {name: id,status:btype}, // serializes the form's elements.
     success: function(data){
       if(btype == "myteam")
         $("#table_myteam").append(data.pstring);
       $('.success_bar')[0].innerHTML = "success";
       $('.success_bar').fadeIn(1000).delay(1000).fadeOut(2000);
     }
   });
   return false;
 });

});

