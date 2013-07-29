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

  var count = 180;
  var counter;

  $("#timerbtn").click(function(){
    clearInterval(counter);
    count = 5;//$("#count").val();
    counter = setInterval(timer, 1000); //1000 will  run it every 1 second
  })

  function timer(){
    count=count-1;
    if (count <= 0)
    {
       clearInterval(counter);
       //counter ended, do something here
       var number = Math.floor((Math.random()*2)+1);
       $("#timer")[0].innerHTML = "00";
       //var snd = new Audio("Donkey"+number+".mp3"); // buffers automatically when created
       var snd = new Audio("Donkey21.mp3")
       snd.play();
       return;
    }

    //Do code for showing the number of seconds here
    $("#timer")[0].innerHTML = count;

  }

});

