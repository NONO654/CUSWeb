<%--  emxColumnStatusAction.jsp - to drop a document file
--%>

<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>
<%@page import="matrix.db.*" %>

<html>
	<body>
		<script language="javascript" type="text/javaScript">	
		
<%	
	String sLang		= request.getHeader("Accept-Language");
	String sMessage		= i18nNow.getI18nString("emxFramework.String.DoYouReallyWantToSetThisItemToItsFinalState", "emxFrameworkStringResource"	        , sLang);
	String sRouteBlock	= i18nNow.getI18nString("emxFramework.Lifecycle.Promote.InCompleteRouteStateBlock",  "emxFrameworkStringResource"	, sLang);
	String sOID 		= request.getParameter("objectId");
	String sRowID		= emxGetParameter(request, "rowId");
	String sAction 		= request.getParameter("action");
	String sState 		= request.getParameter("state");
	String sPolicy 		= request.getParameter("policy");
	String sConfirm		= request.getParameter("confirm");
	Boolean bConfirm	= false;
	String sError		= "";
		
	DomainObject dObject 	= new DomainObject(sOID);
	Access access 		  	= dObject.getAccessMask(context);	
	Boolean bAccessPromote	= access.hasPromoteAccess();
	
	
	if(sAction.equals("demote")) 	{ dObject.demote(context);  }
	else {
		if(bAccessPromote) {
			Policy policy           = dObject.getPolicy(context);
			String sCurrent 		= dObject.getInfo(context, DomainConstants.SELECT_CURRENT);
			String sSymbolicState   = FrameworkUtil.reverseLookupStateName(context, policy.getName(), sCurrent);
			MapList mlStateBlocks	= dObject.getRelatedObjects(context, DomainConstants.RELATIONSHIP_OBJECT_ROUTE, DomainConstants.TYPE_ROUTE, new StringList(new String[] {"id"}), new StringList(new String[] {"attribute["+ DomainConstants.ATTRIBUTE_ROUTE_BASE_STATE+"]"}), false, true, (short)1, "(current != 'Complete') && (current != 'Archive')", "attribute["+ DomainConstants.ATTRIBUTE_ROUTE_BASE_STATE+"] == '" + sSymbolicState + "'", 1);
			if(mlStateBlocks.size() > 0) { bAccessPromote = false; sError = sRouteBlock; }			
		}
		if(bAccessPromote) {
			if(sAction.equals("promote")) { 
				dObject.promote(context);
			} else {
				if(null == sConfirm) {
					bConfirm = true;
				} else {
					if(sAction.equals("setState"))	{ dObject.setState(context, sState);  }
					else if(sAction.equals("setPolicy")){ dObject.setPolicy(context, sPolicy);  }
				}								
			}
		}	
	}
	
	if(sError.equals("")) {
		if(bConfirm) { %>
	
			var conf = confirm("<%=sMessage%>?");
			if(conf) {
				document.location.href = document.location.href + "&confirm=done";
			}
	
<%		} else { %>

			var url = parent.document.location.href;
			if(url.indexOf("emxIndentedTable.jsp") == -1) {
				if(typeof(parent.listDisplay)!="undefined"){
					parent.listDisplay.location.reload();
				}else{
					parent.location.reload();
				}
			} else {
				parent.emxEditableTable.refreshRowByRowId("<%=sRowID%>");
			}

<% 		}
	} else { %>
		alert("<%=sError%>");
<%	}	%>

		</script>
	</body>
</html>
