  <%--  emxRouteTemplateEditAccess.jsp-Displays the Route Access edit Dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxRouteEditAccess.jsp.rca 1.15 Wed July 11 16:18:26 2008 przemek Experimental przemek $
--%>


<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%!
    // Returns HashMap of all persons and RouteNode ids connected to Route
    public static HashMap getRoutePersons(matrix.db.Context context, DomainObject Route) throws Exception
    {
      StringList objectSelects = new StringList();
      StringList relSelects = new StringList();
      objectSelects.addElement(Route.SELECT_NAME);
      relSelects.addElement(Route.SELECT_RELATIONSHIP_ID);
      MapList mapList = Route.expandSelect(context,
                                            PropertyUtil.getSchemaProperty(context,"relationship_RouteNode"),
                                            Route.TYPE_PERSON,
                                            objectSelects,
                                            relSelects,
                                            false,
                                            true,
                                            (short)1,
                                            null,
                                            null,
                                            null,
                                            false);

       Iterator itr = mapList.iterator();
       StringList sPersonList = new StringList();
       HashMap hashMap = new HashMap();
       while(itr.hasNext()){
         Map map = (Map)itr.next();
         hashMap.put(map.get(Route.SELECT_NAME),map.get(Route.SELECT_RELATIONSHIP_ID));
       }
       return hashMap;
    }
%>

