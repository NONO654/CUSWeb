<%@page import="java.util.Set"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../components/emxComponentsNoCache.inc"%>
<%@include file="../components/emxComponentsUtil.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
String strMode = emxGetParameter(request,"mode");
String strLanguage = request.getHeader("Accept-Language");
String strEnablePush = emxGetParameter(request, "enablePush");
String strHelpMarker = emxGetParameter(request, "HelpMarker");
String bPortalMode = emxGetParameter(request, "portalMode");
boolean bEnablePush = "true".equalsIgnoreCase(strEnablePush) ? true : false;
String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
String strObjectId = emxGetParameter(request,"objectId"); 

if(strMode==null || "".equals(strMode) || "null".equals(strMode)){
	
	StringBuilder sbHref = new StringBuilder(256);
	sbHref.append("../common/emxIndentedTable.jsp?table=APPSubscriptionTable&program=emxCommonSubscription:getSubscriptionEventsTableData&selection=multiple&toolbar=APPSubscriptionMenu&header=emxComponents.header.Subscription&showClipboard=false&showPageURLIcon=false&customize=false&multiColumnSort=false&objectCompare=none&displayView=details&suiteKey=Components&rowGrouping=false&autoFilter=false&Export=false&showRMB=false&portalMode="+bPortalMode+"&HelpMarker="+strHelpMarker);
	sbHref.append("&objectId=");
	sbHref.append(strObjectId);
	if(bEnablePush){
		sbHref.append("&enablePush=true&expandProgram=emxCommonSubscription:getSubscribers");
	}else{
		sbHref.append("&enablePush=false");
	}
	response.sendRedirect(sbHref.toString());
}
else if(strMode.equals("Subscribe"))
{	
	%>
	<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
	<%
	try{
		
		HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
	
		StringList slResourceTokens=null;
		String strTokenId="";
		StringList slEvents=new StringList();
		if((null!=strObjectId && !"null".equals(strObjectId)) && (null!=strTableRowIds && strTableRowIds.length > 0))
		{
		  boolean flag = true;

	      for(String entry : strTableRowIds) {
		     if(!entry.contains(strObjectId)){
			      flag = false;
		          break;
		     }
	       }

	      if(flag) {		
		  %>
			<script language="javascript" type="text/javaScript">
			var arrIds=[];
			<%
			String strUserId = PersonUtil.getPersonObjectID(context);
			for(int i=0;i<strTableRowIds.length;i++)
			{
				slResourceTokens = FrameworkUtil.splitString(strTableRowIds[i], "|");
				strTokenId = (String)slResourceTokens.get(1);
				slEvents.add(strTokenId);
				String strRowId = (String)slResourceTokens.get(3);
				
				if(bEnablePush){
					%>
					var nRow = getTopWindow().emxUICore.selectSingleNode(getTopWindow().sb.oXML, "/mxRoot/rows//r[@id = '<%=strRowId%>']");
		            var expand = nRow.setAttribute("expand","false");
					arrIds.push("<%=strRowId%>");
					<%
				}
				%>
				getTopWindow().emxEditableTable.refreshRowByRowId("<%=strRowId%>");
				<%
			}
			if(bEnablePush){
				%>
				getTopWindow().emxEditableTable.expand(arrIds,"1");
				<%
			}
			%>
			</script>
			<%
				String[] strEvents = (String[]) slEvents.toArray(new String[slEvents.size()]);
				SubscriptionUtil.createSubscriptions(context, strObjectId, strEvents, requestMap);
		  } else {
	        %>    
	             <script type="text/javascript">
		             alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Event.Message.Subscription_Event_Selection_Warning</emxUtil:i18nScript>");
	             </script>	
	        <% 
          } 	
		 }	
	}
	catch (Exception ex) 
	{
		emxNavErrorObject.addMessage(ex.toString().trim());
	}
}
else if(strMode.equals("PushSubscribe"))
{
    if((null!=strObjectId && !"null".equals(strObjectId)) && (null!=strTableRowIds && strTableRowIds.length > 0))
  { 
	boolean flag = true;
	
	for(String entry : strTableRowIds) {
		if(!entry.contains(strObjectId)){
			flag = false;
		    break;
		}
	}

	if (flag) {
	   //go to search results
	String strRowList = FrameworkUtil.join(strTableRowIds, "~");
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"  type="text/javascript"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
	<script language="javascript" type="text/javaScript">
		sURL="../common/emxFullSearch.jsp?field=TYPES=type_Person,type_MemberList:CURRENT=policy_Person.state_Active,policy_MemberList.state_Active&table=AEFPersonChooserDetails&form=AEFSearchPersonForm&selection=multiple&showSavedQuery=True&submitURL=../components/emxSubscription.jsp?strRowList=<%=XSSUtil.encodeForURL(context,strRowList)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&mode=PushSubscribeAction&submitAction=refreshCaller&excludeOIDprogram=emxCommonSubscription:getNonReadableExcludePersonOID";
		showModalDialog(sURL);
	</script>
<% 
	} else {
		%>    	
        <script type="text/javascript">
		    alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Event.Message.Subscription_Event_Selection_Warning</emxUtil:i18nScript>");
	    </script>>	
		<% 
	}
  }
}
else if(strMode.equals("PushSubscribeAction"))
{
	%>
	<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
	<%
	String strTemp = "";
	StringList resultList = new StringList();
	
    String sSubmitAction = emxGetParameter(request, "submitAction");
    boolean refreshCaller = (sSubmitAction != null && sSubmitAction.equals("refreshCaller"));
	StringList slResourceTokens=null;
	String strTokenId="";
	StringList slEvents=new StringList();
	
	%>
	<script language="javascript">
		var arrIds=[];
	<%
	
	String strPersonId = PersonUtil.getPersonObjectID(context);

	String strRowList = emxGetParameter(request, "strRowList");
	StringList slParamValues = FrameworkUtil.split(strRowList, "~");
	StringList slEventList = new StringList();
	for (int i = 0; i < slParamValues.size(); i++) 
	{ 
	    StringList tempList = new StringList(); 
	    strTemp = (String)slParamValues.get(i);    
	    tempList=FrameworkUtil.split(strTemp,"|");  
	    String strId=(String)tempList.get(0);
	    slEventList.add(strId);
	    String strRowId = (String)tempList.get(2);
	    %>
		var nRow = getTopWindow().getWindowOpener().emxUICore.selectSingleNode(getTopWindow().getWindowOpener().parent.sb.oXML, "/mxRoot/rows//r[@id = '<%=strRowId%>']");
        var expand = nRow.setAttribute("expand","false");
		arrIds.push("<%=strRowId%>");
		if(getTopWindow().getWindowOpener().parent.emxEditableTable){
			getTopWindow().getWindowOpener().parent.emxEditableTable.refreshRowByRowId("<%=strRowId%>");
		} else{	
			getTopWindow().getWindowOpener().emxEditableTable.refreshRowByRowId("<%=strRowId%>");
		}
		<%
	}
	
	String strEventList = FrameworkUtil.join(slEventList, ",");
	
	for (int i = 0; i < strTableRowIds.length; i++) 
	{
		strTemp = strTableRowIds[i];
		StringList tempList = FrameworkUtil.split(strTemp, "|");
		if (!strPersonId.equals((String) tempList.get(0))) 
		{
			resultList.addElement((String) tempList.get(0));
		} 
		 //create subscription for logged in person
		else
		{
			HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
			String[] strEventArray = (String[]) slEventList.toArray(new String[slEventList.size()]);
			SubscriptionUtil.createSubscriptions(context, strObjectId,strEventArray, requestMap);
		}
	}
	String[] strPersonListArray = (String[]) resultList.toArray(new String[resultList.size()]);
	try {
		String strEvents = FrameworkUtil.join(slEventList, ",");
	
		if (strEvents != null || !strEvents.equals("")) 
		{
			SubscriptionUtil.createPushSubscription(context, strObjectId,strEventList, strPersonListArray, strLanguage);
		}
	} catch (Exception ex) 
	{
		emxNavErrorObject.addMessage(ex.toString().trim());
	}
	%>
	if(getTopWindow().getWindowOpener().parent.emxEditableTable){
			getTopWindow().getWindowOpener().parent.emxEditableTable.expand(arrIds,"1");
		}else{

		getTopWindow().getWindowOpener().emxEditableTable.expand(arrIds,"1");
		}
		getTopWindow().closeWindow();
	</script>
	<% 
}
else if(strMode.equals("unSubscribe"))
{
	%>
	<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
	<%
	
	String strLoginPersonId = PersonUtil.getPersonObjectID(context);
	
	boolean bIsObject = false;
	boolean bIsEvent = false;
	
	MapList mlAlerts=new MapList();
	try
	{
		%>
		<script language="javascript" type="text/javaScript">
			var arrRefreshIds=[];
			var arrDeleteIds=[];
		<%
		
		for(int i=0;i<strTableRowIds.length;i++)
		{	
			StringList slTokens = FrameworkUtil.split(strTableRowIds[i],"|");
			String strPersonOrMemberListId  = (String)slTokens.get(0);
			
			String strEventName= (String)slTokens.get(1);
			String strRowId = (String)slTokens.get(2);
			%>
			getTopWindow().emxEditableTable.refreshRowByRowId("<%=strRowId%>");
			<%
			DomainObject domainObject=DomainObject.newInstance(context,strPersonOrMemberListId);
			 //unsubscribe others
		    if(domainObject.exists(context))
		    {
		    	bIsObject = true;
		    	String strEventRow = strRowId.substring(0,strRowId.lastIndexOf(","));
		    	%>
		    	getTopWindow().emxEditableTable.refreshRowByRowId("<%=strEventRow%>");
				arrDeleteIds.push("<%=strTableRowIds[i]%>");
				<%
			 	Map<String, StringList> map=SubscriptionUtil.unSubscribeMemberAndMemberList(context, strObjectId,strPersonOrMemberListId,strEventName);
		    	StringList slList=map.get(strEventName);
		    	if(null!=slList && !slList.isEmpty())
		    	{
		    		mlAlerts.add(map);
		    	}
		    }
		    //unsubscribe self
		    else
		    {
		    	bIsEvent = true;
		    	%>
				var nRow = getTopWindow().emxUICore.selectSingleNode(getTopWindow().sb.oXML, "/mxRoot/rows//r[@id = '<%=strRowId%>']");
				var isExpanded = nRow.getAttribute("expand");
				if(isExpanded == "true")
				{
	            	var expand = nRow.setAttribute("expand","false");
	            	arrRefreshIds.push("<%=strRowId%>");
				}
				<%
		    	SubscriptionUtil.unSubscribeMemberAndMemberList(context, strObjectId,strLoginPersonId,strPersonOrMemberListId);
		    }
		}
		if(null!=mlAlerts && mlAlerts.size() > 0)
		{
			String strMessage = "";
			boolean bEvent = false;
			for(Object obj: mlAlerts){
				Map mTemp = (Map)obj;
				Set sKeys = mTemp.keySet();
				for(Object objKey:sKeys){
					String strKey = (String)objKey;
					StringList slValue = (StringList)mTemp.get(strKey);
					if(slValue!=null && !slValue.isEmpty()){
						if(bEvent){
							strMessage += " | ";
						}
						bEvent = true;
						strMessage += strKey +": ";
					}
					for(Object objPerson: slValue){
						String strPerson = (String)objPerson;
						strMessage += strPerson;
					}
				}
			}
			strMessage = MessageUtil.getMessage(context, null, "emxComponents.alert.CannotUnsubscribe",
			new String[] {strMessage}, null, context.getLocale(),
			"emxComponentsStringResource");	
			%>
			alert("<%=XSSUtil.encodeForJavaScript(context,strMessage)%>");
			<% 
		}
		if(bIsObject){
			%>
			getTopWindow().emxEditableTable.removeRowsSelected(arrDeleteIds);
			<%
		}
		if(bIsEvent)
		{
		%>
			getTopWindow().emxEditableTable.expand(arrRefreshIds,"1");
		<%
		}
		%>
		</script>
		<%
	}
	catch(Exception ex)
	{
	    emxNavErrorObject.addMessage(ex.toString().trim());
	}	
}
%>
