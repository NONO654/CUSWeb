 <%-- emxJobProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxJobProcess.jsp.rca 1.1.5.4 Wed Oct 22 15:48:07 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript">
  addStyleSheet("emxUIJob");
</script>

<%
    int refreshInterval = Integer.parseInt(UINavigatorUtil.getSystemProperty(application,"emxFramework.BackgroundProcess.TimeIntervalToCheckJobStatus"));
    String objectId=emxGetParameter(request,"objectId");
     String submitURL = emxGetParameter(request,"submitURL");
    StringBuilder progressBuffer =new StringBuilder();
	String targetLocation  = emxGetParameter(request, "targetLocation");
	String targetType  = emxGetParameter(request, "targetType");

    //To manually show progress bar completed when job status is Completed
    for(int index=0;index<106;index+=2)
    {
        progressBuffer.append("|");
    }
  
%>
<div id="monitorprogress">
<jsp:include page="emxJobProcessInclude.jsp">
<jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
<jsp:param name="submitURL" value="<%=XSSUtil.encodeForJavaScript(context, submitURL)%>"/>
</jsp:include>
</div>

<script language="JavaScript">

function refreshJobPageHeader(){
	var RefreshButton = top.$(".refresh button");
	if(RefreshButton){
		var cEvent  = top.$.Event("click");
    		cEvent.data = {"headerOnly":true};
    		if(isIE){
			setTimeout(function(){
    				RefreshButton.parent().trigger(cEvent);
			}, 10);
		}else{
			RefreshButton.parent().trigger(cEvent);
		}
	}
}

function getChannel(channelName)
{
	var tempContainer = null;
	var tempObjPortal = null;
	var tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"portalDisplay");
	tempObjPortal  = tempListDisplayFrame.objPortal;
	if(tempObjPortal == null ){
            if(parent.objPortal){
		        tempObjPortal = parent.objPortal;
            }else if(parent.parent.objPortal){
                tempObjPortal = parent.parent.objPortal;
            }
	}
	for(var i = 0;i< tempObjPortal.rows.length;i++){
	    for(var j = 0;j< tempObjPortal.rows[i].containers.length;j++){
	        if(tempObjPortal.rows[i].containers[j].channelName == channelName){
	            tempContainer = tempObjPortal.rows[i].containers[j];
	            break;
	        }
	    }
	}
    var channel = null;
    if(tempContainer != null)
    {
		for(var i = 0;i< tempContainer.channels.length;i++){
	        channel = tempContainer.channels[i];
	    }
    }

    return channel;
}

var refreObj = setInterval("refreshFrame();refreshJobPageHeader()",<%=refreshInterval%>);
var tl = '';
<%
if(targetLocation != null && !"".equals(targetLocation)){
%>
    tl = '<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>';
<%
}
%>
function refreshFrame()
{
        var divObj=document.getElementById("monitorprogress");
		var timestamp = (new Date()).getTime();
        var str = emxUICore.getData("emxJobProcessInclude.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&timestamp=" + timestamp +"&submitURL=<%=XSSUtil.encodeForJavaScript(context, submitURL)%>");
        if(str.indexOf("Status=Completed") != -1 ){
        	URL = str.substring( str.indexOf("URL")+4 , str.indexOf("</table>") ) ;
        	
        	if( (tl != '') && (str.indexOf("Status=Completed") != -1))
        	 { 
        	      if("<%=XSSUtil.encodeForJavaScript(context,targetType)%>" == "channel"){//XSSOK
	        	      var channel = getChannel("<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>");
                  clearInterval(refreObj);
	              	  channel.data.src =URL;
              	  } else {
              	     var frm = findFrame(getTopWindow(), "<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>");
              	     frm.document.location.href = URL;
              	  }
                  var divBarObj=document.getElementById("progressBar");
                	//XSSOK
                	divBarObj.innerHTML="<%=progressBuffer%>";
        	  }
        	  else
        	  {
                 window.parent.location.href = URL; 
        	  }
        }else{
        
        divObj.innerHTML=str;
}
}


function abortPage(objectId)
{
   document.jobFrm.objectId.value=objectId;
   document.jobFrm.submit();
}

</script>
<form name="jobFrm" action="emxJobRequestAbort.jsp">
<input type="hidden" name="objectId" />
</form>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
