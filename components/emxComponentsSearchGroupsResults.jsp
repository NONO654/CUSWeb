<%-- emxComponentsSearchGroupsResults.jsp -- The Page displays the List of Group

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSearchGroupsResults.jsp.rca 1.7 Wed Oct 22 16:17:51 2008 przemek Experimental przemek przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String languageStr      = request.getHeader("Accept-Language");
  String objectId         = emxGetParameter(request, "objectId");
  String loginName        = emxGetParameter(request,"loginName");
  String password         = emxGetParameter(request,"password");
  String confirmpassword  = emxGetParameter(request,"confirmpassword");
  String firstName        = emxGetParameter(request,"firstName");
  String middleName       = emxGetParameter(request,"middleName");
  String lastName         = emxGetParameter(request,"lastName");
  String companyName      = emxGetParameter(request,"companyName");
  String location         = emxGetParameter(request,"location");
  String businessUnit     = emxGetParameter(request,"businessUnit");
  String workPhoneNumber  = emxGetParameter(request,"workPhoneNumber");
  String homePhoneNumber  = emxGetParameter(request,"homePhoneNumber");
  String pagerNumber      = emxGetParameter(request,"pagerNumber");
  String emailAddress     = emxGetParameter(request,"emailAddress");
  String faxNumber        = emxGetParameter(request,"faxNumber");
  String webSite          = emxGetParameter(request,"webSite");
  String sNamePattern     = emxGetParameter(request,"txtName");
  
  String sTopChecked      = emxGetParameter(request,"chkTopLevel");
  String sSubChecked      = emxGetParameter(request,"chkSubLevel");
  String sCallpage        = emxGetParameter(request, "callPage");
  String sGroupList       = emxGetParameter(request, "groupList");
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String strMultiSelect   = emxGetParameter(request,"multiSelect");
  
  String mainSearchPage   = emxGetParameter(request,"mainSearchPage");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  
  String parentFieldDisp  = emxGetParameter(request,"fieldDisp");
  
  String queryLimit = emxGetParameter(request,"queryLimit");
  int groupLimit=Integer.parseInt(queryLimit);

  // Only one line added - Nishchal
  String keyValue = emxGetParameter(request,"keyValue");
  if(keyValue == null || "null".equals(keyValue))
  {
      keyValue = "";
  }

  if(objectId == null ){
    objectId = "";
  }
  if(parentFieldDisp == null || "null".equals(parentFieldDisp)) {
    parentFieldDisp ="";
  } else {
    parentFieldDisp = parentFieldDisp.trim();
  }
  
  
  boolean multiSelect = true;
  if(strMultiSelect != null && "false".equals(strMultiSelect)){
    multiSelect = false;
  }
  
  String sNewSearchPage ="emxComponentsSearchGroupsDialog.jsp";
  if(mainSearchPage != null && !"null".equals(mainSearchPage) && !"".equals(mainSearchPage))
  {
    sNewSearchPage = mainSearchPage;
  }    
    
%>

<script language="javascript">
  function newSearch() 
  {
     
     // Added keyValue - Nishchal 
      parent.location='<%=XSSUtil.encodeForURL(context, sNewSearchPage)%>?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&form=<%=XSSUtil.encodeForURL(context, parentForm)%>&field=<%=XSSUtil.encodeForURL(context, parentField)%>&multiSelect=true&targetSearchPage=&mainSearchPage=<%=XSSUtil.encodeForURL(context, sNewSearchPage)%>&callPage=<%=XSSUtil.encodeForURL(context, sCallpage)%>&txtName=<%=XSSUtil.encodeForURL(context, sNamePattern)%>&chkTopLevel=<%=XSSUtil.encodeForURL(context, sTopChecked)%>&chkSubLevel=<%=XSSUtil.encodeForURL(context, sSubChecked)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>';
  }

// Modified the function name as it was clashing and also modified where it was being called - Nishchal
  function doCheckCheckbox(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;

    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem') > -1){
        objForm.elements[i].checked = chkList.checked;
      }

  }