<%int  dataCount=0;%>
<%
  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String objectId           = emxGetParameter(request,"objectId");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String sReadSelected      = "";
  String sReadWriteSelected = "";
  String sAddSelected       = "";
  String sRemoveSelected    = "";
  String sAddRemoveSelected = "";
  String sNoneSelected      = "";
  String sDisplayPersonName = "";
  String sParams            = "jsTreeID="+jsTreeID+"&objectId="+objectId+"&suiteKey="+suiteKey;
  String sPersonName        = "";
  String sOrgName           = "";
  String sProjectMemberId   = "";
  String sSpecificAccess    = "";
  String sType              = "";
  int cols                  = 6;
  boolean isRevised			= false;

  Route BaseObject 			= (Route) DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  BaseObject.setId(objectId);

  
  Access access             = new Access();
  AccessUtil accessUtil     = new AccessUtil();
  String sGrantee           = "";
  String sAccess            = "";
  MapList constructedList   = new MapList();
  HashMap hashMap           = null;
  int i                     = 0;
  DomainObject PersonObj    = DomainObject.newInstance(context);
  String sTypeName          = BaseObject.getType(context);
  String sOwner = BaseObject.getInfo(context, DomainObject.SELECT_OWNER);
  StringList granteeList    = new StringList();

  if (emxPage.isNewQuery()) {

    granteeList               = BaseObject.getGrantees(context);
    if(granteeList == null){
      granteeList = new StringList();
    }
    //remove duplicates in the granteelist
    boolean exist=true;
    for(int k=0;k<granteeList.size();k++){
      Object obj = granteeList.elementAt(k);
      exist=true;
      while(exist){
        if(granteeList.indexOf(obj) == granteeList.lastIndexOf(obj) ){
          exist = false;
        }else{
          granteeList.remove(obj);
        }
      }
    }
    Iterator messageGranteeItr    = granteeList.iterator();
    HashMap routePersonMap        = getRoutePersons(context,BaseObject);
    java.util.Set sRoutePersonSet = routePersonMap.keySet() ;
    while(messageGranteeItr.hasNext())
{
    sGrantee = (String)messageGranteeItr.next();
    hashMap = new HashMap();
    hashMap.put("Name", sGrantee);
    if(sRoutePersonSet.contains(sGrantee))
    {
       com.matrixone.apps.common.Person PersonBean = com.matrixone.apps.common.Person.getPerson(context, sGrantee);
       String selRouteNodeRelId = "to["+PersonBean.RELATIONSHIP_ROUTE_NODE+"].id";
       SelectList selListType = new SelectList();
       selListType.add(PersonBean.SELECT_ID);
       selListType.add(PersonBean.SELECT_TYPE);
       selListType.add(PersonBean.SELECT_COMPANY_NAME);
       selListType.add(PersonBean.SELECT_COMPANY_ID);
       selListType.add(PersonBean.SELECT_FIRST_NAME);
       selListType.add(PersonBean.SELECT_LAST_NAME);
       selListType.add(PersonBean.SELECT_CURRENT);
       selListType.add(selRouteNodeRelId);
       Map personMap = PersonBean.getInfo(context, selListType);
       hashMap.put("Organization", personMap.get(PersonBean.SELECT_COMPANY_NAME));
       hashMap.put("OrganizationId", personMap.get(PersonBean.SELECT_COMPANY_ID));
       hashMap.put("ProjectMemberId", personMap.get(PersonBean.SELECT_ID));
       hashMap.put("PersonId", personMap.get(PersonBean.SELECT_ID));
       hashMap.put("Type", personMap.get(PersonBean.SELECT_TYPE));
       hashMap.put("sState", personMap.get(PersonBean.SELECT_CURRENT));
       hashMap.put("RouteNodeId", personMap.get(selRouteNodeRelId));
       hashMap.put("LastFirstName", personMap.get(PersonBean.SELECT_LAST_NAME) + ", " + personMap.get(PersonBean.SELECT_FIRST_NAME));

       //getting the Access mask for the grantee.
       try {
            access = BaseObject.getAccessForGranteeGrantor(context,sGrantee,accessUtil.ROUTE_ACCESS_GRANTOR);
       } catch (Exception e) {
       }
       if(access != null){
         sAccess = accessUtil.checkAccess(access);
       }
       hashMap.put("Access", sAccess);
     //}
     constructedList.add(hashMap);
     }
    }
    StringList selTypeStmts = new StringList();
    StringList selRelStmts = new StringList();
    selRelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
    selTypeStmts.add(DomainObject.SELECT_TYPE);

    MapList roleMapList = BaseObject.getAssignedRoles(context,selTypeStmts,selRelStmts,false);

    Vector vectRoles = new Vector();
    Iterator mapRoleItr = roleMapList.iterator();
    while(mapRoleItr.hasNext()){
      Map tempMap = (Map)mapRoleItr.next();
      String roleName = (String)tempMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
      if(roleName!=null && !"".equals(roleName) && !vectRoles.contains(roleName)){
        HashMap tempHashMap = new HashMap();
    //added for 311950
       //tempHashMap.put("Type",roleName.substring(0, roleName.indexOf("_")));
    if(roleName.startsWith("role"))
      {
      tempHashMap.put("Type","Role");
      }else
      {
      tempHashMap.put("Type","Group");
      }
   //till here
        tempHashMap.put("Access","Read");
        tempHashMap.put("LastFirstName",PropertyUtil.getSchemaProperty(context,roleName));
        tempHashMap.put("Organization", "");
        tempHashMap.put("OrganizationId", "");
        tempHashMap.put("ProjectMemberId", "");
        tempHashMap.put("sState", "");
        tempHashMap.put("PersonId", "");
        tempHashMap.put("RouteNodeId", "");

        constructedList.add(tempHashMap);
        vectRoles.addElement(roleName);
      }
    }

    MapList tempMapList = new MapList();
    Iterator tempMapItr = constructedList.iterator();
    while(tempMapItr.hasNext()) {
      Map sMap = (Map)tempMapItr.next();
      if(!"Inactive".equals((String)sMap.get("sState"))) {
        tempMapList.add(sMap);
      }
    }

    // pass the resultList to the following method
    emxPage.getTable().setObjects(tempMapList);
    // pass in the selectables to the following method
    emxPage.getTable().setSelects(new StringList());
}
constructedList  =  emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
dataCount  += constructedList.size();
%>

