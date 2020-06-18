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
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileUtils" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants.Type" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants" %>
<%
	System.out.println("BEGIN emxProfileFilterChooser.jsp");
	String language = context.getSession().getLanguage();
	String errortype = EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.ValidateValue.ErrorOtherTypeSelected");
	String errornoselection = EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.ValidateValue.ErrorNoSelection");
	errortype += " "+Type.PLMFilteringCheck;
	String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
	String inputname = emxGetParameter(request,"inputname");
	String inputvalue = emxGetParameter(request,"inputvalue");
	String inputOID = emxGetParameter(request,"inputOID");
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
		if(sObjId != null) {
			String objectType = ProfileUtils.getType(context, sObjId);
			if(ProfileUtils.isTypeKindOf(context, objectType, Type.PLMFilteringCheck)){
				DomainObject object = DomainObject.newInstance(context, sObjId);
				String parentName = object.getAttributeValue(context, "PLMEntity.V_Name");
				if(null == parentName)
					parentName = object.getAttributeValue(context, "PLMEntity.PLM_ExternalID");
				String objectId = object.getId();
				%>
					<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
					<script language="javascript" src="../common/scripts/emxUICore.js"></script>
					<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
					<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
					<script language="javascript" src="scripts/emxUICoreMenu.js"></script>
					<script language="javascript" src="scripts/emxUIToolbar.js"></script>
					<script language="Javascript">
						var txtTypeDisp, txtTypeValue, txtTypeOID;
						objForm = emxUICore.getNamedForm(getTopWindow().getWindowOpener(),0);
						txtTypeDisp = objForm.elements['<%=inputname%>'];
						txtTypeDisp.value = "<%=parentName%>";
						txtTypeDisp = objForm.elements['<%=inputvalue%>'];
						txtTypeDisp.value = "<%=parentName%>";
						txtTypeDisp = objForm.elements['<%=inputOID%>'];
						txtTypeDisp.value = "<%=objectId%>";
						getTopWindow().close();
					</script>				 
				<%
			}else{
				%>
				<script language="javascript" src="../common/scripts/emxUICore.js"></script>
				<script language="Javascript">
					var errortype = '<%=errortype%>';
					alert(errortype);
					getTopWindow().close();
				</script>
				<%
			}
		}
	}else{
		%>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="Javascript">
			var errornoselection = '<%=errornoselection%>';
			alert(errornoselection);
		</script>
		<%
	}
	System.out.println("END emxProfileFilterChooser.jsp");
%>


