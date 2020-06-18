          function resizeIframe(obj) 
          {
            var doc   = obj.contentDocument? obj.contentDocument: obj.contentWindow.document;               
            var height  = getDocHeight(doc);
            obj.style.height = height + 'px';
          }

          function getDocHeight(doc) 
          {
            doc         = doc || document;
            var body    = doc.body, html = doc.documentElement;
            var height  = Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight );
                  
            return height;
          }

          function getDelimitedStringFromList(stepObjectIds, delimiter){
              var arrayIn = stepObjectIds;
              if(arrayIn.length > 1){
                  var arrayOut = arrayIn.toString().split(",");
                  arrayIn = arrayOut.join(delimiter);
              }
              return arrayIn;
          }

          function getNonNullValue(value){
              if(value == null){
                  return "";
              }
              else{
                  return value;
              }
          }

          function getStepTitleImage(stepTitleImage){
              if(statusIconImage == null){
                  return "";
              }
              else{
                  stepTitleImage = "<img src=\"../common/images/"+stepTitleImage+"\" width=\"16px\" height=\"15px\" alt=\"\"/>";
              }
          }

          function getStatusIcon(processTask, isActiveStep, isElapsedStep, disabled) {

            var taskStatus      = processTask.status;
            var taskType        = processTask.taskType;
            var isFutureStep    = "false";
            var statusTag       = "";

            if(isActiveStep==="false" && isElapsedStep==="false")
                isFutureStep = "true";

            if (taskType==="Optional") {
                if(isFutureStep==="true") {
                    statusTag = "iconcircle future icon";
                } else if (taskStatus==="OK") {
                    statusTag = "iconcircle complete checked icon";
                } else if(taskStatus==="hold") {
                    statusTag = "iconcircle future icon";
                } else {
                    statusTag = "iconcircle active alert-iconcircle icon";
                }
            } else if (isElapsedStep==="true") {
                statusTag = "iconcircle complete checked icon";
            } else if (isActiveStep==="true") {
                if (taskStatus==="OK") {
                    statusTag = "iconcircle complete checked icon";
                } else if (taskStatus==="WIP") {
                    statusTag = "iconcircle pendingArrow icon";
                } else if (taskStatus==="NA" || taskStatus==="hold") {
                    statusTag = "iconcircle future icon";
                } else if (taskStatus==="KO") {
                    statusTag = "iconcircle stopped error icon";
                } else if (taskStatus==="stop") {
                    statusTag = "<div class='octagonStatus'><div class='octagon'></div></div>";
                }
            } else {
                statusTag = "iconcircle future icon";
            }
            
            if (isActiveStep==="true" && taskStatus==="stop")
                return statusTag;

            if(disabled)
                statusTag += " disabled";

            return "<div class='{0}'></div>".format(statusTag);
          }

          function getTitleTag(title, className, formattedDate){
              if(className != null && formattedDate != null){
                  return title+"&nbsp;&nbsp;<div class=\""+className+"\">"+formattedDate+"</div>";
              }
              else{
                  return title;
              }
          }

          if(!String.prototype.format) {
            String.prototype.format = function() {
              var args = arguments;
              return this.replace(/{(\d+)}/g, function(match, number) { 
                return typeof args[number] != 'undefined'? args[number] : match
                ;
              });
            };
         }

  		
      	function FileDropSelectHandlerColumn(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes,directions,typesStructure,validator) {


var dragobjectID=e.dataTransfer.getData("DragObjectId");

if(dragobjectID!=null && dragobjectID!="")
{
	var isReferenceDocument=e.dataTransfer.getData("Reference Document");
var dropdiv=document.getElementById(idDiv);
var reference=dropdiv.getAttribute("reference"); 
	if(isReferenceDocument=="true" &&reference )
	{

		var objId=dropdiv.getAttribute("objectid");



  UWA.Data.request(getTopWindow().myAppsURL+"/resources/processStepsReferential/ReferentialService/addReferenceDocument", {
        		    type:"json",
        		    method:"POST",
        		    data:"{\"objectId\":\""+objId+"\",\"referenceObjectId\":\""+dragobjectID+"\"}",
        		    headers: {
        		        'Accept': 'application/json',
        		        'Content-Type': 'application/json',
        		    },
        		onComplete : function(jsonObject) {
				dropdiv.className="dropAreaColumn";
        			
			},
			onFailure : function(jsonObject) {
				dropdiv.className="dropAreaColumn";
        			
			},


			});
			
		
	}
	else
	{	
		dropdiv.className="dropAreaColumn";
	}
}
else
{
      		functionOne(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes, directions,
      				typesStructure,'');
      		functionTwo(idDiv) ;
                 
      	}
      	
      	
      	}
      	
      	
      	var functionOne= function(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes, directions,
      			typesStructure,validator)
      	{
      		var r = $.Deferred();
      		
      		FileSelectHandler(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes, directions,
      				typesStructure,validator);
      		 return r;
      	};
      		
      	var functionTwo= function(idDiv) 
      	{
      		onfileDrop(idDiv);
      	};
      	
      	function onDragLeaveFile(event,dragId)
      	{
      		FileDragHoverColumn(event, dragId);
      		//setTimeout(fileDropMain(dragId),500)
      		
      	}
      	function onfileDrop(dragId){
      		
      		var aa= document.getElementById(dragId);
      		//aa.className= "dropAreaColumn";
aa.className= "dropProgressColumn";
      		var Children  = document.getElementById(dragId).children;
      		 
      	    for (i = 0; i <= Children.length - 1; i++) {
      	    	Children[i].parentNode.removeChild(Children[i]);
      	    }
      	    Children  = document.getElementById(dragId).children;
      	    for (i = 0; i <= Children.length - 1; i++) {
      	    	Children[i].parentNode.removeChild(Children[i]);
      	    
      	    }
      	   
      	  //setTimeout(refreshFrame,500);
      	   
      	}
      	function refreshFrame()
      	{
      	    var frameDisplay=findFrame(getTopWindow(),"detailsDisplay");
      	    frameDisplay.location.href=frameDisplay.location.href;
      	}
      	
        function getObjectHref(objectId, label)
		{
		    return "<a href='#' onclick=\"openViewPage('{0}');return false\">{1}</a>".format(objectId, label);
        }
        
      	

