<!-- emxTableMarkupFilter.jsp-->
<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxStyleListPFInclude.inc"%>
<%@ page import="com.matrixone.apps.common.util.*"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

String strLanguage =context.getSession().getLanguage();
String AllStates=i18nNow.getI18nString("emxEngineeringCentral.Markup.AllStates","emxEngineeringCentralStringResource",strLanguage);
String ProposedState=i18nNow.getI18nString("emxEngineeringCentral.Markup.ProposedState","emxEngineeringCentralStringResource",strLanguage);
String AppliedState=i18nNow.getI18nString("emxEngineeringCentral.Markup.AppliedState","emxEngineeringCentralStringResource",strLanguage);
String RejectedState=i18nNow.getI18nString("emxEngineeringCentral.Markup.RejectedState","emxEngineeringCentralStringResource",strLanguage);
String AllOwners=i18nNow.getI18nString("emxEngineeringCentral.Markup.AllOwners","emxEngineeringCentralStringResource",strLanguage);
  

String tableID = Request.getParameter(request, "tableID");

%>
<head>
<link rel="stylesheet" href="styles/emxUIDefault.css"type="text/css" />
<link rel="stylesheet" href="styles/emxUIList.css" type="text/css"   />



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



<td width="50"><label>State</label></td>
<td class="inputField" ><select name="filterState" id="">
<option value="All" selected ><%=AllStates%></option>
<option value="Proposed" ><%=ProposedState%></option>
<option value="Applied"><%=AppliedState%></option>
<option value="Rejected"><%=RejectedState%></option>
</select>

<td width="20"> &nbsp; </td>
<td width="50"><label>Owner</label></td>
<td class="inputField" ><select name="filterowner" id="">
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
        
        
        
        relpattern=PropertyUtil.getSchemaProperty(context,"relationship_PartMarkup");
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

			<option VALUE="<%=XSSUtil.encodeForHTMLAttribute(context, sOwner)%>"><%=XSSUtil.encodeForHTML(context, sOwner)%></option>
			
                
                
       <% }
           
        }
          
			 
    

%>
</select>
<td width="50"> &nbsp; </td>
<td width="150"><input type="button" name="btnFilter"
value="Filter..." onclick="javascript:filterData()" /></td>
</tr>
</table>

<script language="javascript">

function filterData()
{
var filterProcessURL="emxTableMarkupFilterProcess.jsp?tableID=<%=XSSUtil.encodeForURL(context, tableID)%>";
document.filterIncludeForm.action = filterProcessURL;
document.filterIncludeForm.target = "listHidden";
document.filterIncludeForm.submit();

}
</script>

<!--<%--<option VALUE="<%=sOwner%>"><%=sOwner%></option>--%>-->

<input type="hidden" name="tableID" value="<xss:encodeForHTMLAttribute><%=tableID%></xss:encodeForHTMLAttribute>" />
</form>
</body>
</html>
