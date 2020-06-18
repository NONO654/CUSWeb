<%--  emxNavigatorCheckReadAccess.inc   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxNavigatorCheckReadAccess.inc.rca  Mon Feb 12 15:48:32 2017 przemek Experimental przemek $
--%>
<%@ page import = "matrix.db.*, matrix.util.*,
				   com.matrixone.util.*,
				   com.matrixone.apps.framework.ui.*,
				   com.matrixone.apps.domain.util.*, 
				   com.matrixone.apps.domain.*, 
				   java.util.*, 
				  com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%
HashMap reqMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String objId = (String)reqMap.get("objectId");
boolean hasReadAccess = true;
boolean isObjectId =false;
	if(UIUtil.isNotNullAndNotEmpty(objId)){
		isObjectId = FrameworkUtil.isObjectId(context,objId);
		if(isObjectId ){
			DomainObject dObject    = new DomainObject(objId);
			if(dObject.exists(context)){
				Access  access = dObject.getAccessMask(context);
				hasReadAccess=access.hasReadAccess();
			}else{
				hasReadAccess=false;
			}
	  }
	}
	if(!hasReadAccess && isObjectId){
		%>
		<!-- //XSSOK -->
		<jsp:forward page="emxTreeNoDisplay.jsp" > <jsp:param name ="objectId" value  ="<%=objId%>" />
     	</jsp:forward>
	<%
	}
%>
