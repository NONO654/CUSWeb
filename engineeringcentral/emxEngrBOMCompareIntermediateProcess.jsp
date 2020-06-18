<%--  emxEngrBOMCompareIntermediateProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file ="emxEngrFramesetUtil.inc"%>


<%

String strObjectId1 = null;
String strObjectId2 = null;


String contentURL = "";

String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");

if (tableRowIdList!= null)
{
	int intNumRows = tableRowIdList.length;

	System.out.println("intNumRows ---------------> " + intNumRows);

	if (intNumRows >= 2)
	{
		 String strRowInfo = tableRowIdList[0];

		 StringList strlRowInfo = FrameworkUtil.split(strRowInfo, "|");

		 if (strlRowInfo.size() == 3)
		 {
		 	strObjectId1 = (String) strlRowInfo.get(0);
		 }
		 else
		 {
			 strObjectId1 = (String) strlRowInfo.get(1);
		 }


		 strRowInfo = tableRowIdList[1];

		 strlRowInfo = FrameworkUtil.split(strRowInfo, "|");

		 if (strlRowInfo.size() == 3)
		 {
		 	strObjectId2 = (String) strlRowInfo.get(0);
		 }
		 else
		 {
			 strObjectId2 = (String) strlRowInfo.get(1);
		 }

	}
	else if (intNumRows == 1)
	{
		String strRowInfo = tableRowIdList[0];

		StringList strlRowInfo = FrameworkUtil.split(strRowInfo, "|");

		 if (strlRowInfo.size() == 3)
		 {
		 	strObjectId1 = (String) strlRowInfo.get(0);
		 }
		 else
		 {
			 strObjectId1 = (String) strlRowInfo.get(1);
		 }

	}
}

if (strObjectId1 == null)
{
 strObjectId1 = emxGetParameter(request,"objectId");
}

contentURL = "../common/emxForm.jsp?form=ENCEBOMCompareWebform&mode=Edit&formHeader=emxEngineeringCentral.command.BOMCompare&postProcessURL=../engineeringcentral/emxEngineeringCentralBOMComparePostProcess.jsp&suiteKey=EngineeringCentral&findMxLink=false&showClipboard=false&IsStructureCompare=true&objectId1="+strObjectId1+"&objectId2="+strObjectId2+"&objectId="+strObjectId1+"&HelpMarker=emxhelppartbomcompare&preProcessJavaScript=preProcessInBOMCompare";


%>

<html>
<head>
</head>

<body scrollbar="no" border="0">
<script language="JavaScript" type="text/javascript">
//XSSOK
document.location.href='<%=XSSUtil.encodeForJavaScript(context,contentURL)%>';
</script>
</body>

</html>
