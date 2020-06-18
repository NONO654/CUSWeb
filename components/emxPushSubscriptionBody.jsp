<%-- emxPushSubscriptionBody.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPushSubscriptionBody.jsp.rca 1.5.6.5 Wed Oct 22 16:18:56 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.common.util.*"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%

    String strLanguage = request.getHeader("Accept-Language");

	String objectId = "";
	String tableRowIdList[] = emxGetParameterValues(request,
			"emxTableRowId");
	if (tableRowIdList == null || tableRowIdList.length <= 0) {
		objectId = emxGetParameter(request, "objectId");
	} else {
		String strElement = "";
		for (int i = 0; i < tableRowIdList.length; i++) {
			strElement = tableRowIdList[i];
			if (strElement.indexOf('|') >= 0) {
				StringList tempList = FrameworkUtil.split(strElement,
						"|");
				strElement = (String) tempList.get(1);
				if (strElement.equals("")) {
					strElement = (String) tempList.get(0);
				}
			}
			if (i > 0)
				objectId += ",";
			objectId += strElement;
		}
	}

	//Resource Planning code change for RMB Push Subscription functionality
	String isFromRMB = "";
	boolean isRequestObject = false;
	isFromRMB = emxGetParameter(request, "isFromRMB");
	if (null != (isFromRMB) && !"null".equals(isFromRMB)
			&& !"".equals(isFromRMB)) {
		if ("true".equals(isFromRMB)) {
			String strTableRowId = emxGetParameter(request,"emxTableRowId");
			String strTokenId = "";
			StringList slRequestTokens = new StringList();
			slRequestTokens = FrameworkUtil.split(strTableRowId, "|");
			strTokenId = (String) slRequestTokens.get(1);
			DomainObject dmoRequest = new DomainObject(strTokenId);
			isRequestObject = dmoRequest.isKindOf(context,
					DomainConstants.TYPE_RESOURCE_REQUEST);

			if (isRequestObject) {
				objectId = strTokenId;
			}
		}
	}
	String strResourcePoolId = emxGetParameter(request,"resourcePoolId");
	if (null != (strResourcePoolId)&& !"null".equals(strResourcePoolId)&& !"".equals(strResourcePoolId)) {
			String strElement = "";
			objectId = "";
			boolean isBusinessObject = false;
			for (int i = 0; i < tableRowIdList.length; i++) {
				strElement = tableRowIdList[i];
				if (strElement.indexOf('|') >= 0) {
					StringList tempList = FrameworkUtil.split(
							strElement, "|");
					strElement = (String) tempList.get(0);
					DomainObject dmoRequest = new DomainObject(strElement);
		            isBusinessObject = dmoRequest.exists(context);
				}
				if (i > 0)
					objectId += ",";
				if(isBusinessObject)
				objectId += strElement;
		}
	}
	//End Of Resource Planning Code Change     

	String suiteKey = emxGetParameter(request, "suiteKey");
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);

    MapList eventList = new MapList();
	String strPushedRecipients = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Subscription.PushedRecipients"); 
	String strSubscribeRecipients = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Subscription.SubscribedRecipients"); 
	String strHeader = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.Header"); 
	String strNoEvents = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.SubscriptionOptions.NoEvents");

	if(objectId != null && !"".equals(objectId))
    {
		DomainObject dObj = new DomainObject(objectId);
		StringList selectsList = new StringList();
		selectsList.addElement(DomainConstants.SELECT_TYPE);
		Hashtable valueMap = (Hashtable) dObj.getInfo(context, selectsList);
		String objType = (String) valueMap.get(DomainConstants.SELECT_TYPE);
		eventList = SubscriptionUtil.getObjectSubscribableEventsList(context, objectId, objType, requestMap);
	}
%>
<html>
   <head>
      <title></title>
    </head>
        <script language="javascript" src="../common/scripts/emxUICore.js"></script>
        <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
		<script language="javascript" src="../emxUIPageUtility.js"></script>
        <script type="text/javascript">
            var refreshPage = false;
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIList");
        </script>
