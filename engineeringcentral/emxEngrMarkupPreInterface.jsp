<%--  emxEngrMarkupPreInterface.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
 --%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
	boolean sflag=false;
	String contentURL = "";
	String Action=emxGetParameter(request,"Action");
	
	String targetLocation=emxGetParameter(request,"targetLocation");
	
	String commandType=emxGetParameter(request,"commandType");
	String strObjectIds=emxGetParameter(request,"strObjectIds");
	if(UIUtil.isNullOrEmpty(strObjectIds)){
		strObjectIds = emxGetParameter(request,"objectIds");
	}
	String sObjId=emxGetParameter(request,"sObjId");
	String strChangeObjectId=emxGetParameter(request,"sChangeObjId");
	String strMarkupIds=emxGetParameter(request,"strMarkupIds");
	long timeinMilli = System.currentTimeMillis();


	Map reqMap = (Map)request.getParameterMap();
	String[] oXML = (String[])reqMap.get("markupXML");
	String strMarkupXML = oXML[0];
	strMarkupXML = UIUtil.isNotNullAndNotEmpty(strMarkupXML) ? strMarkupXML.trim() : strMarkupXML;
	session.removeAttribute("markupXML");
	session.removeAttribute("massUpdateAction");
	session.removeAttribute("partWhereusedMarkupIds");	


	if ( "Save".equalsIgnoreCase( Action) )	{
		session.setAttribute("markupXML", strMarkupXML);
		session.setAttribute("partWhereusedMarkupIds", strObjectIds);
		contentURL = "../common/emxForm.jsp?form=MarkupSave&formFieldsOnly=true&targetLocation=slidein&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&mode=edit&postProcessJPO=emxPartMarkup:saveMarkup&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource"
			+ "&commandType=" + commandType + "&objectId=" + sObjId+"&submitAction=doNothing&jpoAppServerParamList=session:markupXML,session:partWhereusedMarkupIds";
		sflag=true;
	} else if ( "SaveOpen".equalsIgnoreCase( Action ) ){
		session.setAttribute("massUpdateAction", strMarkupXML);
		contentURL="../common/emxForm.jsp?form=ENCOpenSaveMarkupChangeProcess&formFieldsOnly=true&formHeader=emxEngineeringCentral.Markup.Create&suiteKey=EngineeringCentral&mode=edit&commandType=Save&sSelPart=ECPart&sChangeObjId="+strChangeObjectId+"&sObjId="+sObjId+"&strMarkupIds="+strMarkupIds+"&postProcessURL=../engineeringcentral/emxEngrMarkupSavePostProcess.jsp&jpoAppServerParamList=session:massUpdateAction";
		sflag=true;
	}
	else if ( "SaveAsOpen".equalsIgnoreCase( Action ) ){
		session.setAttribute("massUpdateAction", strMarkupXML);
		contentURL="../common/emxForm.jsp?form=ENCOpenSaveMarkupChangeProcess&formFieldsOnly=true&formHeader=emxEngineeringCentral.Markup.Create&suiteKey=EngineeringCentral&mode=edit&commandType=SaveAs&sSelPart=ECPart&sChangeObjId="+strChangeObjectId+"&sObjId="+sObjId+"&strMarkupIds="+strMarkupIds+"&postProcessURL=../engineeringcentral/emxEngrMarkupSavePostProcess.jsp&jpoAppServerParamList=session:massUpdateAction";
		sflag=true;
	}

%>


<%
if(sflag)
{%>
<html>
	<head>
	</head>
	<body>
		<form name="preMarkupForm" method="post">
			<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
			<script language="javascript" src="../common/scripts/emxUICore.js"></script>	
			<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>		
			<script language="JavaScript" type="text/javascript">
				var targetLoc = "<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>";
				if( targetLoc == "slidein" ){
					//XSSOK
					getTopWindow().showSlideInDialog('<%=contentURL%>', true);
				}else{
					//XSSOK
			        //window.open('about:blank','newWin' + "<%=timeinMilli%>",'height=570,width=570,resizable=yes');
					showModalDialog("../common/emxBlank.jsp","570","570","true"); 
					//XSSOK
			        //document.preMarkupForm.target="newWin" + "<%=timeinMilli%>";
			        var objWindow =  getTopWindow().modalDialog.contentWindow;
					document.preMarkupForm.target = objWindow.name;
			        //XSSOK
					document.preMarkupForm.action='<%=contentURL%>';
					document.preMarkupForm.submit();
				}		
			</script>
		</form>
	</body>
</html>

<%
}
%>
