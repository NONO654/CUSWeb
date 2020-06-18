<%@ page import="com.matrixone.apps.framework.ui.emxPagination" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.lang.String" %>
<%@ page import="com.matrixone.apps.domain.util.MapList"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%
	String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
	String objectId = emxGetParameter(request,"objectId");
	System.out.println("selectedId:"+selectedId+" objectId:"+objectId);
	
	if(selectedId != null)
	{
		StringTokenizer st = null;
		String sRelId = "";
		String sObjId = "";
		if(selectedId[0].indexOf("|") != -1)
		{
			st = new StringTokenizer(selectedId[0], "|");
			sObjId = st.nextToken();
			sRelId = st.nextToken();
		}
		else
		{
			sObjId = selectedId[0];
		}
		System.out.println("sObjId:"+sObjId+" sRelId:"+sRelId);
		if(sObjId != null) {
			DomainObject object = DomainObject.newInstance(context, sObjId);
			String parentName = object.getInfo(context, DomainConstants.SELECT_NAME);
			%>
			<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
			<script language="javascript" src="../common/scripts/emxUICore.js"></script>
			<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
			<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
			<script language="javascript" src="scripts/emxUICoreMenu.js"></script>
			<script language="javascript" src="scripts/emxUIToolbar.js"></script>
			<script language="Javascript">
				var txtType,txtTypeDisp;
				objForm = emxUICore.getNamedForm(getTopWindow().getWindowOpener(),0);
				txtType = objForm.elements["ImportProfile"];
				txtTypeDisp = objForm.elements["ImportProfileDisplay"];
				txtType.value = "<%=sObjId%>";
				txtTypeDisp.value = "<%=parentName%>";
				getTopWindow().close();
			</script>				 
		<%
		}
	}

%>


