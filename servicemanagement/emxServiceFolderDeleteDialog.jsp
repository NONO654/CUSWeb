<%--  emxServiceFolderDeleteDialog.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxServiceFolderDeleteDialog.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>


<!-- content begins here -->

<script language="javascript">

    function deleteSelected() 
    {
        if(jsIsClicked()) {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
            return;
        }
        var objForm = document.ServiceFolder;
        var flag = false;
        for (var iProcess = 0; iProcess < document.ServiceFolder.elements.length; iProcess++) 
        {
            if (objForm.elements[iProcess].type == "checkbox" && 
                    objForm.elements[iProcess].checked &&
                    objForm.elements[iProcess].name == "serviceFolderId" ) 
            {
                flag = true;
                break;
            }
        }
        if (flag == true) 
        {
            objForm.action="emxServiceFolderDeleteProcess.jsp";
            if (jsDblClick()) 
            {
                startProgressBar(true);
                objForm.submit();
            }
            return;
        } else {
            alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Command.DeleteServiceFolder.NoServiceFolderSelected</emxUtil:i18nScript>");
            return;
        }
    }

  function doCheck() 
  {
    var objForm = document.ServiceFolder;
    var chkList = objForm.checkAll;

    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('serviceFolderId') > -1)
      {
        objForm.elements[i].checked = chkList.checked;
      }  
    }
  }  

  function updateCheck() 
  {
    var objForm = document.ServiceFolder;
    var chkList     = objForm.checkAll;
    chkList.checked = false;
  }
  
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%  
    MapList serviceFolderMapList =  null;
    MapList serviceFolderFinalMapList = new MapList();
    boolean bFound = false;
  
    if (emxPage.isNewQuery()) 
    {
        MapList serviceFolderObjMapList = null;
        
        int size1= 0;

        SelectList busSelects = new SelectList(3);
        busSelects.add(DomainConstants.SELECT_ID);
        busSelects.add(DomainConstants.SELECT_NAME);
        busSelects.add(DomainConstants.SELECT_DESCRIPTION);
   
        serviceFolderObjMapList = DomainObject.findObjects(
                                    context,            // eMatrix context
                                    PropertyUtil.getSchemaProperty(context, "type_ServiceFolder"),  // type pattern
                                    DomainConstants.QUERY_WILDCARD,         // name pattern
                                    DomainConstants.QUERY_WILDCARD,     // revision pattern
                                    DomainConstants.QUERY_WILDCARD,     // owner pattern
                                    DomainConstants.QUERY_WILDCARD,     // vault pattern
                                    "",        // where expression
                                    true,               // expand types
                                    busSelects);     // object selects

        if(serviceFolderObjMapList != null && (size1 = serviceFolderObjMapList.size()) > 0)
        {
            for(int i = 0 ; i < size1 ; i++ )
            {
            	serviceFolderFinalMapList.add((Map)serviceFolderObjMapList.get(i));
            }
        }

        emxPage.getTable().setObjects(serviceFolderFinalMapList);
        emxPage.getTable().setSelects(new SelectList());
    }
    // this Maplist is the one which is used to make the table.
    serviceFolderMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
    String sParams = "objectId=";
%><!-- //XSSOK -->
  <framework:sortInit  defaultSortKey="<%=DomainConstants.SELECT_NAME%>"  defaultSortType="string"  mapList="<%=serviceFolderMapList%>"  resourceBundle="emxWSManagementStringResource"  ascendText="emxWSManagement.Common.SortAscending"  descendText="emxWSManagement.Common.SortDescending"  params = "<%=sParams%>"  />

<form name = "ServiceFolder" method = "post" action = "" onSubmit="deleteSelected(); return false;">


<table width="100%" cellpadding="3" cellspacing="2">

  <tr>
  
    <th width="5%">
        <input type="checkbox" name="checkAll" onClick="doCheck()" />
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxWSManagement.Common.Name"
        sortKey="<%=DomainConstants.SELECT_NAME%>"
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxWSManagement.Common.Description"
        sortKey=""
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>
      
  </tr>

<%
        String strValue = "";
        StringTokenizer strTokenizer = null;
        String strName = "";
        String strDescription = "";
%>
<!-- //XSSOK -->
  <framework:mapListItr mapList="<%=serviceFolderMapList%>" mapName="serviceFoldersMap">

    <tr class='<framework:swap id ="1" />'>
      <!-- //XSSOK -->
	  <td><input type="checkbox" name="serviceFolderId" value="<%=serviceFoldersMap.get(DomainConstants.SELECT_ID)%>" onClick="updateCheck()" /></td>
<%
		strName = (String)serviceFoldersMap.get(DomainConstants.SELECT_NAME);
        strDescription = (String)serviceFoldersMap.get(DomainConstants.SELECT_DESCRIPTION);
%>
      <!-- //XSSOK -->
	  <td><%=strName%>&nbsp;</td>
      <!-- //XSSOK -->
	  <td><%=strDescription%>&nbsp;</td>
    </tr>
<%
    bFound = true;
%>
  </framework:mapListItr>

<%
  if (!bFound) 
  {
%>
    <tr class="odd">
       <td class="noresult" colspan="3"><emxUtil:i18n localize="i18nId">emxWSManagement.Command.DeleteServiceFolder.EmptyServiceFolder</emxUtil:i18n></td>
    </tr>
<%
  }
%>
    </table>
    <input type="image" height="1" width="1" border="0" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