<script language="javascript" >
  function submitform() {
    document.summaryform.busIdArrayHidden.value =  parent.busIdArray.toString();
    document.summaryform.contentArrayHidden.value =  parent.contentArray.toString();
    startProgressBar();
    document.summaryform.submit();
  }
  function closeWindow() {
    window.closeWindow();
    return;
  }
  function collectContentData(selectedRow)
  {
    var  content = "";
    if(document.summaryform.elements["lead"+selectedRow]!=null)
    {
        content = content + "lead";
    }
    else
    {
        content = content + "null";
    }
    if(document.summaryform.elements["route"+selectedRow]!=null)
    {
        content = content +"~"+"route";
    }
    else
    {
        content = content + "~" +"null";
    }

    content = content + "~" + eval('document.summaryform.selAccess'+selectedRow+'.options[document.summaryform.selAccess'+selectedRow+'.selectedIndex].value');

    if(document.summaryform.elements["personName"+selectedRow]==null)
    {
        content  =  content + "~"+ "null";
    }
    else
    {
        content  =  content + "~"+ eval('document.summaryform.personName'+selectedRow+'.value');
    }
    if(document.summaryform.elements["isLead"+selectedRow]==null)
    {
        content  =  content +"~"+ "null";
    }
    else
    {
        content  =  content + "~"+    eval('document.summaryform.isLead'+selectedRow+'.value');
    }
    if(document.summaryform.elements["access"+selectedRow]==null)
    {
        content  =  content + "~"+ "null"
    }
    else
    {
        content  =  content + "~"+    eval('document.summaryform.access'+selectedRow+'.value');
    }
    var memberId  = eval('document.summaryform.memberId'+selectedRow+'.value');
    if(memberId =="")
    {
           memberId ="memberId"+selectedRow;
    }
    if(parent.busIdArray.length==0)
    {
        parent.busIdArray[0] = memberId;
        parent.contentArray[0]=content;
    }

    var k=0;

    for(var j=0;j<parent.busIdArray.length;j++)
    {
        if(parent.busIdArray[j]!=memberId)
        {
            memberFlag=false;
        }
        else
        {
            memberFlag=true;
            k=j;
            break;
        }

    }
    if(!memberFlag)
    {
        parent.busIdArray[parent.busIdArray.length] = memberId;
        parent.contentArray[parent.contentArray.length]=content;

    }
    else
    {
        parent.contentArray[k]=content;
    }

    document.summaryform.busIdArrayHidden.value =  parent.busIdArray.toString();
    document.summaryform.contentArrayHidden.value =  parent.contentArray.toString();


}


function dataPersistence()
{
    var arrayLength  = parent.busIdArray.length;
    var pageNumber   = "<%=emxPage.getCurrentPage()%>";
    //XSSOK
    var dataCount    = "<%=dataCount%>"-1;
    var initArray ="";
    initArray   = "0";
    var endArray    = parseInt(initArray)+parseInt(dataCount);
    var slead    =    "";
    var sroute    =    "";
    var sfolder    =    "";
    var sAccess =    "";
    var sRowIndentify ="";


    for(var i=initArray;i<=endArray;i++)
    {

        var arrayFlag  = "false";
        var memberId  = eval('document.summaryform.memberId'+i+'.value');
                if(memberId =="")
        {
           memberId ="memberId"+i;
        }
        for(var j=0;j<parent.busIdArray.length;j++)
        {
            if(memberId == parent.busIdArray[j])
            {
                arrayFlag = "true";
                content= parent.contentArray[j];
                content = new String(content);
                var contentArray  = new Array();
                contentArray      = content.split("~");
                for(var j=0;j<contentArray.length;j++)
                {
                   slead= contentArray[j];
                   sroute =     contentArray[j+1];
                   sfolder =     contentArray[j+2];
                   sAccess  = contentArray[j+3];
                   break;
                }


                if(sAccess!="null")
                {
                    var selBox    = eval("document.summaryform.selAccess" + i);
                    for(var k=0;k<eval('document.summaryform.selAccess' + i+'.length');k++)
                    {
                       if(eval('document.summaryform.selAccess'+i+'.options['+k+'].value')==sAccess)
                       {
                            var currentSel=eval('document.summaryform.selAccess'+i+'.options['+k+']');
                            currentSel.selected=true
                       }
                    }
                    selBox.selected =sAccess;
                }
            }

            if(arrayFlag=="true")
            {
                break;
            }
        }

    }

}

