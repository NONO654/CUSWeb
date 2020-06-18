<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%
    String  parentId = emxGetParameter(request, "objectId");
    String  newOID  = emxGetParameter(request, "newObjectId");
    String relId = emxGetParameter(request, "relId"); 


	if(null == parentId)
	{
	%>
		<script language="javascript">
			alert("no parent info.");
		</script>
	<%
		throw new Exception("refresh ko 2");
	}

	if(null == relId)
	{
	%>
	<script language="javascript">
		alert("no rel info.");
	</script>
	<%
	throw new Exception("refresh ko 3");
	}
    String xmlItemInfo = "<item oid=\""+newOID+"\" relId=\""+relId+"\" pid=\""+parentId+"\"/>"; 

    String xmlMessage = "<mxRoot><action>add</action><data location=\"appendChild\" status=\"comitted\">"+xmlItemInfo+"</data></mxRoot>";
%>



<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
	try{
  							var sbWindow = findFrame(getTopWindow(), "detailsDisplay");
  							if(!sbWindow) {
  								sbWindow = findFrame(getTopWindow(), "content");
  							}
  							if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.addToSelected){
  								sbWindow.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
  								 //refreshStructureTree();
  							}	
							
	}
	catch(e)
	{
		alert("error while refreshing the tree: ");
	}
</script>


