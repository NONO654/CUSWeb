<%@page import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.common.Company,com.matrixone.apps.common.Person"%>
<%@page
    import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%@page contentType="text/html;charset=utf-8"%>
<%
response.setContentType("text/html;charset=UTF-8");
Context context = Framework.getFrameContext(session);
String objectId = emxGetParameter(request,"objectId");
System.out.println("objectId-----111------"+objectId);
String ListUrl="../common/emxIndentedTable.jsp?selection=multiple&isAddExisting=true&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&cancelButton=true&HelpMarker=emxhelpselectorganization&header=emxComponentsCentral.Common.SelectRegion&suiteKey=Components&table=CSICModelTable&program=CSICGetResources:getResources&expandProgram=CSICGetResources:getExpandResources&submitURL=../csic/csicSelectModel.jsp&findMxLink=false&massPromoteDemote=false&customize=false&showRMB=false&showClipboard=false&objectCompare=false&objectId="+objectId;
String ListUrlLoad="../common/emxIndentedTable.jsp?selection=multiple&isAddExisting=true&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&cancelButton=true&HelpMarker=emxhelpselectorganization&header=emxComponentsCentral.Common.SelectRegion&suiteKey=Components&table=CSICModelTable&program=CSICGetResources:getResources&expandProgram=CSICGetResources:getExpandResources&submitURL=../csic/csicSelectModel.jsp&findMxLink=false&massPromoteDemote=false&customize=false&showRMB=false&showClipboard=false&objectCompare=false&objectId="+objectId;

%>

<html>
<head>
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css">
<link rel="stylesheet" type="text/css" href="styles/dashboard.css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script src="../common/scripts/emxUIModal.js" language="JavaScript"></script>
<script src="../common/scripts/emxUICalendar.js" language="JavaScript"></script>
<script src="../common/scripts/emxUIPopups.js" language="JavaScript"></script>
<script src="../common/scripts/jquery-1.9.1.js" language="JavaScript"></script>
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css">
<link rel="stylesheet" type="text/css" href="styles/dashboard.css"> 
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css">
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css">

<link href="../common/styles/emxUIToolbar.css" type="text/css" rel="stylesheet">
<link href="../common/styles/emxUIMenu.css" type="text/css" rel="stylesheet">
<link href="../common/styles/emxUIDialog.css" type="text/css" rel="stylesheet">
<link href="../common/styles/emxUICalendar.css" type="text/css"rel="stylesheet">

<script type="text/javascript">
	
	function item1Search()
    {
		var item1 = $("#item1").val();
		var item1Id = $("#item1Id").val();
		window.open("../common/emxFullSearch.jsp?field=TYPES=type_ProjectSpace&table=PMCGenericProjectSpaceSearchResults&selection=single&hideHeader=true&fieldNameDisplay=item1&fieldNameActual=item1Id&submitURL=../csddc/csddcChoserSumbit2.jsp&HelpMarker=emxhelpfullsearch&showInitialResults=false",'','toolbar=no,menubar=no,resizable=no,location=no,status=no,scrollbars=no,height=800px,width=800px');   
    }
	
	function clearField(fieldId1){
		var field1 = document.getElementById(fieldId1);
		if(field1 != null && field1 != "unidentified"){
			field1.value = "";
		}
	}
	
</script>
</head>
<body onLoad="" style=" height:auto; width:auto">

<div id="tabs1" style="height:86%; width=100%">
				<ul class="block" style="height:100%; width=100%">
			<iframe id="ListId1" src="<%=ListUrlLoad%>" width="100%" height="100%" frameborder="no" border="0" marginwidth="0" marginheight="0" scrolling="no" allowtransparency="yes">
			</iframe>
    </ul>
</div>

</body>

</html>
