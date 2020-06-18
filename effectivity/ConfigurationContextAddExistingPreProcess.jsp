

<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%
	try{
String strContextObjId = (String)emxGetParameter(request, "objectId");
String strSearchTypes = EffectivityFramework.getConfigurationContextSearchTypes(context,strContextObjId);
%>
<script language="javascript" type="text/javaScript">
var searchTypes = '<%=strSearchTypes%>';// XSSOK strSearchTypes coming from Java code
var contextObjId = '<%=XSSUtil.encodeForURL(context,strContextObjId)%>';
var vURL= "../common/emxFullSearch.jsp?field=TYPES="+searchTypes+":CURRENT!=policy_Model.state_Inactive&excludeOIDprogram=emxEffectivityFramework:excludeConnectedConfigCtxObjects&objectId="+contextObjId+"&table=CFFConfigurationContext&selection=multiple&showInitialResults=false&submitURL=../effectivity/ConfigurationContextAddExistingPostProcess.jsp?objectId="+contextObjId; //IR-623840-3DEXPERIENCER2019x fixing by adding "CURRENT!=policy_Model.state_Inactive" in URl to prevend inactive models in the search results
  showModalDialog(vURL,575,575,"true","Large");
</script>
<%
}catch(Exception ex)
{
	%>
    <script language="javascript" type="text/javaScript">
     alert("<%=ex.getMessage()%>");//XSSOK                 
    </script>
    <% 
}
%>
