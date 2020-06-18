<%-- emxSubscriptionBody.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSubscriptionBody.jsp.rca 1.5.7.5 Tue Oct 28 19:01:10 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.common.util.*"%>
<html>
   <head>
      <title></title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIForm");
        </script>
   		<script type="text/javascript">
        	function onCheckboxClick(clickcheck)
		    {
	      		var obj = document.getElementById(clickcheck.value);
	      		if(obj != null && obj != 'undefined' && obj != 'null')
	      		{
			      	if(!clickcheck.checked)
			      	{
		      			obj.checked = false;
		      			obj.disabled = true;
			      	}
			      	else
			      	{
		      			//obj.checked = false;
		      			obj.disabled = false;
			      	}
		      	}
		    }

       </script>
    </head>
<%
    String strLanguage = request.getHeader("Accept-Language");
	String strobjectId = (String)session.getAttribute("strObjectIds");
	String targetLocation = emxGetParameter(request, "targetLocation");
	StringList lIds = FrameworkUtil.split(strobjectId.trim(), ",");
	MapList eventList = null;
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
	String sEventCommandName = null;
	boolean errorFlag = false;
	int objectCount = 0;
	boolean recursionEnabled = false;
	
	boolean isObjectExist = false;
    boolean isRequestObject = false;
    String strTokenId = "";
	for (int i = 0; i < lIds.size(); i++)
	{
		String id = ((String)lIds.get(i)).trim();
		if (id.length() == 0) {
			continue;
		}

		objectCount++;
		DomainObject dObj = new DomainObject(id);
		StringList selectsList = new StringList();
		selectsList.addElement(DomainConstants.SELECT_TYPE);
		Hashtable valueMap = (Hashtable) dObj.getInfo(context, selectsList);
		String objType = (String) valueMap.get(DomainConstants.SELECT_TYPE);
		//Resource Planning code change for RMB Subscription functionality
	    String isFromRMB = "";

	    isFromRMB = emxGetParameter(request, "isFromRMB");
	    
	    
	    if (null != (isFromRMB) && !"null".equals(isFromRMB)
	            && !"".equals(isFromRMB)) {
	        if ("true".equals(isFromRMB)) {
	            String strTableRowId = emxGetParameter(request,"emxTableRowId");
	            
	            StringList slRequestTokens = new StringList();
	            slRequestTokens = FrameworkUtil.split(strTableRowId, "|");
	            for(int m=0 ; m<slRequestTokens.size();m++){
	            strTokenId = (String) slRequestTokens.get(m);
	            DomainObject dmoRequest = new DomainObject(strTokenId);
	            isObjectExist = dmoRequest.exists(context);
	            
	            if(isObjectExist){
	            isRequestObject = dmoRequest.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST);
	            }

	            if (isRequestObject) {
	               id = strTokenId;
	               objType = dmoRequest.getInfo(context,DomainConstants.SELECT_TYPE);
	               break;
	            }
	            }
	        }
	    }

		MapList tempEventList = SubscriptionUtil.getObjectSubscribableEventsList(context, id, objType, requestMap);
		if (eventList == null) {
			eventList = tempEventList;
		} else if (!eventList.equals(tempEventList)) {
			errorFlag = true;
			break;
		}
	}
	String objectId = "";
	if(isRequestObject)
	{
		  objectId  = strTokenId;
    }else{
    	  objectId = (String)lIds.get(0);
        }

	HashMap objEventMap = new HashMap();
	HashMap subscriptionMap = new HashMap();
	HashMap pushedSubscriptionMap = new HashMap();
	String strApplytoSelected = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.ApplytoSubLevels");
	String strParentSubscriptions = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.ParentSubscriptions");
	String strPushed = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.Pushed");
	String strHeader = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.Header");
	String strNoEvents = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.NoEvents");
	String strUncommonObjs = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.UncommonObjs");
	if(eventList != null && eventList.size() > 0 && objectCount >= 1)
	{
		objEventMap = SubscriptionUtil.getObjectSubscribedEventsMap(context, objectId);
		subscriptionMap = (HashMap)objEventMap.get("Subscription Map");

		pushedSubscriptionMap = (HashMap)objEventMap.get("Pushed Subscription Map");

	}