// Modified the function name as it was clashing and also modified where it was being called - Nishchal
  function updateCheckCheckbox(checkbox) {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    if (checkbox.checked == false)
    {
        chkList.checked = false;
    }
    else
    {
        var checkBoxObjects = objForm.elements[checkbox.name];
        if (checkBoxObjects.length == null || (checkBoxObjects.length == "undefined"))
        {
            chkList.checked = true;
        }
        else
        {
            var checkHeader=0;
            for (var i = 0; i < checkBoxObjects.length; i++)
            {
                if (checkBoxObjects[i].checked == true)
                {
                    checkHeader++;
                }
            }
            if(checkHeader == checkBoxObjects.length)
            {
                chkList.checked = true;
            }
            else
            {
                chkList.checked = false;
            }
        }
    }
  }


  function submitform() {
    var checkedFlag = "false";
    var chkbxFlag = "false";

    var displayGroup="";
    var originalGroup = "";    

    if (document.templateresults.groupList.value == ""){
      document.templateresults.groupList.value = "|";
    }
    // force to select atleast one member to remove
<%
   if(multiSelect) 
   {
%>    
    for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
      if (document.templateresults.elements[varj].type == "checkbox") {
        chkbxFlag = "true";
        if (document.templateresults.elements[varj].checked ){
          checkedFlag = "true";
          if (document.templateresults.elements[varj].name.indexOf('chkItem') > -1) {
            if (document.templateresults.groupList.value.indexOf("|"+document.templateresults.elements[varj].value+"|") == -1) {
              document.templateresults.groupList.value=document.templateresults.groupList.value+document.templateresults.elements[varj].value+"|";
            }
          }
        }
      }
    }
    
    if ((checkedFlag == "false") && (chkbxFlag == "true")) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.SearchGroup.SelectOne</emxUtil:i18nScript>");
      return;
    } else if("CreatePeopleRoleSumary" == "<%=XSSUtil.encodeForJavaScript(context, sCallpage)%>"){
      var stmt1 = "parent.window.getWindowOpener().document.<%=XSSUtil.encodeForURL(context, parentForm)%>.<%=XSSUtil.encodeForURL(context, parentField)%>.value=parent.window.getWindowOpener().document.<%=XSSUtil.encodeForURL(context, parentForm)%>.<%=XSSUtil.encodeForURL(context, parentField)%>.value + document.templateresults.groupList.value";
      eval(stmt1);
      stmt1 = "parent.window.getWindowOpener().document.<%=XSSUtil.encodeForURL(context, parentForm)%>.action=\"emxComponentsPeopleRoleSummaryFS.jsp\"";
      eval(stmt1);
      stmt1 = "parent.window.getWindowOpener().document.<%=XSSUtil.encodeForURL(context, parentForm)%>.submit()";
      eval(stmt1);
      window.closeWindow(); 
    } else if("PeopleEditGroupSumary" == "<%=XSSUtil.encodeForJavaScript(context, sCallpage)%>"){
      document.templateresults.action = "emxComponentsAddGroup.jsp";
      document.templateresults.submit();    
    }
    // Added Nishchal
    else if ("emxComponentsObjectAccessUsersDialog" == "<%=XSSUtil.encodeForJavaScript(context, sCallpage)%>")
    {
        document.location.href=fnEncode("emxComponentsObjectAccessAddUsersProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&userType=Group&userList="+document.templateresults.groupList.value);
    }
    
<%
    } else {
%>
    var count = 0;
    for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
      if (document.templateresults.elements[varj].type == "radio") {
        chkbxFlag = "true";
        if (document.templateresults.elements[varj].checked ){
          checkedFlag = "true";
          originalGroup = document.templateresults.elements[varj].value;
          displayGroup = eval('document.templateresults.GroupName' + count + '.value');
        }
        count++;
      }
    }

     if ((checkedFlag == "false") && (chkbxFlag == "true")) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.SearchGroup.SelectOne</emxUtil:i18nScript>");
      return;
    } else {
      parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, parentForm)%>.<%=XSSUtil.encodeForJavaScript(context, parentField)%>.value=originalGroup;
      var dispFieldPassed = '<%=XSSUtil.encodeForJavaScript(context, parentFieldDisp)%>';
      if(dispFieldPassed != "")
      {
        var dispField = eval('parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, parentForm)%>.<%=XSSUtil.encodeForJavaScript(context, parentFieldDisp)%>');
        if(dispField) {
          dispField.value=displayGroup;
        }
      }
      window.closeWindow();
    }
<%
  }
