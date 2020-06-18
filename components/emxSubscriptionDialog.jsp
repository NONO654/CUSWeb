<%-- emxSubscriptionDialog.jsp
   Copyright (c) 2000-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSubscriptionDialog.jsp.rca 1.4.7.6 Tue Oct 28 23:01:05 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<html>
<head>
<title>ENOVIA</title>
<%
	StringBuffer sfb = new StringBuffer();
	boolean appendAmp = false;
	String sSubmitAction = "";
	Enumeration enumParamNames = request.getParameterNames();
	while(enumParamNames.hasMoreElements()) {
	    String paramName = (String) enumParamNames.nextElement();
	    String paramValue = request.getParameter(paramName);

	    if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) && !"objectId".equalsIgnoreCase(paramName)) {
	        if(appendAmp)
	        	sfb.append("&");
	        else
	        	appendAmp = true;

	        sfb.append(XSSUtil.encodeForURL(context, paramName));
	        sfb.append("=");
	        sfb.append(XSSUtil.encodeForURL(context, paramValue));
	    }
        if (paramName.equals("submitAction") && paramValue != null) {
            sSubmitAction = paramValue;
        }
	}

	String objectId = "";
	 //Added by LVC for IR-057144V6R2011x    
    String strType = "";
	String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
    if(tableRowIdList == null || tableRowIdList.length <= 0) {
    	objectId = emxGetParameter(request, "objectId");
    	 //Added by LVC for IR-057144V6R2011x    
    	
    	   DomainObject domainObj = DomainObject.newInstance(context,objectId);
    	   strType = domainObj.getInfo(context,DomainConstants.SELECT_TYPE);
    }
    else
    {
        tableRowIdList = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(tableRowIdList);
        objectId = com.matrixone.apps.common.util.ComponentsUIUtil.arrayToString(tableRowIdList, ",");
    }
   String strLanguage = request.getHeader("Accept-Language");
  
	String suiteKey = emxGetParameter(request, "suiteKey");
	String targetLocation = emxGetParameter(request, "targetLocation");
	String strHelpMarker = emxGetParameter(request,"HelpMarker");	
	String helpDone=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.Button.Done");
	String helpCancel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.Button.Cancel");
	String pageHeader = "";


	if(objectId.indexOf(",") >= 0)
	{
		pageHeader = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.MultiObjectPageHeader");
	}
	else
	{
		if(strType.equalsIgnoreCase(DomainConstants.TYPE_MESSAGE))
		{
			  pageHeader = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.SingleObjectPageHeader");
		}
		else
		{
			pageHeader = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.SingleObjectPageHeaderAllTypes");
		}
	}
	pageHeader = UINavigatorUtil.parseHeader(context, pageContext, pageHeader, objectId, "Framework", strLanguage);
    if(pageHeader == null || pageHeader.trim().length() == 0)
    {
    	pageHeader = "Subscription Options";
    }

	session.setAttribute("strObjectIds", objectId);
    
    String subURL = UINavigatorUtil.encodeURL("emxSubscriptionBody.jsp?"+sfb.toString());    
    String pageTitle = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.MultiObjectPageHeader");
   
%>

  <title><%=XSSUtil.encodeForHTML(context, pageTitle) %></title>

  <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
  <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
  <script language="JavaScript" type="text/JavaScript">
	addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIDialog");  
  </script>
  <%@include file = "../emxStyleDefaultInclude.inc"%>
  <%@include file = "../emxStyleDialogInclude.inc"%>

  <script language="javascript">
  function readjustBodytop(){
		var phd = document.getElementById("pageHeadDiv");
		var dpb = document.getElementById("divPageBody");
		if(phd && dpb){
			var ht = phd.clientHeight;
			if(ht <= 0){
				ht = phd.offsetHeight;
			}
			dpb.style.top = ht + "px";
		}
	}
  
  function onSubmit(){
		var sAllIds = "";
		var sPushedIds = "";
		var sPushedIds = "";
      	var bodyFrame = findFrame(getTopWindow(), "subscriptionOptions");
      	var formobj = bodyFrame.document.formEvents;
		for( var i = 0; i < formobj.elements.length; i++ ){
		  if ((formobj.elements[i].type == "checkbox") && (!formobj.elements[i].checked)) {
			  if(formobj.elements[i].name == "chkUnSubscribeEvent"){
				sAllIds += formobj.elements[i].value + ";";
			  }
			  if(formobj.elements[i].name == "chkUnSubscribePushEvent"){
				sPushedIds += formobj.elements[i].value + ";";
			  }
		  }
		}
		formobj.sUnsubscribedEventIds.value = sAllIds;
		formobj.sUnsubscribedPushEventIds.value = sPushedIds;
		formobj.submitAction.value = "<%=XSSUtil.encodeForJavaScript(context, sSubmitAction)%>";
		formobj.target = "formEditHidden";
		formobj.action="emxSubscriptionProcess.jsp";
		formobj.submit();
		return;
    }

    function windowClose()
    {
<%
		if(targetLocation != null && "slidein".equalsIgnoreCase(targetLocation)){
%>
			getTopWindow().closeSlideInDialog();
<%
		} else {
%>
    		    	window.closeWindow();
<%
		}
%>    	
    }

  </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>

<body onload="javascript:readjustBodytop();" class="dialog">
  <div id="pageHeadDiv">
	  	<table>
			<tr>
				<td class="page-title">
					<h2><%=XSSUtil.encodeForHTML(context,pageHeader)%></h2>
				</td>
			</tr>
		</table>    
	    <jsp:include page = "../common/emxToolbar.jsp" flush="true">
			<jsp:param name="toolbar" value=""/>
			<jsp:param name="suiteKey" value="<%=suiteKey%>"/>
			<jsp:param name="PrinterFriendly" value="false"/>
			<jsp:param name="export" value="false"/>
			<jsp:param name="helpMarker" value="<%=strHelpMarker%>"/>
			<jsp:param name="categoryTreeName" value="null"/>
	    </jsp:include>
  </div> <!-- #pageHeadDiv -->
    <div id="divPageBody">
    	<div style="height: 99%"> 
          <iframe name="subscriptionOptions" src="<%=subURL%>" width="99%" height="99%"  frameborder="0" border="0"></iframe>
          <iframe class="hidden-frame" name="formEditHidden" src="emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>
        </div>
    </div>
	<div id="divPageFoot">
		<div id="divDialogButtons" >
		  <table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
			  <tr>
                <td id="msgTD" align="left"></td>
				  <td align="right">
					  <table border="0" cellspacing="0">
						  <tr>
							  <td><a href="#" onClick="onSubmit()"><button class="btn-primary"><%=XSSUtil.encodeForHTML(context, helpDone)%></button></a></td>
							  <td>&nbsp;</td>
							  <td><a href="#" onClick="windowClose()"><button class="btn-default"><%=XSSUtil.encodeForHTML(context, helpCancel)%></button></a></td>
						  </tr>
					  </table>
				  </td>
			  </tr>
		  </table>
		</div>
	</div>
</body>
</html>
