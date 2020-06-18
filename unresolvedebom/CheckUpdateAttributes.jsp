 <%--  CheckUpdateAttributes.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%-- <%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" %> --%>
<%-- <jsp:useBean id="pueChange" class="com.matrixone.apps.unresolvedebom.PUEChange" scope="session"/>
<jsp:useBean id="unresolvedPart" class="com.matrixone.apps.unresolvedebom.UnresolvedPart" scope="session"/> --%>

<%
	response.setHeader("Cache-Control", "no-cache");
	String returnMsg = "true@";
	
	boolean isIntersectForEdit = true;
	boolean isCyclicDependent = false;
	
	String relId = emxGetParameter(request, "relId");
	String contextECOId = emxGetParameter(request, "contextECOId");
	
	if (contextECOId != null && !"".equals(contextECOId)) {
		//isIntersectForEdit = pueChange.isIntersectEffectivity(context,contextECOId,relId);
		isIntersectForEdit=true;
		if (isIntersectForEdit) {
			//isCyclicDependent = unresolvedPart.checkForCyclicPrerequisite(context, relId, contextECOId);
			isCyclicDependent=false;
			if (isCyclicDependent) {
				returnMsg = "cyclicDependency";
			}
		} else {
			returnMsg = "invalidIntersectEffectivity";
		}
	} else {
	    returnMsg = "alert@";
	}
	
	response.getWriter().write(returnMsg);
%>

