<%--  emxTabkeMarkupFilter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<!-- emxTableMarkupFilter.jsp-->
<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxStyleListPFInclude.inc"%>
<%@ page import="com.matrixone.apps.common.util.*"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

 ContextUtil.pushContext(context);

String strLanguage =context.getSession().getLanguage();
/*String AllStates=i18nNow.getI18nString("emxEngineeringCentral.Markup.AllStates","emxEngineeringCentralStringResource",strLanguage);
String ProposedState=i18nNow.getI18nString("emxEngineeringCentral.Markup.ProposedState","emxEngineeringCentralStringResource",strLanguage);
String AppliedState=i18nNow.getI18nString("emxEngineeringCentral.Markup.AppliedState","emxEngineeringCentralStringResource",strLanguage);
String RejectedState=i18nNow.getI18nString("emxEngineeringCentral.Markup.RejectedState","emxEngineeringCentralStringResource",strLanguage);
String AllOwners=i18nNow.getI18nString("emxEngineeringCentral.Markup.AllOwners","emxEngineeringCentralStringResource",strLanguage);
  
//Added For 049225 - Starts
String strState =i18nNow.getI18nString("emxEngineeringCentral.Common.State", "emxEngineeringCentralStringResource",strLanguage);
String strOwner = i18nNow.getI18nString("emxEngineeringCentral.Common.Owner", "emxEngineeringCentralStringResource",strLanguage);
String strFilter = i18nNow.getI18nString("emxEngineeringCentral.Common.Filter", "emxEngineeringCentralStringResource",strLanguage);
//Added For 049225 - Ends*/

String AllStates=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Markup.AllStates");
String ProposedState=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Markup.ProposedState");
String AppliedState=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Markup.AppliedState");
String RejectedState=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Markup.RejectedState");
String AllOwners=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Markup.AllOwners");
  
//Added For 049225 - Starts
String strState =EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Common.State");
String strOwner = EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Common.Owner");
String strFilter = EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Common.Filter");
//Added For 049225 - Ends
String tableID = emxGetParameter(request, "tableID");

%>
<head>
<link rel="stylesheet" href="styles/emxUIDefault.css"type="text/css" />
<link rel="stylesheet" href="styles/emxUIList.css" type="text/css" />



</head>
<body>
<form name="filterIncludeForm">
<table border="0" cellspacing="2" cellpadding="0" width="100%">
<tr>
<td width="99%">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
</tr>
</table>
</td></tr>
</table>
<table>
<tr>


<!-- XSSOK -->
<td width="50"><label><%=strState %></label></td>
<td class="inputField" ><select name="filterState" id="">
<!-- XSSOK -->
<option value="All" selected ><%=AllStates%></option>
<!-- XSSOK -->
<option value="Proposed" ><%=ProposedState%></option>
<!-- XSSOK -->
<option value="Applied"><%=AppliedState%></option>
<!-- XSSOK -->
<option value="Rejected"><%=RejectedState%></option>
</select>

<td width="20"> &nbsp; </td>
<!-- XSSOK -->
<td width="50"><label><%=strOwner %></label></td>
<td class="inputField" ><select name="filterowner" id="">
<!-- XSSOK -->
<option value="All"><%=AllOwners%></option>


<% 
HashMap tableData = tableBean.getTableData(tableID);
HashMap requestMap = tableBean.getRequestMap(tableData); 


String objectId=(String)requestMap.get("objectId");


DomainObject domobj=new DomainObject();
domobj.setId(objectId);

 
        
        StringList mlallOwners=new StringList();
        
        
        
        String relpattern="";
        String typepattern="";
        String sOwner="";
        MapList MarkupIds=new MapList();
       
        StringList selectStmts=new StringList();
        selectStmts.addElement(DomainConstants.SELECT_ID);
        selectStmts.addElement(DomainConstants.SELECT_OWNER);
        
        StringList selectRelStmts=new StringList();
        selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);              
        
        
        
	relpattern=PropertyUtil.getSchemaProperty(context,"relationship_EBOMMarkup");
        typepattern=PropertyUtil.getSchemaProperty(context,"type_BOMMarkup");
        
     
        MarkupIds = domobj.getRelatedObjects(context,relpattern,typepattern,selectStmts,selectRelStmts,false,true,(short)1,null,null);
                    
        Iterator ItrOwner=MarkupIds.iterator();
        Map mapOwner=null;
        
        while(ItrOwner.hasNext())
        {
            mapOwner=(Map)ItrOwner.next();
            sOwner=(String)mapOwner.get(DomainConstants.SELECT_OWNER);
                  
            // To check for Duplicate Values of Owners in the List
             if (!mlallOwners.contains(sOwner))
            {
				  mlallOwners.addElement(sOwner);
				 %>
			<!-- XSSOK -->
			<option VALUE="<%=sOwner%>"><%=sOwner%></option>
			
                
                
       <% }
           
        }
          
			 
    

%>
</select>
<td width="50"> &nbsp; </td>
<!-- XSSOK -->
<td width="150"><input type="button" name="btnFilter" value="<%=strFilter %>" onclick="javascript:filterData()" /></td>
</tr>
</table>

<script language="javascript">

function filterData()
{
var filterProcessURL="emxTableMarkupFilterProcess.jsp?tableID=<xss:encodeForJavaScript><%=tableID%></xss:encodeForJavaScript>";
document.filterIncludeForm.action = filterProcessURL;
document.filterIncludeForm.target = "listHidden";
document.filterIncludeForm.submit();

}
</script>



<input type="hidden" name="tableID" value="<xss:encodeForHTMLAttribute><%=tableID%></xss:encodeForHTMLAttribute>" />

<%

ContextUtil.popContext(context);		

%>


</form>
</body>
</html>