%>
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  if (sGroupList == null){
    sGroupList = "";
  }

  Group group         = new Group();
  GroupItr groupItr   = null;
  String classname  = "odd";
  String sAll       = "*";
  String sName      = "";
  String sType      = "Group";
  StringList topGroupNameList  = new StringList();
  boolean isFound   = false;
  MapList templateMapList  =  new MapList();
  MapList  constructedList =  new MapList();
  Pattern pattern = null;

  if(sNamePattern != null) {
    pattern = new Pattern(sNamePattern);
  } else {
    sNamePattern = sAll;
    pattern = new Pattern(sAll);
  }
//Added for the Bug No: 325300 
  String caseSensitivity="print system  casesensitive";
  String caseStatus=MqlUtil.mqlCommand(context,caseSensitivity);
  if(caseStatus.equals("CaseSensitive=Off"))
	{
		pattern.setCaseSensitive(false);
	}
// Till Here
  /** List Subfolders based on the Checkbox Select
  * if both 'TopLevel' & 'SubLevel' were selected/not selected  - display all Groups
  * if 'Top Level' selected and 'Sub Level' not selected  - display only Top Level Groups
  * if 'Sub Level' selected and 'Top Level' not selected  - display only Sub Level Groups
  */
  if (emxPage.isNewQuery()) {
    if (sSubChecked != null) {
      if (sTopChecked == null) {
        groupItr = new GroupItr(group.getTopLevelGroups(context));
        while(groupItr.next()) {
          topGroupNameList.add(groupItr.obj().getName());
        }
      }
      GroupList groupList = group.getGroups(context);
      groupItr = new GroupItr(groupList);
    } else {
      if (sTopChecked != null) {
        GroupList groupList = group.getTopLevelGroups(context);
        groupItr = new GroupItr(groupList);
      } else {
        GroupList groupList = group.getGroups(context);
        groupItr = new GroupItr(groupList);
      }
    }

    String strGroup = i18nNow.getI18nString("emxComponents.Common.Group", "emxComponentsStringResource", languageStr);
    
    //String symbolicGrpName = "";
    String strCommand = "";
    MQLCommand mql = new MQLCommand();
    String strResult = "";
    while (groupItr.next()) {
      String sGroup = groupItr.obj().getName();
	  String sMapGroup=sGroup;
      String  tranVal = i18nNow.getAdminI18NString("Group",sGroup,languageStr);
      if (!topGroupNameList.contains(sGroup) && pattern.match((String) sGroup)) {
        String sCheckGroup = "false";
        Hashtable hashTableFinal  = new Hashtable();
        hashTableFinal.put("lock",sCheckGroup);
        hashTableFinal.put("GroupName",sGroup);
        hashTableFinal.put("GroupType",tranVal);
      
        // Do not Add non registered Gropus
        strCommand = "list property on program eServiceSchemaVariableMapping.tcl  to group \"" +sMapGroup+ "\" ";
        mql.executeCommand(context,strCommand);
        strResult = mql.getResult();
        if(strResult != null && !"".equals(strResult.trim()))
        {
            templateMapList.add(hashTableFinal);
            
            if(templateMapList.size()>groupLimit-1){
                break;
            }
        }

        //symbolicGrpName = FrameworkUtil.getAliasForAdmin(context, "group",sGroup, true);
        //if(symbolicGrpName!=null && !"null".equals(symbolicGrpName) && !"".equals(symbolicGrpName)) {
        //  templateMapList.add(hashTableFinal);
        //}
      }
    }

    emxPage.getTable().setObjects(templateMapList);

  }


  // this Maplist is the one which is used to make the table.
  constructedList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

  String sParams  = "loginName="+loginName+"&password="+password+"&confirmpassword="+
                  confirmpassword+"&firstName="+firstName+"&middleName="+
                  middleName+"&lastName="+lastName+"&companyName="+companyName
                  +"&location="+location+"&workPhoneNumber="+workPhoneNumber+
                  "&homePhoneNumber="+homePhoneNumber+"&pagerNumber="+pagerNumber
                  +"&emailAddress="+emailAddress+"&faxNumber="+faxNumber+"&webSite="+
                  webSite+"&objectId="+objectId+"&groupList="+sGroupList;
