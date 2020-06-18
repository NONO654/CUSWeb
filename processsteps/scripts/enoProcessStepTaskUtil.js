        

		function ProcessStep(data) {

            this.allMandTasksComplete = true;

        	    $.extend(this, data);
          }

          function ProcessTask(data) {
            
            this.calloutFlag        = false;
            this.parentCalloutFlag  = false;
            
              $.extend(this, data);
         }

