<%--
  ConfigurationRuleCreatePreProcess.jsp
  
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%
	try{
			
			String strobjectId = (String)emxGetParameter(request, "objectId");
			String strparentOID = (String)emxGetParameter(request, "parentOID");
			String strproductID = (String)emxGetParameter(request, "productID");
        	String strtitlefieldValue = (String)emxGetParameter(request, "TitlefieldValue");
        	String strtitlefield = (String)emxGetParameter(request, "Title");
			String strDescriptionfieldValue = (String)emxGetParameter(request, "DescriptionfieldValue");
			String strDescription = (String)emxGetParameter(request, "Description");
			String timeStamp = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "timeStamp"));
			
			System.out.println(strtitlefieldValue + strDescriptionfieldValue + strDescription);
			System.out.println(strobjectId+strparentOID+strproductID+strtitlefieldValue+strDescriptionfieldValue + strtitlefield);
			String strObjectPID = "";
			if(strobjectId != null){
				DomainObject domProduct  = new DomainObject(strobjectId);
		 		 strObjectPID = domProduct.getInfo(context,"physicalid");
			}
			
			String strProductPID = "";
			if(strproductID != null){
				DomainObject domProduct  = new DomainObject(strproductID);
				strProductPID = domProduct.getInfo(context,"physicalid");
			}
			
			if(strtitlefield == null){
				strtitlefield = "";
			}
			if(strDescription == null){
				strDescription = "";
			}
			//Update only if needed
			if( !strDescriptionfieldValue.equals(strDescription) || !strtitlefieldValue.equals(strtitlefield)){
%>
			<script language="javascript" type="text/javaScript">
			//Function to update Rule Title and Desc
			function updateRuleTitleDesc(strTitleValue, strDescValue , rulePID , productPID ){
				var r = null;
			        if (window.XMLHttpRequest) {
			            r = new XMLHttpRequest()
			        } else {
			            r = new ActiveXObject(Microsoft.XMLHTTP)
			        }
				var p = "../resources/modeler/configurationrule/pid:" + rulePID;
		        
		        var q = {};
		        q.version = "1.0.1";
		        q.configurationRule = {};
		        q.description = strDescValue;
		        q.configurationRule.attributes = {};
		        q.configurationRule.attributes.Title = strTitleValue ;
		        q.cloneSharedRuleForObj = productPID ;
		        q = JSON.stringify(q);
		        
		        r.open("PUT", p, false);
		        r.setRequestHeader("Content-Type", "application/ds-json");
	 	        r.send(q);
		        if (r.status === 200 && r.readyState === 4) {	            
		            if (r.responseText != "{}"){	
		            	var resp = JSON.parse(r.responseText);
		            	return resp;
		            }else{
		            	return null;
		            }      
		        } else {
		        	var resp = JSON.parse(r.responseText);
		        	if(resp.errorMessage){
		        		alert(resp.errorMessage);
		        	}
		        } 
			}

	       
	        var productPID = '<%=strProductPID %>' ;
	        var rulePID = '<%=strObjectPID %>' ;
	        var strTitleValue = '<%= XSSUtil.encodeForJavaScript(context , strtitlefield) %>';
	        var strDescValue = '<%= XSSUtil.encodeForJavaScript(context , strDescription) %>';

            var contentFrame ;
            var topWindow = getTopWindow();
			var formUrl = null;
            	
				contentFrame = getFormContentFrame('null');
				if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
					getTopWindow().opener.getTopWindow().RefreshHeader();
                    getTopWindow().opener.getTopWindow().deletePageCache();
				}else if(getTopWindow().RefreshHeader){
					getTopWindow().RefreshHeader();
                    getTopWindow().deletePageCache();
				}

				if(contentFrame){
				    formUrl = contentFrame.location.href;
				    formUrl = changeURLToViewMode(formUrl);
				}	
        	
			//Call webService 
        	var resp = updateRuleTitleDesc(strTitleValue,strDescValue,rulePID,productPID);
        	if(resp!=null){
        		if( resp.details != "undefined" && (("pid:"+rulePID) != resp.details.id)){
            		
        			//Modify URL to have new Object Id
        			var newURL = removeObjectIDParam(formUrl);
                	var argParts = newURL.split("?");
                	var newPID = resp.details.id.substring(4);
                	newURL = argParts[0] + "?&objectId=" + newPID + "&" + argParts[1];
                	newURL = newURL.replace("emxForm.jsp","emxTree.jsp");
                	contentFrame = topWindow.findFrame(getTopWindow(), "content");
            		if(contentFrame == null){
            		contentFrame = getFormContentFrame('null');
            		}
        			if(contentFrame.frameElement){
        				//modify BreadCrumb
        				topWindow.bclist.setPosition(topWindow.bclist.currentPosition()-1);
        				//Reload Page
        				contentFrame.location.href =newURL;
        			}
            	}else {
            		contentFrame = getFormContentFrame('null');
            		var newURL = changeURLToViewMode(contentFrame.location.href);
            		contentFrame.location.href = newURL ;
            	}
        	}else{
        		contentFrame = getFormContentFrame('null');
        		var newURL = changeURLToViewMode(contentFrame.location.href);
        		contentFrame.location.href = newURL ;
        	}
			</script>
<%
			}else{
%>
			<script>
				
					contentFrame = getFormContentFrame('null');
            		var newURL = changeURLToViewMode(contentFrame.location.href);
            		contentFrame.location.href = newURL ;
				
			</script>
<%				
			}
			
	}catch(Exception ex)
	{
		%>
<script language="javascript" type="text/javaScript">
	     	alert("<%=ex.getMessage()%>");                 
	    </script>
<% 
	}
%>
