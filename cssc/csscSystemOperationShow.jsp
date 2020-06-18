<%@page import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.common.Company,com.matrixone.apps.common.Person"%>
<%@page
    import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%@page contentType="text/html;charset=utf-8"%>
<%
String objectId = emxGetParameter(request,"objectId");
%>

<script>
window.location.href = "../common/emxIndentedTable.jsp?table=CSSCShowCreateAssemblyTable&expandProgram=CSSCCreateAssemblJPO:getAssembly&editLink=true&toolbar=CSSCAssemblyToolbar&selection=multiple&objectId=<%=objectId%>";
</script>