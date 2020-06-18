<%--  emxVPLMConnectObjects.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxVPLMConnectObjects.jsp.rca 1.22 Wed Oct 22 16:18:09 2008 przemek Experimental przemek przemek $";
   
   Historique:
   Wk 40 2009 - RCI - IR-015934V6R2011 - modif signature attachDocument de VPLMDocument & envoi exception si document deja attache.  
   Wk 12 2012 - RCI - IR-159739V6R2012 - simplification jsp .... (199 lg à 81 !!!)
   Wk 40 2017 - VZB - FUN063474 - ENOVIA Classification WebProduct 3DSearch adoption
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<html>
	<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
	
	<head>
		<title></title>
		
		<%@include file = "../common/emxUIConstantsInclude.inc"%>
		
		<%@page import="java.util.HashMap"%>
		<%@page import="java.util.Vector"%>
		
		<%@page import="com.matrixone.apps.domain.DomainConstants"%>
		<%@page import="com.matrixone.apps.domain.DomainObject"%>
		<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
		<%@page import="matrix.db.JPO"%>
		<%@page import="java.util.Map"%>
		<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
		<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
		
		
	</head>
	
	
	<body>
		<%
		try {
                    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

			String strObjectId = (String)requestMap.get("objectId");
			String strTableRowIds[]  = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
			
			//if ( (strTableRowIds!=null && !strTableRowIds.length>0)) {
				ContextUtil.startTransaction(context, true);
				Map programMap = new HashMap();
				programMap.put("objectId", strObjectId);
				programMap.put("documentIds", strTableRowIds);
				String[] methodargs =JPO.packArgs(programMap);
						
				Vector hasDocEverAttached = (Vector) JPO.invoke(context, "VPLMDocument", null,"attachDocuments", methodargs, Vector.class);
				// IR-015934V6R2011 - tentative attach document existant - on affiche apenl et on n'attache pas
				if ( hasDocEverAttached != null) {
					throw new Exception("Document is already attached to the entity");
				}
				%>
				<script language="javascript">
				//top.opener.location.href = top.opener.location.href;
				//top.location.href = "../common/emxCloseWindow.jsp";
                getTopWindow().getWindowOpener.location.href = getTopWindow().getWindowOpener.location.href;
                getTopWindow().location.href = "../common/emxCloseWindow.jsp";
				</script>
				<%


			//} else {
		//		throw new Exception ("");
		//	}
		} catch (Exception e) {
			session.putValue("error.message", e.toString());
		}
		%>

		<script language="javascript">
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
        getTopWindow().closeWindow();    
        </script>
		
	</body>
	
	<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
	
</html>
