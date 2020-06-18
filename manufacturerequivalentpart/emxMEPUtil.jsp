<%@ page import="matrix.db.Context" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%
String[] sCheckBoxArray = (String[])emxGetParameterValues(request, "emxTableRowId");

matrix.util.StringList objList = new matrix.util.StringList(sCheckBoxArray.length);

for (int i =0; i<sCheckBoxArray.length; i++) 
{
    if (sCheckBoxArray[i].indexOf("|") != -1)
    {
        matrix.util.StringList slids = com.matrixone.apps.domain.util.FrameworkUtil.split(sCheckBoxArray[i], "|");
        objList.add((String)slids.get(0));
    }
    else 
    {
        objList.add(sCheckBoxArray[i]);
    }
}

String name = "";
String id   = "";

for (int i = 0 ;i<objList.size();i++)
{
	com.matrixone.apps.domain.DomainObject domObject =new com.matrixone.apps.domain.DomainObject((String)objList.get(i));
	
	if("".equals(name) && "".equals(id))
    {
        name  = domObject.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
        id    = (String)objList.get(i) ;
    }
    else
    {
        name  = name + "," +domObject.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
        id    = id + "," +(String)objList.get(i) ;
    }
}

String parentForm		= emxGetParameter(request,"formName");
String parentField		= emxGetParameter(request,"fieldNameDisplay");
String parentFieldOId	= emxGetParameter(request,"fieldNameActual");
%>

<script language="javascript" type="text/javascript">
//XSSOK
	if(parent.getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>)
	{
	    //XSSOK
	    parent.getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.<%=XSSUtil.encodeForJavaScript(context,parentField)%>.value="<%=XSSUtil.encodeForJavaScript(context,name)%>";
	    //XSSOK
	    parent.getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.<%= XSSUtil.encodeForJavaScript(context,parentFieldOId)%>.value="<%=XSSUtil.encodeForJavaScript(context,name)%>";
	    parent.getTopWindow().closeWindow();
	}
</script>

