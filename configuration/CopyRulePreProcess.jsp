<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<html>

<body>
<%
try {
	String objectId = emxGetParameter(request,"objectId");
	DomainObject domObject = new DomainObject(objectId);
	String objectType = domObject.getType(context);
	
	 if(mxType.isOfParentType(context, objectType,ConfigurationConstants.TYPE_LOGICAL_FEATURE)){
		 %>
         <script language="javascript" type="text/javaScript">         
		 var submitURL="../common/emxFullSearch.jsp?field=TYPES=type_BooleanCompatibilityRule:RULE_TYPE=Logical&table=FTRBooleanCompatiblityRuleSearchTable&showInitialResults=false&selection=single&HelpMarker=emxhelpcompatibilityrulecopy&submitAction=refreshCaller&hideHeader=true&submitURL=../configuration/BCRCopyPreProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>";
	     showModalDialog(submitURL,575,575,"true","Large");
	     </script>
         <%  
	 }else{
		 %>
		 <script language="javascript" type="text/javaScript">         
		 var submitURL="../common/emxFullSearch.jsp?field=TYPES=type_BooleanCompatibilityRule&table=FTRBooleanCompatiblityRuleSearchTable&showInitialResults=false&selection=single&HelpMarker=emxhelpcompatibilityrulecopy&submitAction=refreshCaller&hideHeader=true&submitURL=../configuration/BCRCopyPreProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>";
		 showModalDialog(submitURL,575,575,"true","Large");
		 </script>
	     <% 
	 }
} 
catch (Exception e) {
	session.putValue("error.message", e.getMessage());
}
%>
</body>
</html>

