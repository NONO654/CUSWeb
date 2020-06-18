<%--  emxSubscriptionProcess.jsp
   Copyright (c) 2000-2018 - 2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSubscriptionProcess.jsp.rca 1.2.7.5 Wed Oct 22 16:18:31 2008 przemek Experimental przemek $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.common.util.*"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
	//Read the objectId list passed in
	String saObjectKey[]    = emxGetParameterValues(request, "chkSubscribeEvent");
	String sObjectId        = (String)session.getAttribute("strObjectIds");
	session.removeAttribute("strObjectIds");
	String targetLocation = emxGetParameter(request, "targetLocation");
	String sUnsubEvtIds     = emxGetParameter(request, "sUnsubscribedEventIds");
	String sUnsubPushedEvtIds     = emxGetParameter(request, "sUnsubscribedPushEventIds");
    String sSubmitAction = emxGetParameter(request, "submitAction");
    boolean refreshCaller = (sSubmitAction != null && sSubmitAction.equals("refreshCaller"));

	String subRecursive[]    = emxGetParameterValues(request, "chkUnSubscribeEvent");

	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
	boolean errorHappen = false;
	//Process subscribed events, create objects and connect relationships
	try
	{
		if (sUnsubPushedEvtIds != null && !"".equals(sUnsubPushedEvtIds))
		{
			StringTokenizer st = new StringTokenizer(sUnsubPushedEvtIds, ";");
			while (st.hasMoreTokens())
			{
				DomainRelationship.disconnect(context, st.nextToken());
			}
		}

		if (sUnsubEvtIds != null && !"".equals(sUnsubEvtIds))
		{
			StringTokenizer st = new StringTokenizer(sUnsubEvtIds, ";");
			while (st.hasMoreTokens())
			{
				DomainRelationship.disconnect(context, st.nextToken());
			}
		}

		if(subRecursive != null)
		{
			for (int i = 0; i < subRecursive.length; i++)
			{
				String strRecurseVal = "False";
				if(requestMap.containsKey(subRecursive[i]))
				{
					String recurse = emxGetParameter(request, subRecursive[i]);
					if(recurse != null && "true".equalsIgnoreCase(recurse))
					{
						strRecurseVal = "True";
					}
					DomainRelationship domRel = new DomainRelationship(subRecursive[i]);
					domRel.setAttributeValue(context, DomainObject.ATTRIBUTE_ISRECURSIVE, strRecurseVal);
				}
			}
		}
		SubscriptionUtil.createSubscriptions(context, sObjectId, saObjectKey, requestMap);
	}
	catch(Exception ex)
	{
		errorHappen = true;
		emxNavErrorObject.addMessage(ex.toString().trim());
	}

	if(!errorHappen)
	{
%>
		<script language="javascript">

<%
		if(targetLocation != null && "slidein".equalsIgnoreCase(targetLocation)){
%>
			getTopWindow().closeSlideInDialog();
<%
		} else {
%>
		  if (<%=refreshCaller%>)
		      getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
			  window.closeWindow();
<%
		}
%>
		
		</script>
<%
	}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