<body>
		<form name="formEvents" method="post">
			<input type=hidden name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
			<table class="list">
				<tr>
					<th width="40%"><%=XSSUtil.encodeForHTML(context, strHeader) %></th>
					<th width="30%"><%=XSSUtil.encodeForHTML(context, strPushedRecipients)%></th>
					<th width="30%"><%=XSSUtil.encodeForHTML(context, strSubscribeRecipients)%></th>
				</tr>
<%
		 if(eventList == null || eventList.size() <= 0)
		 {
%>
			   	<tr>
			   		<td align="center" colspan="13" class="error">
			   			<%=XSSUtil.encodeForHTML(context, strNoEvents)%>
			   		</td>
			   	</tr>
<%
		 }
		 else {
				Iterator it       = eventList.iterator();
				HashMap tempMap = new HashMap();
				while (it.hasNext())
				{
					tempMap = (HashMap) it.next();
					String eventCmdName = UIComponent.getName(tempMap);
					String eventName = UIComponent.getSetting(tempMap, "Event Type");
					String isRecursible = UIComponent.getSetting(tempMap, "Is Recursible");
					String isForceRecurse = UIComponent.getSetting(tempMap, "Force Recurse");
					boolean blnForceRecurse = "true".equalsIgnoreCase(isForceRecurse)?true:false;
					String strRecurseRelation = UIComponent.getSetting(tempMap, "Recurse Relationship");
					String i18nEventName = UIComponent.getLabel(tempMap);
					i18nEventName = UIExpression.substituteValues(context,pageContext, i18nEventName,objectId);
					boolean blnRecursible = "true".equalsIgnoreCase(isRecursible)?true:false;
					MapList parentObjList = new MapList();
					if(blnRecursible)
		    		{
						parentObjList = SubscriptionUtil.getParentObjectIdList(context, objectId, tempMap);
		    		}

					StringList personList = SubscriptionUtil.getSubscribersList(context, objectId, eventName, parentObjList, false, !blnForceRecurse);
					MapList pushSubList = SubscriptionUtil.getPushSubscribersListByObject(context, objectId, eventName);
					String strPushSubscriptionUrl = "../common/emxTable.jsp?program=emxSubscriptionUtil:getPushSubscribersList&sortColumnName=Name&table=APPSubscribersSummary&CancelButton=true&CancelLabel=emxComponents.Button.Close&CancelURL=../components/emxRefreshSubscriptionsList.jsp&objectCompare=false&header=emxComponents.PushedRecipients.PageHeader&selection=multiple&toolbar=APPPushSubscriptionsToolbar&HelpMarker=emxhelppushrecipients&objectId=" + XSSUtil.encodeForURL(context, objectId) + "&eventName=" + XSSUtil.encodeForURL(context, eventName) + "&suiteKey=Components&Style=dialog";
					String strSubscriptionUrl = "../common/emxTable.jsp?program=emxSubscriptionUtil:getSelfSubscribersList&sortColumnName=Name&table=APPSubscribersSummary&CancelButton=true&CancelLabel=emxComponents.Button.Close&header=emxComponents.SubscribedRecipients.PageHeader&selection=none&objectCompare=false&HelpMarker=emxhelpsubscriptionspush&objectId=" + XSSUtil.encodeForURL(context, objectId) + "&eventCmdName=" + XSSUtil.encodeForURL(context, eventCmdName) + "&suiteKey=Components&Style=dialog";
%>
				<tr class='<framework:swap id="1"/>'>
					<td><%=XSSUtil.encodeForHTML(context, i18nEventName)%><br/></td>
					<td style="text-align: center">
						<!-- //XSSOK -->
						<a href="javascript:emxShowModalDialog('<%=strPushSubscriptionUrl%>',550,500);" ><%=pushSubList.size()%></a>
					</td>
					<td style="text-align: center">
						<!-- //XSSOK -->
						<a href="javascript:emxShowModalDialog('<%=strSubscriptionUrl%>',550,500);" ><%=personList.size()%></a>
					</td>
				</tr>
<%
				}
		 }
%>
			</table>
		</form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
