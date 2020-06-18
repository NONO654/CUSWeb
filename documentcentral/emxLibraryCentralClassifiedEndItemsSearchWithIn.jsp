<%-- emxLibraryCentralClassifiedEndItemsSearchWithIn.jsp

   static const char RCSID[] = $Id: emxLibraryCentralClassifiedEndItemsSearchWithIn.jsp.rca 1.2.3.4 Wed Oct 22 16:02:35 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<xss:encodeForHTML><%= request.getHeader("Accept-Language") %></xss:encodeForHTML>' />
<%
	String strDocumentCentralAppDir   = "documentcentral";
	String objectId = emxGetParameter(request,"objectId");
	String emxTableRowId = emxGetParameter(request,"emxTableRowId");
	//type_Library is the symbolic name for "Document Library" 
	String strDocumentLibrary = PropertyUtil.getSchemaProperty(context, "type_Library");
	String objId = emxTableRowId;
	
	String strParameterName  = "";
	String strParameterValue = "";
	java.util.Enumeration enumParameters = emxGetParameterNames(request);

	StringBuffer queryString  = new StringBuffer("?");
	
	while (enumParameters.hasMoreElements())
	{
		strParameterName  = (String)enumParameters.nextElement();
		strParameterValue = emxGetParameter(request, strParameterName);
		if("objectId".equals(strParameterName))
		{
			if(strParameterValue==null || "null".equals(strParameterValue) || "".equals(strParameterValue))
			{
				strParameterValue = emxTableRowId;
				objId = emxTableRowId;
			}
			else
			{
				objId = strParameterValue;
			}
		}
		queryString.append(strParameterName);
		queryString.append("=");
		queryString.append(strParameterValue);
		queryString.append("&");
	}//while !
	String strSubmitActionURL = "../" + strDocumentCentralAppDir + "/emxLibraryCentralClassifiedEndItemsSearch.jsp" + queryString.toString();
%>

<body>
</body>

<script language="javascript">
<!--
	function showSearchInDialogForm()
	{
		var fm = window.document.formForwardRequest;
		var conTree = getTopWindow().objDetailsTree;		

	<%
		DomainObject domObject = new DomainObject(objId);

		String strObjType = domObject.getInfo(context,DomainObject.SELECT_TYPE);

		if(strObjType != null && strObjType.indexOf(strDocumentLibrary) != -1)
		{
	%>
				alert("<emxUtil:i18n localize="i18nId">emxLibraryCentral.SearchIn.SearchWithinNotApplicable</emxUtil:i18n>");
				window.location.href="about:blank";
	<%
		}
		else
		{

	%>
		//start - javascript
			var selectedTreeNode = "";
			if(conTree.getSelectedNode())
			{
				selectedTreeNode=conTree.getSelectedNode().nodeID;
			}
			showAndGetNonModalDialogWithName("<xss:encodeForJavaScript><%=strSubmitActionURL%></xss:encodeForJavaScript>&selectedTreeNode="+selectedTreeNode,"SearchIn", 700, 500, true);
		//end - javascript
	<%
		}
	%>
	}
	showSearchInDialogForm();
-->
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
