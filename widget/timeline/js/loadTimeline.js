function (){
	var myObj = {
		html: function() { return jQuery('<div id="'+ this.getId() +'" class="enovia-timeline-target"></div>');},
		getId: function() { return "dsTL_" + new Date().getTime()},
		draw: function(data){
				console.log('drawing from custom script');
				var ctnr = this.html();
				var testTL = new Timeline(data);
      			testTL.draw(jQuery(ctnr));
 
				return ctnr;
			}
	};
	return myObj;
}()
