
<%--  emxInfoRelationshipFilter.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  $Archive: /InfoCentral/src/InfoCentral/emxInfoRelationshipFilter.jsp $
  $Revision: 1.1$
  $Author: ds-hbhatia$

--%>

<%--
 *
 * $History: IEFRelationshipFilter.jsp $
 * 
 * *****************  Version 3  *****************
 * User: Mallikr      Date: 11/26/02   Time: 5:57p
 * Updated in $/InfoCentral/src/InfoCentral
 * added header
 *
 * ***********************************************
 *
--%>
<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ include file = "../common/emxNavigatorInclude.inc"%>
<%@ include file = "../components/emxSearchInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="javascript">
function filterData()
{				   
	var filterProcessURL="IEFRelatedItemsFilterProcess.jsp?";

	var toFrom="*";
	if(true)
	{
		toFrom="to";
	}
	if(true)
	{
	  if(toFrom=="*"){
		toFrom="from";
	   }
	  else {
		toFrom="*";
	   }
	}

	filterProcessURL += "&toFrom=" + toFrom + "";

	document.tableHeaderForm.action = filterProcessURL;
	document.tableHeaderForm.target = "listHidden";
	document.tableHeaderForm.submit();
}
</script>


<html>
<%
	String tableID = Request.getParameter(request, "tableID");
	String timeStamp = Request.getParameter(request, "timestamp");
	HashMap requestMap = (HashMap) tableBean.getTableData(tableID).get("RequestMap");
	String objectId = (String) requestMap.get("objectId");
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	
	String toFrom		= null; //emxGetSessionParameter(request,"toFrom");
	String relationshipName =  null; // emxGetSessionParameter(request,"relationshipName");
	String isTemplateType	=  null; //emxGetSessionParameter(request, "isTemplateType");

	Vector assemblyLikeRelNames	= new Vector();
		
	String integName						  = util.getIntegrationName(integSessionData.getClonedContext(session),objectId);
	MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integName,integSessionData.getClonedContext(session));

	if(globalConfigObject != null)
	{
		Hashtable mxRels  = new Hashtable(10);
		String inRelClass = "AssemblyLike";

		globalConfigObject.getMxRelNameDirnTableForClass(mxRels, inRelClass);

		if(mxRels != null)
		{
			Enumeration assemblyLikeRelNamesEnum = mxRels.keys();
			while(assemblyLikeRelNamesEnum.hasMoreElements())
				assemblyLikeRelNames.addElement((String)assemblyLikeRelNamesEnum.nextElement());
		}
	}
	
	if(toFrom==null|| toFrom.equals("null"))
		toFrom="*";
	
	String tochecked="";
	String fromchecked="";
	
	if(toFrom.equals("to"))
		tochecked="checked";
	
	if(toFrom.equals("from"))
		fromchecked="checked";
	
	if(toFrom.equals("*"))
	{ 
		tochecked="checked";
		fromchecked="checked";
	}
%>
	<body>
	<form name="tableHeaderForm" method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

	<input type="hidden" name="tableID" value="<xss:encodeForHTML><%=tableID%></xss:encodeForHTML>">
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
    <td align="left">&nbsp;</td>
	<!--XSSOK-->
    <td width="2%" nowrap><input type="checkbox" name="toDirection"  <%=tochecked%> ></td>
    <td width="25%"nowrap>&nbsp;<%=i18nNow.getI18nString("emxIEFDesignCenter.Common.To", "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%></td>
	<!--XSSOK-->
    <td width="2%" nowrap><input type="checkbox" name="fromDirection"  <%=fromchecked%> ></td>
    <td width="25%"nowrap>&nbsp;<%=i18nNow.getI18nString("emxIEFDesignCenter.Common.From", "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%></td>
    <td nowrap>&nbsp;<%=i18nNow.getI18nString("emxIEFDesignCenter.Common.Relationship", "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%>&nbsp;</td>
    <td class="filter"nowrap >
    <select name="relationshipName" >
    <option value ="All" ><%=i18nNow.getI18nString("emxIEFDesignCenter.Common.All", "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%></option>
 <%
      String sRelName = null;
	  BusinessObject  boObject  = null;
	  boObject  = new BusinessObject(objectId);
	  boObject.open(context);
	  String sBustype = null;
	  StringList displayRelNameList = new StringList();
	  Hashtable dispVsActualName    = new Hashtable();
	  BusinessType btConnObj              = boObject.getBusinessType(context);
	  sBustype = btConnObj.getName();
	  btConnObj.open(context);
	  RelationshipTypeList relTypeListObj = btConnObj.getRelationshipTypes(context,true,true,true);
	  btConnObj.close(context);
	  	  			
	  RelationshipTypeItr  relTypeItrObj  = new RelationshipTypeItr(relTypeListObj);
	  while(relTypeItrObj.next())
	  {
		  RelationshipType  relTypeObj    = (RelationshipType) relTypeItrObj.obj();
		  relTypeObj.open(context);
		  sRelName = relTypeObj.getName() ;
		  String displayRelName = i18nNow.getMXI18NString(sRelName,"",request.getHeader("Accept-Language"),"Relationship");
		  displayRelNameList.addElement(displayRelName);
		  dispVsActualName.put(displayRelName, sRelName);
		  displayRelNameList.sort();
		  relTypeObj.close(context); 
	  }

	  Iterator displayRelNameListItr = displayRelNameList.iterator();
	  while(displayRelNameListItr.hasNext())
	  {
		  String displayRelName = (String)displayRelNameListItr.next();
		  sRelName              = (String) dispVsActualName.get(displayRelName);
		  String selected       = "";
		  if(relationshipName!=null && relationshipName.equals(sRelName))
			selected="selected";
		  if(isTemplateType != null && isTemplateType.equalsIgnoreCase("true") && assemblyLikeRelNames.size()>0)
		  {
			if(assemblyLikeRelNames.contains(sRelName))
			{
%>
				<option value = "<%=sRelName%>"  <%=selected%> ><%=displayRelName%></option>
<%
			}
		  }
		  else
		  {
%>
			<option value = "<%=sRelName%>"  <%=selected%> ><%=displayRelName%></option>		
<%
		  }

          }
%>
      </select>
      </td>

    <td align="right">
      <table border="0">
        <tr>
          <td nowrap><a href="javascript:filterData()" ><img src="../iefdesigncenter/images/iconFilter.gif" border="0" alt="<%=i18nNow.getI18nString("emxIEFDesignCenter.Common.Refresh",  "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%>"></a></td>
          <td nowrap ><a href="javascript:filterData()" ><%=i18nNow.getI18nString("emxIEFDesignCenter.Common.Refresh",  "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%></a></td>
        </tr>
      </table>
    </td>
    <tr>
    </table>
	</form>
	</body>
</html>