%>

  <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

  <framework:sortInit
    defaultSortKey="GroupName"
    defaultSortType="string"
    resourceBundle="emxComponentsStringResource"
    mapList="<%=constructedList%>"
    params="<%=XSSUtil.encodeForHTML(context, sParams)%>"
    ascendText="emxComponents.Common.SortAscending"
    descendText="emxComponents.Common.SortDescending" />

<form name="templateresults" id="templateresults" method="post" onSubmit="return false">
  <input type="hidden" name="loginName" value="<xss:encodeForHTMLAttribute><%=loginName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="password"  value="<xss:encodeForHTMLAttribute><%=password%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="confirmpassword" value="<xss:encodeForHTMLAttribute><%=confirmpassword%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="firstName" value="<xss:encodeForHTMLAttribute><%=firstName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="middleName"value="<xss:encodeForHTMLAttribute><%=middleName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="lastName"  value="<xss:encodeForHTMLAttribute><%=lastName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="companyName" value="<xss:encodeForHTMLAttribute><%=companyName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="location" value="<xss:encodeForHTMLAttribute><%=location%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="workPhoneNumber" value="<xss:encodeForHTMLAttribute><%=workPhoneNumber%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="homePhoneNumber" value="<xss:encodeForHTMLAttribute><%=homePhoneNumber%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="pagerNumber" value="<xss:encodeForHTMLAttribute><%=pagerNumber%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="emailAddress" value="<xss:encodeForHTMLAttribute><%=emailAddress%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="faxNumber" value="<xss:encodeForHTMLAttribute><%=faxNumber%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="webSite" value="<xss:encodeForHTMLAttribute><%=webSite%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId %></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="groupList" value="<xss:encodeForHTMLAttribute><%=sGroupList%></xss:encodeForHTMLAttribute>" />

  <!--Nishchal - keyValue-->
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="callPage" value="<xss:encodeForHTMLAttribute><%=sCallpage%></xss:encodeForHTMLAttribute>" />
  
  <table class="list" id="UITable">
    <tr>
<%
    if(multiSelect) {
%>
      <th width="5%" style="text-align:center"><input type="checkbox" name="chkList" id="chkList" onclick="doCheckCheckbox()"></th>
<%
    } else {
%>
      <th width="5%" style="text-align:center">&nbsp;</th>
<%
    }
%>    
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="GroupName"
          sortType="string"/>
      </th>
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Type"
          sortKey="GroupType"
          sortType="string"/>
      </th>
    </tr>
<%
  int i=0;
%>  
	<!-- //XSSOK -->
  <framework:mapListItr mapList="<%=constructedList%>" mapName="templateMap">
    <tr class='<framework:swap id ="1" />'>
<%
      String sGroupName  = (String)templateMap.get("GroupName");
      String sGroupType  = (String)templateMap.get("GroupType");
      String sLock       = (String)templateMap.get("lock");
      isFound            = true;
      if(multiSelect) {
      if (sLock.equals("true")) {
%>
        <td align="center"><img src="../common/images/utilCheckOffDisabled.gif" alt="" /></td>
<%
      } else {
%>
        <td align="center"><input type="checkbox" name ="chkItem" id="chkItem" value = "<xss:encodeForHTMLAttribute><%=sGroupName%></xss:encodeForHTMLAttribute>" onclick="updateCheckCheckbox(this)"/></td>
<%
      }
    } else {
%>
        <td align="center"><input type="radio" name ="chkItem" id="chkItem" value = "<xss:encodeForHTMLAttribute><%=sGroupName%></xss:encodeForHTMLAttribute>"/></td>
        <input type="hidden" name="GroupName<%=i%>" value="<xss:encodeForHTMLAttribute><%=sGroupType%></xss:encodeForHTMLAttribute>" />
<%
    }
%>
        <td><img src="../common/images/iconSmallGroup.gif" name="imgGroup" id="imgGroup" alt="<%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Group",sGroupName,languageStr))%>" /> <%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Group",sGroupName,languageStr))%>&nbsp;</td>
        <td><%=XSSUtil.encodeForHTML(context, sGroupType)%>&nbsp;</td>
    </tr>
<%
  i++;
%>    
  </framework:mapListItr>

<%
  if (!isFound) {
%>
    <tr>
      <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.SearchGroup.NoGroupsFound</emxUtil:i18n></td>
    </tr>
<%
  }
%>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
