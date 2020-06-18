
//(c) Dassault Systemes, 2007, 2008

function htmlUnescape(value){
	return String(value)
	.replace(/&quot;/g, '"')
	.replace(/&#39;/g, "'")
	.replace(/&lt;/g, '<')
	.replace(/&gt;/g, '>')
	.replace(/&amp;/g, '&');
}

function htmlUnescapeForHostExport(value){
	return String(value)
	.replace(/&quot;/g, '"')
	.replace(/&#39;/g, "'")
	.replace(/&lt;/g, '<')
	.replace(/&gt;/g, '>')
	.replace(/&amp;/g, '&')
	.replace(/&slash;/g, '\\');
}

function makeRunJob (returndata, runApplication)
{
	jQuery.support.cors = true; 
	jQuery.ajax(
			{
				url : sessionStorage.eedURL,
				type : "POST",
				beforeSend: function (request)
				{
					
					if(runApplication=="ConfigureAndRun"){
						request.setRequestHeader("EEDTicket", 
								topWin.getWindowOpener().sessionStorage.ticket);
						request.setRequestHeader("Credentials", "");

						var decodeRunInfo = 
							htmlUnescape(topWin.getWindowOpener().sessionStorage.runINFO);
						request.setRequestHeader("RunInfo",decodeRunInfo);
						var decodeJobXML = 
							htmlUnescape(topWin.getWindowOpener().sessionStorage.encodedJobxml);

						var urlEncodedAppData = encodeURIComponent(decodeJobXML);
	                    request.setRequestHeader("ApplicationData", urlEncodedAppData);
						request.setRequestHeader("ResourceCredentials",
								 returndata.trim());
                    }
                    else
                    {
                        request.setRequestHeader("EEDTicket", ticket1);
                        request.setRequestHeader("Credentials", "");

                        var decodeRunInfo = htmlUnescape(runInfo);
							if(validClient)
							{
								//Adding Secure Station as the SubmissionHost in runInfo
								decodeRunInfo = decodeRunInfo.replace("submissionHost=\"\"","submissionHost=\""+stationName+"\"");
							}
                        request.setRequestHeader("RunInfo",decodeRunInfo);
                        var decodeJobXML = htmlUnescape(encodedJobXML1);
                        var urlEncodedAppData = encodeURIComponent(decodeJobXML);
                        request.setRequestHeader("ApplicationData", urlEncodedAppData);
    				    returndata = returndata.trim();
                        request.setRequestHeader("ResourceCredentials", returndata);
                    }
					
				},
				dataType : "xml",
				contentType : "text/plain; charset=utf-8",
				success : function (returndata,status,xhr)
				{
					if(runApplication=="ConfigureAndRun"){
						alert(topWin.getWindowOpener().sessionStorage.jobSubmitSuccessfulMessage);
						try{
							getTopWindow().getWindowOpener().getTopWindow().childWindow.closeWindow();
							}catch(ignore){
								// failed closing.TODO
							}
					}
					else
					{
					that.eedJobId = (returndata.getElementsByTagName("JobID")[0].childNodes[0]).textContent;
					//JQuery start
						if(validClient)
							{
								var stationClaim = 'https://dslauncher.3ds.com:' + successPort + '/SMAExeStation-REST/station/claim?jobids='+eedJobId;
           jQuery.ajax({ 
                url : stationClaim,
                type : "POST",
                cache:false,
                success : function(returndata, status, xhr) {
                },
                error : function(jqXHR, textStatus, errorThrown) 
                {
                alert("Sending job ID to station failed");
				}
            });
							}
						//JQuery end
						if(window.top && window.top.childWindows.length > 0){
							try{
								window.top.childWindows.forEach(function(win ){
									if(win && win.location && win.location.href)
								    	if(win.location.href.contains(objectID))
								        {
											console.log('alerting '+win.location.href);
											win.top.alert(jobSubmitSuccessfulMessage);
										}
								});
							}catch(e){
								alert(jobSubmitSuccessfulMessage)
							}

						}
						else{
							window.top.alert(jobSubmitSuccessfulMessage);
						}
						
					}
				},
				error :  function(  jqXHR,  textStatus,  errorThrown ){
					failTheJob(sessionStorage.mcsTicketUrl, 
							sessionStorage.failJobUrl,jqXHR.responseText);
					if(runApplication=="ConfigureAndRun"){
						getTopWindow().closeWindow();
					}

				}
			}
	);

}

function smaGetProperty(node, propertyName)
{
	if (node == null || propertyName == null)
	{
		return null;
	}

	// IE supports named properties
	if (propertyName in node)
	{
		return node[propertyName];
	}

	// Firefox (Mozilla) supports named attributes
	if (node.getAttribute)
	{
		return node.getAttribute(propertyName);
	}

	// unsupported browser?
	return null;
}


/*
    Utility function
*/
//Non blocking script loader
function loadScript(url, parentWindow, callback){
  var script = parentWindow.document.createElement("script")
  script.type = "text/javascript";

  if (script.readyState){  //IE
	  script.onreadystatechange = function(){
		  if (script.readyState == "loaded" ||
				  script.readyState == "complete"){
			  script.onreadystatechange = null;
			  callback();
		  }
	  };
  } else {  //Others
	  script.onload = function(){
		  callback();
	  };
  }

  script.src = url;
  parentWindow.document.body.appendChild(script);
}

function failTheJob(ticketUrl,failUrl,msg,csrfWSURL)
{
	if (msg == null || msg.length == 0)
		msg = "The Job has failed. Problem with the Execution Server.";
    jQuery.ajax
   (
   {
      url : ticketUrl,
      type : "POST",
      cache:false,
      success : function (returndata,status,xhr)
      {

					console.log("**** ticketUrl is successful");
					jQuery.ajax
					(
							{
								url : csrfWSURL,
								type : "GET",
								contentType : "text/plain",
								error:  function(err){
									console.log("**** " + err);
								},
								success: function(response){
									console.log("**** csrfWSURL is successful");
									var csrfKey = response;
          var urlL = failUrl;
          try
          {
              var myData;
              try{
              myData = String(
                  returndata.documentElement.childNodes[1].textContent);
              }
              catch(error)
              {
                  var myData1 = String(returndata);
                  var sMyData1 = myData1.split('\n');
                  var ticketStr = sMyData1[0].split("ticket=");
                  myData = ticketStr[1];
              }
              jQuery.ajax(
              {
                  url : urlL,
                  type : "POST",
                  data : { 'loginTicket' : myData},
                  dataType : "text",
													beforeSend: function(request){
														console.log("**** csrfKey is "+csrfKey);
														request.setRequestHeader('eno_csrf_token', csrfKey);
													},
                  success : function (returndata,status,xhr)
                  {
                	  alert (msg);
                  }
              }
              );
          }
          catch(error)
          {
              myData="ERROR"
          }

								}
							});
      }
  }
);

}

function failTheJobForSecureStation(ticketUrl,failUrl,csrfWSURL)
{
	jQuery.ajax
   (
   {
      url : ticketUrl,
      type : "POST",
      cache:false,
      success : function (returndata,status,xhr)
      {
					console.log("**** ticketUrl is successful");
					jQuery.ajax
					(
							{
								url : csrfWSURL,
								type : "GET",
								contentType : "text/plain",
								error:  function(err){
									console.log("**** " + err);
								},
								success: function(response){
									console.log("**** csrfWSURL is successful");
									var csrfKey = response;
          var urlL = failUrl;
          try
          {
              var myData;
              try{
              myData = String(
                  returndata.documentElement.childNodes[1].textContent);
              }
              catch(error)
              {
                  var myData1 = String(returndata);
                  var sMyData1 = myData1.split('\n');
                  var ticketStr = sMyData1[0].split("ticket=");
                  myData = ticketStr[1];
              }
              jQuery.ajax(
              {
                  url : urlL,
                  type : "POST",
                  data : { 'loginTicket' : myData},
                  dataType : "text",
													beforeSend: function(request){
														console.log("**** csrfKey is "+csrfKey);
														request.setRequestHeader('eno_csrf_token', csrfKey);
													},
                  success : function (returndata,status,xhr)
                  {
														console.log("**** urlL is successful");
                	  //alert (msg);
                  }
              }
              );
          }
          catch(error)
          {
              myData="ERROR"
          }
								}
							});
      }
  }
);

}         
