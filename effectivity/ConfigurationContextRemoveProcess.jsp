<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%@page import = "com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="matrix.util.StringList"%>
<%@page import = "java.util.StringTokenizer"%>
<%
	try
  {
	
	String strObjId = emxGetParameter(request, "objectId");
	String[] strTableRowIds    = emxGetParameterValues(request, "emxTableRowId");
	String strConfigCtxRelIds[]=null;
	strConfigCtxRelIds = new String[strTableRowIds.length];
    StringBuffer sbTableRowId = null;
    for (int i = 0; i < strTableRowIds.length; i++)      // for each table row
    {
    	StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[i] ,"|");
        strConfigCtxRelIds[i]=strTokenizer.nextToken();
    }   
    
    ContextUtil.startTransaction(context,true);
    DomainRelationship.disconnect(context, strConfigCtxRelIds);
    ContextUtil.commitTransaction(context);
    
    %>

    <script language="javascript" type="text/javaScript">

          parent.editableTable.loadData();
          parent.rebuildView();

    </script>
    <%
    
	}catch(Exception ex){
		ContextUtil.abortTransaction(context);
		%>
        <script language="javascript" type="text/javaScript">
         alert("<%=ex.getMessage()%>");//XSSOK                 
        </script>
        <%    
	}
	%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