</script>

<body onLoad="dataPersistence()">

<form name="summaryform"  onSubmit="javascript:submitform(); return false" method="post" action="emxRouteTemplateEditAccessProcess.jsp">
  <input type="hidden" name="objectId"  value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

    <framework:sortInit
      defaultSortKey="LastFirstName"
      defaultSortType="string"
      mapList="<%=constructedList%>"
      resourceBundle="emxComponentsStringResource"
      ascendText="emxComponents.Common.SortAscending"
      descendText="emxComponents.Common.SortDescending"
      params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"  />
    <tr>

      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="LastFirstName"
          sortType="string"/>
      </th>

      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Type"
          sortKey="Type"
          sortType="string"/>
      </th>

      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Organization"
          sortKey="Organization"
          sortType="string"/>
      </th>
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Access"
          sortKey="Access"
          sortType="string"/>
      </th>
    </tr>
<%
  if(constructedList.size() > 0) {
%>
    <!-- \\XSSOK -->
    <framework:mapListItr mapList="<%=constructedList%>" mapName="mapAccess">
    <tr class='<framework:swap id ="1" />'>

<%

    sProjectMemberId      = (String)mapAccess.get("ProjectMemberId");
    sPersonName           = (String)mapAccess.get("Name");
   // sProjectLead          = (String)mapAccess.get("ProjectLead");
    //sCreateRoute          = (String)mapAccess.get("CreateRoute");
    //sCreateFolder         = (String)mapAccess.get("CreateFolder");
    sOrgName              = (String)mapAccess.get("Organization");
    sSpecificAccess       = (String)mapAccess.get("Access");
    sDisplayPersonName    = (String)mapAccess.get("LastFirstName");
    sType                 = (String)mapAccess.get("Type");
    if(DomainObject.TYPE_PERSON.equals(sType)){
%>
     <td class="object">
        <table>
                <tr>
                        <td>
                                <img src="../common/images/iconPerson16.png" border="0" id=""/>
                        </td>
                        <td>
                                <%=XSSUtil.encodeForHTML(context, sDisplayPersonName)%>
                        </td>
                </tr>
        </table>
       </td>
<%
    }else if(sType.equalsIgnoreCase("group") ){
%>
    <td class="object">
      <table>
                <tr>
                        <td>
                                <img src="../common/images/iconSmallGroup.gif" border="0" id=""/>
                        </td>
                        <td>
                                <%=XSSUtil.encodeForHTML(context, sDisplayPersonName)%>
                        </td>
                </tr>
        </table>
      </td>

<%  }
    else{
%>
      <td class="object">
      <table>
                <tr>
                        <td>
                                <img src="../common/images/iconRole.gif" border="0" id=""/>
                        </td>
                        <td>
                                <%=XSSUtil.encodeForHTML(context, sDisplayPersonName)%>
                        </td>
                </tr>
        </table>
      </td>
<%
    }
    if(!sType.equals("role") && !sType.equals("group")){
%>
      <td><%=XSSUtil.encodeForHTML(context, i18NUserType(request,sType))%>&nbsp;</td>
<%
    }else if(sType.equalsIgnoreCase("group") ){
%>
   <td><emxUtil:i18n localize="i18nId">emxComponents.Common.Group</emxUtil:i18n>&nbsp;</td>
<%
    }else{
%>
      <td><emxUtil:i18n localize="i18nId">emxComponents.Common.Role</emxUtil:i18n>&nbsp;</td>
<%
    }

%>
  <td><input type="hidden" name="orgName" value="<%=XSSUtil.encodeForHTMLAttribute(context, sOrgName)%>"/><%=XSSUtil.encodeForHTML(context, sOrgName)%>&nbsp;</td>
  <input type="hidden" name="<%="personName"+i%>" value="<xss:encodeForHTMLAttribute><%=sPersonName%></xss:encodeForHTMLAttribute>"/>

<%
    if(sSpecificAccess.equals("Read")){
        sReadSelected="selected";
      }else if(sSpecificAccess.equals("Read Write")){
        sReadWriteSelected="selected";
      }else if(sSpecificAccess.equals("Add")){
        sAddSelected="selected";
      }else if(sSpecificAccess.equals("Remove")){
        sRemoveSelected="selected";
      }else if(sSpecificAccess.equals("Add Remove")){
        sAddRemoveSelected="selected";
      }else{
        sNoneSelected="selected";
      }

%>	<!-- //XSSOK -->
    <input type="hidden" name="<%="access"+i%>" value="<%=sSpecificAccess%>" />
    <input type="hidden" name="<%="memberId"+i%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,sProjectMemberId)%>" />
    <td>
<%
  //modified for 311950
//if((sType!=null && !sType.equals("role") && !sType.equals("group")) && !sPersonName.equals(sOwner)){
    if((sType!=null) && !sType.equals("Role") && !sType.equals("Group") && !sPersonName.equals(sOwner) ) {
//till here

%>
    <select name="<%="selAccess"+i%>" onChange="javascript:collectContentData('<%=i%>');" >
      <!-- //XSSOK -->
      <option value="Read" <%=sReadSelected%>><emxUtil:i18n localize="i18nId">emxComponents.Access.Read</emxUtil:i18n></option>
      <!-- //XSSOK -->
      <option value="Read Write" <%=sReadWriteSelected%>><emxUtil:i18n localize="i18nId">emxComponents.Access.ReadWrite</emxUtil:i18n></option>
      <!-- //XSSOK -->
      <option value="Add" <%=sAddSelected%>><emxUtil:i18n localize="i18nId">emxComponents.Access.Add</emxUtil:i18n></option>
      <!-- //XSSOK -->
      <option value="Remove" <%=sRemoveSelected%>><emxUtil:i18n localize="i18nId">emxComponents.Access.Remove</emxUtil:i18n></option>
      <!-- //XSSOK -->
      <option value="Add Remove" <%=sAddRemoveSelected%>><emxUtil:i18n localize="i18nId">emxComponents.Access.AddRemove</emxUtil:i18n></option>
    </select>
<%
    }else{
         if(sSpecificAccess.equals("Read")){
 %>
        <emxUtil:i18n localize="i18nId">emxComponents.Access.Read</emxUtil:i18n>
<%     }else if(sSpecificAccess.equals("Read Write")){ %>
        <emxUtil:i18n localize="i18nId">emxComponents.Access.ReadWrite</emxUtil:i18n>
<%       }else if(sSpecificAccess.equals("Add")){ %>
        <emxUtil:i18n localize="i18nId">emxComponents.Access.Add</emxUtil:i18n>
<%      }else if(sSpecificAccess.equals("Remove")){ %>
        <emxUtil:i18n localize="i18nId">emxComponents.Access.Remove</emxUtil:i18n>
<%      }else if(sSpecificAccess.equals("Add Remove")){ %>
        <emxUtil:i18n localize="i18nId">emxComponents.Access.AddRemove</emxUtil:i18n>
<%      }else{ %>
        <emxUtil:i18n localize="i18nId">emxComponents.Access.None</emxUtil:i18n>
<%      }
      }
%>
   </td>
  </tr>
<%
   i++;
   sReadSelected          = "";
   sAddSelected           = "";
   sRemoveSelected        = "";
   sAddRemoveSelected     = "";
   sNoneSelected          = "";
   //Bug No 311610 - Start
   sReadWriteSelected     = "";
   //Bug No 311610 - End
%>
  </framework:mapListItr>
<%
  } else {
%>
    <tr><td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.Access.NoAccess</emxUtil:i18n></td></tr>
<%
  }
%>
  </table>
  <input type="hidden" name="type" value="<xss:encodeForHTMLAttribute><%=sTypeName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="count" value="<%=i%>" />
   <input type="hidden" name="busIdArrayHidden" value="" />
  <input type="hidden" name="contentArrayHidden" value="" />
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