%>
<body>
		 <img src="../common/images/utilSpace.gif" width="1" height="8" />
		 <form name="formEvents" method="post">
<%
		if(targetLocation != null && "slidein".equalsIgnoreCase(targetLocation)){
%>
		 <input type="hidden" name="targetLocation" value="slidein" />
<%
}
%>  	     
		 <input type="hidden" name="sUnsubscribedEventIds" value="" />
		 <input type="hidden" name="sUnsubscribedPushEventIds" value="" />
		 <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
         <input type="hidden" name="submitAction" value="" />
<%
		 if (errorFlag)
		 {
%>
			 <table border="0" cellpadding="5" cellspacing="2" width="100%">
			   <tr><td class="label"><%=XSSUtil.encodeForHTML(context, strUncommonObjs)%></td></tr>
			 </table>
<%
		 }
		 else
		 {
		 if(eventList == null || eventList.size() <= 0)
		 {
%>
			 <table border="0" cellpadding="5" cellspacing="2" width="100%">
			   <tr><td class="label"><%=XSSUtil.encodeForHTML(context, strNoEvents)%></td></tr>
			 </table>
<%
		 }
		 else {
%>
		 <table border="0" cellpadding="5" cellspacing="2" width="100%">
		   <tr>
			 <td width="150" class="label"><%=XSSUtil.encodeForHTML(context, strHeader)%></td>
			 <td class="inputField">
			   <table border="0">
<%
					Iterator it       = eventList.iterator();
					HashMap tempMap = new HashMap();
					String eventName = "";
					String isRecursible = "";
					String recurseRel = "";
					String forceRecursion="";
					while (it.hasNext())
					{
						tempMap = (HashMap) it.next();
						eventName = UIComponent.getSetting(tempMap, "Event Type");
						isRecursible = UIComponent.getSetting(tempMap, "Is Recursible");
                        forceRecursion=UIComponent.getSetting(tempMap, "Force Recursion");
						String i18nEventName = UIComponent.getLabel(tempMap);
						i18nEventName = UIExpression.substituteValues(context,pageContext, i18nEventName,objectId);
						boolean pushSubscriptionExists = false;
						StringTokenizer st = new StringTokenizer(eventName, ",");
						while(st.hasMoreTokens())
						{
						    String sToken = st.nextToken();
						    pushSubscriptionExists = pushedSubscriptionMap.containsKey(sToken);
						    if (pushSubscriptionExists) {
						        eventName = sToken;
						        break;
						    }
						}
						if(pushedSubscriptionMap != null && pushSubscriptionExists)
						{
							HashMap eventInfoMap = (HashMap)pushedSubscriptionMap.get(eventName);
							String relId = (String)eventInfoMap.get("ID");
%>
                    		<tr><td><input type="checkbox"  value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>"  name="chkUnSubscribePushEvent" checked />&nbsp;<%=XSSUtil.encodeForHTML(context, i18nEventName)%> <%=XSSUtil.encodeForHTML(context, strPushed)%></td></tr>
<%
						}

						String isRecurseSelected = "false";
						boolean subscriptionExists = false;
						st = new StringTokenizer(eventName, ",");
						while(st.hasMoreTokens())
						{
						    String sToken = st.nextToken();
						    subscriptionExists = subscriptionMap.containsKey(sToken);
						    if (subscriptionExists) {
						        eventName = sToken;
						        break;
						    }
						}
						if(subscriptionMap != null && subscriptionExists)
						{
							HashMap eventInfoMap = (HashMap)subscriptionMap.get(eventName);
							isRecurseSelected = (String)eventInfoMap.get("isRecursive");
							//String relId = (String)eventInfoMap.get("ID");
							String relId = "";
							StringList relIds = (StringList) eventInfoMap.get("relIds");
							for(int k=0; k<relIds.size();k++){
								relId += relIds.get(k)+ ";";
							}
                            
							if("true".equalsIgnoreCase(isRecursible))
							{
%>
                                <tr><td><input type="checkbox"  onclick="onCheckboxClick(this);" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" name="chkUnSubscribeEvent" checked />&nbsp;<%=XSSUtil.encodeForHTML(context, i18nEventName)%></td></tr>
<%
                                if(!"true".equalsIgnoreCase(forceRecursion))
								{
%>
								<tr><!-- //XSSOK -->
									<td>&nbsp;<input type="checkbox"  name="<%=XSSUtil.encodeForHTML(context, relId)%>"  value="true" <%=("true".equalsIgnoreCase(isRecurseSelected)?"checked":"")%> /><%=XSSUtil.encodeForHTML(context, strApplytoSelected)%></td></tr>

<%
	                            }
                                else
								{
%><!-- //XSSOK -->
								<input type="hidden"  name="<%=XSSUtil.encodeForHTML(context, relId)%>"  value="true" <%=("true".equalsIgnoreCase(isRecurseSelected)?"checked":"")%> />
<%
								}

							}
							else
							{

%>
                    			<tr><td><input type="checkbox"  value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" name="chkUnSubscribeEvent" checked />&nbsp;<%=XSSUtil.encodeForHTML(context, i18nEventName)%></td></tr>
<%
							}
						}
						else
						{
							if("true".equalsIgnoreCase(isRecursible))
							{
								boolean eventSubscribed = false;
								if(objectCount == 1)
									eventSubscribed = SubscriptionUtil.checkforRecursiveSubscription(context, objectId, tempMap);
								if(eventSubscribed)
								{
									recursionEnabled = true;
%>
									<tr><td><input type="checkbox"  disabled="true" value="<%=XSSUtil.encodeForHTMLAttribute(context, eventName)%>"  name="chkUnSubscribeEventDisabled" checked />&nbsp;<%=XSSUtil.encodeForHTML(context, i18nEventName)%> *</td></tr>
<%
	
									if(!"true".equalsIgnoreCase(forceRecursion))
									{
%>
									<tr><td>&nbsp;<input type="checkbox"  disabled="true" value="true"  name="<%=XSSUtil.encodeForHTML(context, eventName)%>" checked /><%=XSSUtil.encodeForHTML(context, strApplytoSelected)%></td></tr>
<%
									}
									else
									{
%>
									<input type="hidden" value="true"  name="<%=XSSUtil.encodeForHTML(context, eventName)%>" checked />
<%
									}

								}
								else
								{

%>
									<tr><td><input type="checkbox" onclick="onCheckboxClick(this);" value="<xss:encodeForHTMLAttribute><%=eventName%></xss:encodeForHTMLAttribute>"  name="chkSubscribeEvent" />&nbsp;<%=i18nEventName%></td></tr>
<%
	
									 if(!"true".equalsIgnoreCase(forceRecursion))
									 {
%>
									<tr><td>&nbsp;<input type="checkbox"  value="true"  name="<%=XSSUtil.encodeForHTML(context, eventName)%>" /><%=XSSUtil.encodeForHTML(context, strApplytoSelected)%></td></tr>
<%
									}
									else
									{
%>
									<input type="hidden"  value="true"  name="<%=XSSUtil.encodeForHTML(context, eventName)%>" />

<%
									}

								}
							}
							else
							{
%>
								<tr><td><input type="checkbox"  value="<xss:encodeForHTMLAttribute><%=eventName%></xss:encodeForHTMLAttribute>"  name="chkSubscribeEvent" />&nbsp;<%=XSSUtil.encodeForHTML(context, i18nEventName)%></td></tr>
<%
							}
						}
					}
%>
					
<%
if (recursionEnabled)
{

%>
<script language="Javascript">
   var msgId = getTopWindow().document.getElementById("msgTD");
   msgId.innerHTML="<%=XSSUtil.encodeForJavaScript(context, strParentSubscriptions)%>";
</script>

<%
}
%>
				</table>
			  </td>
			</tr>
		  </table>
<%
		 }
		 }
%>
		</form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
