<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>

<!-- Page directives -->
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>

<%@page import = "matrix.util.StringList"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.matrixone.util.*"%>
<%@page import = "matrix.db.*, matrix.util.*,
                  com.matrixone.util.*,
                  com.matrixone.servlet.*,
                  com.matrixone.apps.framework.ui.*,
                  com.matrixone.apps.domain.util.*, 
                  com.matrixone.apps.domain.*, 
                  java.util.*, 
                  java.io.*, 
                  java.net.URLEncoder, 
                  java.util.*,
                  com.matrixone.jsystem.util.*"
                  errorPage="../common/emxNavigatorErrorPage.jsp"%>
<%@ page import = "com.matrixone.apps.domain.util.*,java.text.*" %>

<!-- Include directives -->

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script src="../common/scripts/emxUICalendar.js"></script>
<script src="../common/scripts/emxUIModal.js"></script>
<script src="../common/scripts/emxUIPopups.js"></script>
<script src="../common/scripts/emxSearchGeneral.js"></script>
<script src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUISearch.js"></script>
<script src="../emxUIPageUtility.js"></script>
<script language="javascript" src="../common/scripts/emxTypeAhead.js"></script>
<script type="text/javascript"> addStyleSheet("emxUITypeAhead"); </script>

<jsp:useBean id="formEditBean"
class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>

<jsp:useBean id="simBean" 
    class="com.dassault_systemes.smaslm.matrix.web.smaSearchSimulation" 
    scope="session"/>

<%
String sStar  = simBean.getStarLabel();
String sClear = simBean.getClearLabel();
String tableID = emxGetParameter(request,"tableID");
%>

<script >

addStyleSheet("emxUIDefault");
addStyleSheet("emxUIForm");
addStyleSheet("emxUIMenu");

    function validateForm()
    {
        return true;
    }

</script>

<link rel="stylesheet" href="styles/emxUIDefault.css"
type="text/css">
<link rel="stylesheet" href="styles/emxUIList.css" type="text/
css">

</head>
<body>

<!--<h4>Filter Page</h4>-->

<form name="editDataForm">
    <table border="0" width="65%" cellpadding="5" cellspacing="5">   
    <tr>
        <td width="150" class="label">
            <center><h3>Size</h3></center>
        </td>
        <td class="inputField">    
            <input type="hidden" name="ModifiedDisplayStart_msvalue" value="">        
            <input type="text" name="ModifiedDisplayStart" value="<%=sStar%>" 
                maxlength="" size="15" >&nbsp;
                <a class="dialogClear" href="#" 
                onclick="javascript:clearModified(); return false;">
                <%=sClear%></a>
        </td>       
        <td width="30">  </td>
        <td width="150"><input type="button" name="btnFilter"
                value="Filter" onclick="javascript:filterData();">
        </td>        
    </tr>       
</table>

<input type="hidden" name="tableID" value="<%=tableID%>">
</form>


</body>

<script language="javascript">

    function filterData()
    {   
    document.editDataForm.action =  "../simulationcentral/smaSimulationRetentionFilterProcess.jsp"; 
    document.editDataForm.target = "listHidden";    
    document.editDataForm.submit(); 

    }
    
   
    
    
    // Changes modified date field to be a star
    function clearModified()
    {    
        document.editDataForm.ModifiedDisplayStart.value="<%=sStar %>";
    }

    
    
</script>

</html>
