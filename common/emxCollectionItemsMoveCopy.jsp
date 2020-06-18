<%--  emxCollectionItemsMoveCopy.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionItemsMoveCopy.jsp.rca 1.3.3.2 Wed Oct 22 15:48:30 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@ page import="com.matrixone.apps.domain.util.MapList,
                 com.matrixone.apps.domain.util.SetUtil,
                 com.matrixone.apps.domain.DomainObject,
                 matrix.db.Set" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="JavaScript" src="scripts/emxUICollections.js" type="text/javascript"></script>
<script>
addStyleSheet("emxUIToolbar");
</script>
<%@include file = "../emxJSValidation.inc" %>


<%
/*	
This page is used to move / copy the selected items from one collection to another collection
*/


String strCollectionItems   = emxGetParameter(request,"selectedCollections");
String strMode              = emxGetParameter(request,"mode");
String strQueryString       = request.getQueryString();
String strfrmCollectionName = emxGetParameter(request,"fromCollectionName");
int icount                  = 0;
String strCollectionLabel   = "";

String strSystemGeneratedCollectionLabel    = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel");
//Modified for Bug 342586
String strSystemGeneratedCollection         = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");

MapList mplCollections              = SetUtil.getCollections(context);
String strCollectionName            = "";
String strCollectionCount           = "";
String strCollectionDescription     = "";
String strResult                    = "";
int iValue                          = 0;

%>
<form name="copyForm" method="post" onsubmit="doneMethod(); return false" action="emxCollectionItemsMoveCopyProcess.jsp">
<input type=hidden name="CollectionItems" value="<xss:encodeForHTMLAttribute><%=strCollectionItems%></xss:encodeForHTMLAttribute>"/>
<input type=hidden name="mode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>"/>
<input type=hidden name="fromCollectionName" value="<xss:encodeForHTMLAttribute><%=strfrmCollectionName%></xss:encodeForHTMLAttribute>"/>
<table class="list">

  <fw:sortInit
    defaultSortKey="<%= DomainObject.SELECT_NAME %>"
    defaultSortType="string"
    resourceBundle="emxFrameworkStringResource"
    mapList="<%= mplCollections %>"
    params="<%= XSSUtil.encodeURLwithParsing(context, strQueryString) %>"
    ascendText="emxFramework.Common.SortAscending"
    descendText="emxFramework.Common.SortDescending" />

    <!-- Table Column Headers -->
    <tr>
      <th style="text-algin:center" width="5%">
          &nbsp;
      </th>

      <th nowrap="nowrap" width="50%">
        <fw:sortColumnHeader
            title="emxFramework.Common.Name"
            sortKey="<%= DomainObject.SELECT_NAME %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
      
      <th nowrap="nowrap" width="25%">
	    <fw:sortColumnHeader
            title="emxFramework.Common.Description"
            sortKey="<%= DomainObject.SELECT_DESCRIPTION %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
    
      <th nowrap="nowrap" width="15%">
        <fw:sortColumnHeader
                  title="emxFramework.Collections.ItemCount"
                  sortKey="count"
                  sortType="string"
                  anchorClass="sortMenuItem" />
      </th>

    </tr>

    <fw:mapListItr mapList="<%= mplCollections %>" mapName="collectionMap">
	<%
		  strCollectionName  = (String)collectionMap.get("name");
		  strCollectionCount = (String)collectionMap.get("count");
		  
		  if(strCollectionName.equals(strSystemGeneratedCollection))
		  {
		      strCollectionLabel = strSystemGeneratedCollectionLabel;
		  }
		  else
		  {
		      strCollectionLabel = strCollectionName;
		  }
		  // System Generated Collection should not be displayed while moving or copying the items 
		  if(!strCollectionName.equals(strfrmCollectionName))
		  {
		   
		      icount++;
		      strResult = MqlUtil.mqlCommand(context,"list property on set $1",strCollectionName);
		      iValue  = strResult.indexOf("value");
		      if(iValue!=-1)
		      {
		      	strCollectionDescription = strResult.substring(iValue+6);
		      }
		      else
		      {	
		      	strCollectionDescription = "";    
		      }
		      	      
		%>
		      <tr class='<fw:swap id="odd"/>'>
		        <td style="text-align:center" width="5%"><input type="radio" name="setRadio" value="<xss:encodeForHTMLAttribute><%=strCollectionName%></xss:encodeForHTMLAttribute>"/></td>
		        <td width="55%" ><b><img src="../common/images/iconSmallCollection.gif" border="0" />&nbsp;<xss:encodeForHTML> <%=strCollectionLabel%></xss:encodeForHTML></b></td>
		        <td width="25%"><xss:encodeForHTML><%=strCollectionDescription%></xss:encodeForHTML></td>
		        <td width="15%" align="center"><xss:encodeForHTML><%=strCollectionCount%></xss:encodeForHTML></td>
		      </tr>
	      <%
	      }
		  %>
	      
	      </fw:mapListItr>
	      <%
	      	if(icount==0)
	      	{
	     %>
              <tr class="even" ><td colspan="7" align="center" ><emxUtil:i18n localize="i18nId">emxFramework.Collections.NoUserDefinedCollections</emxUtil:i18n></td></tr>

	      <%
	      	}
	      %>
	</table>
	
	
<script language="javascript">
function doneMethod()
{
	   var bflag = false;
       var length = document.copyForm.setRadio.length;
	   if(length>0)
	   {
		  for(var i=0;i<length;i++)
          {
	       	if(document.copyForm.setRadio[i].checked==true)
	       	{
	       		bflag = true;
	       		break;
	       	}
		  }
       }
	   else
       {
    	 if(document.copyForm.setRadio.checked == true)
    	 {
    		bflag = true;
    	 }
       }
       if(!bflag)
       {
       		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ErrorMsg.SelectCollection</emxUtil:i18nScript>");
       }
       else
       {
       		document.copyForm.submit();
       }
   
}
</script>	
	
