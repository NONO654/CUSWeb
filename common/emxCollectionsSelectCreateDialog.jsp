<%--  emxCollectionsSelectCreateDialog.jsp - The content page for selecting/creating Collections

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

      static const char RCSID[] = $Id: emxCollectionsSelectCreateDialog.jsp.rca 1.20 Wed Oct 22 15:47:59 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@ page import="com.matrixone.apps.domain.util.MapList,
                 com.matrixone.apps.domain.util.SetUtil,
                 com.matrixone.apps.domain.DomainObject,
                 com.matrixone.apps.domain.util.XSSUtil,
                 matrix.db.Set" %>

<%@include file = "../emxTagLibInclude.inc"%>

<script language="JavaScript" src="scripts/emxUICollections.js" type="text/javascript"></script>
<%@include file = "../emxJSValidation.inc" %>

<script language="Javascript">

    function SelectChkBox()
    {
        document.frmCreateAppendCollection.setRadio[0].checked=true;
    }

  function doSubmit() {
    var length = document.frmCreateAppendCollection.setRadio.length;
    var bFlag = false;
    
    // Validating if any collection has selected for addition or not
    if(length>0)
    {
        for(var i=0;i<length;i++)
        {
            if(document.frmCreateAppendCollection.setRadio[i].checked)
            {
                bFlag = true;
                break;
            }
        }
    }
    var idList = "";
    if (parent.getWindowOpener().document.formDataRows != null)
      idList = parent.getWindowOpener().document.formDataRows.IdList.value;

    if (idList != "")
    {
      document.frmCreateAppendCollection.IdList.value = idList;
    }
    if((document.frmCreateAppendCollection.setRadio.checked)||(document.frmCreateAppendCollection.setRadio[0].checked))
    {
        var nameValue= trimWhitespace(document.frmCreateAppendCollection.setName.value);
        var nameCheckValue = checkForNameBadChars(nameValue,false);
    
    if (nameValue == "") {
       alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Collections.PleaseEnterCollectionName</emxUtil:i18nScript>");
       document.frmCreateAppendCollection.setName.focus();
       return;
    }
    else if (charExists(nameValue, '"')||charExists(nameValue, '#')||(nameCheckValue == false)){
      alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.InvalidName</emxUtil:i18nScript>");
      document.frmCreateAppendCollection.setName.focus();
      return;
    }
    else if (!checkForNameLength128(nameValue)){
      alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ErrorMsg.ValidateLength</emxUtil:i18nScript>");
      document.frmCreateAppendCollection.setName.focus();
      return;
    }
  }
 if(!bFlag)
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ErrorMsg.SelectCollection</emxUtil:i18nScript>");
    document.frmCreateAppendCollection.setName.focus();
    return;
  }
  else
  {
    document.frmCreateAppendCollection.action= "emxCollectionsCreateAppendProcess.jsp"
    document.frmCreateAppendCollection.submit();
   }
}
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<form name="frmCreateAppendCollection" method="post" onsubmit="doSubmit();return false" >
<%
  StringBuffer memberName           = new StringBuffer("member");
  int nameLen                       = 6;
  String[] memberIds                = (String[]) session.getAttribute("emx.memberIds");

  // Get Collections for user.
  String strCollectionName          = "";
  String strCollectionCount         = "";
  String queryString                = request.getQueryString();
  MapList collectionMapList         = null;
  int iValue                        = 0;
  String strCommand                 = "";
  String strResult                  = "";
  String strCollectionDescription   = "";
  String strTypeCheck               = "checkbox";
  //Modified for Bug 342586
  String strSystemCollection        = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
  String strCollectionLabel         = "";
  collectionMapList                 = SetUtil.getCollections(context);
  String langStr                    = request.getHeader("Accept-Language");
  String addFrom3DSearch = emxGetParameter(request,"addFrom3DSearch");
  
%>
<table class="list" >
<!--//XSSOK -->
  <fw:sortInit defaultSortKey="<%= DomainObject.SELECT_NAME %>" defaultSortType="string" resourceBundle="emxFrameworkStringResource" mapList="<%= collectionMapList %>" params="<%= queryString %>" ascendText="emxFramework.Common.SortAscending" descendText="emxFramework.Common.SortDescending" />

    <!-- Table Column Headers -->
    <tr>
      <th style="text-algin:center" width="5%">
       <input type="checkbox" name="checkAll" onclick="allSelected('frmCreateAppendCollection')" />
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

<%
        String strnewCollectionMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Collections.NewCollection", new Locale(langStr));
%>
    <tr class='<fw:swap id="odd"/>'>
            <!--//XSSOK -->
            <td style="text-align:center" width="5%"><input type="<%=strTypeCheck%>" name="setRadio" value="" onclick="highlightCollectionName();updateSelected('frmCreateAppendCollection')" /></td>
            <!--//XSSOK -->
            <td class="inputField"><input type="text" name="setName" size="50" value="<%=strnewCollectionMsg%>" onFocus="focusCollectionName()" onclick="focusCollectionName()" onKeyPress="SelectChkBox()" /></td>
            <td><input type="hidden" name="addFrom3DSearch" value="<%=addFrom3DSearch %>"/></td>
            <td class="inputField"><textarea name="setDescription" rows="5" cols="25"></textarea></td>
            <td width="15%" align="center">0</td>
    </tr>
<!-- \\XSSOK -->    
        <fw:mapListItr mapList="<%= collectionMapList %>" mapName="collectionMap">
    <%
    
          strCollectionName  = (String)collectionMap.get("name");
          strCollectionCount = (String)collectionMap.get("count");
          strResult          = MqlUtil.mqlCommand(context,"list property on set $1",strCollectionName);
          iValue             = strResult.indexOf("value");
          // Added for Clipboard Collections Label
             if(strCollectionName.equals(strSystemCollection))
             {
                  strCollectionLabel = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(langStr), "emxFramework.ClipBoardCollection.NameLabel");
             }
             else
             {
                 strCollectionLabel = strCollectionName;
             }
          // Ended
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
            <!--//XSSOK -->
            <td style="text-align:center" width="5%"><input type="<%=strTypeCheck%>" name="setRadio" value="<%=XSSUtil.encodeForHTMLAttribute(context, strCollectionName)%>" onclick="this.focus();updateSelected('frmCreateAppendCollection');unhighlightCollectionName()" /></td>
            <td width="75%" ><b><img src="../common/images/iconSmallCollection.gif" border="0" />&nbsp;<xss:encodeForHTML> <%=strCollectionLabel%></xss:encodeForHTML></b></td>
            <td width="25%"><xss:encodeForHTML><%=strCollectionDescription%></xss:encodeForHTML></td>
            <td width="15%" align="center"><xss:encodeForHTML><%=strCollectionCount%></xss:encodeForHTML></td>
          </tr>
          </fw:mapListItr>
<%
            if (collectionMapList.size() == 0)
            {
            %>
                      <tr class="even" ><td colspan="7" align="center" ><emxUtil:i18n localize="i18nId">emxFramework.Collections.NoCollections</emxUtil:i18n></td></tr>
            <%
            }

%>

</table>
<%
  if (memberIds != null)
  {
    //session.removeAttribute("emx.memberIds");
    for (int i = 0;i < memberIds.length;i++)
    {
      memberName.append(i);
      %>
      <input type="hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context,memberName.toString())%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, memberIds[i])%>" />
      <%
      memberName.setLength(nameLen);
    }
  }
%>
<input type="hidden" name="IdList" value="" />
</form>
<script language="Javascript">
      document.frmCreateAppendCollection.setName.focus();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
