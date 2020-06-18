<%--
   emxRouteSelectProjectMembers.jsp

   Copyright (c) 1998-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxRouteSelectProjectMembers.jsp.rca 1.13 Wed Oct 22 16:18:43 2008 przemek Experimental przemek $
--%>

<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="JavaScript" src="emxRouteSimpleFunctions.js" type="text/javascript"></script>

 <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  com.matrixone.apps.common.Person person =
      (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
      DomainConstants.TYPE_PERSON);

boolean isProgramInstalled = false;
  Class clsProjectSpace=null;
try{
        clsProjectSpace = Class.forName("com.matrixone.apps.program.ProjectSpace");
        isProgramInstalled = true;
}catch (Exception ex){}


  String showSel = emxGetParameter(request, "mx.page.filter");
  String hasTarget  = emxGetParameter(request, "hasTarget");
  String selectMultiple = emxGetParameter(request,"selectMultiple");
  String projectId   = emxGetParameter(request,"projectId");
  String routeId   = emxGetParameter(request,"routeId");
  String memberType   = emxGetParameter(request,"memberType");
  String keyValue = emxGetParameter(request, "keyValue");
  String flag              = emxGetParameter(request,"flag");
  String chkSubscribeEvent = emxGetParameter(request,"chkSubscribeEvent");
   /*Quick Route Creation */
   String fromPage=emxGetParameter(request,"fromPage");
   /*Quick Route Creation */

  String checkType = "radio";

  MapList queryResultList = new MapList();

  String sUserName     = "*";
  String sLastName     = "*";
  String sFirstName    = "*";

 if (emxPage.isNewQuery()) {

// Build the where clause from the attributes in the request and run the query.
    StringList busSelects = new StringList (5);
    busSelects.add(person.SELECT_ID);
    busSelects.add(person.SELECT_NAME);
    busSelects.add(person.SELECT_FIRST_NAME);
    busSelects.add(person.SELECT_LAST_NAME);
    busSelects.add(person.SELECT_COMPANY_NAME);


    // The following section is building the busWhere clause.  This is necessary
    // because the company.getPersons will not accept a *.
    String busWhere = null;
    if (sUserName != null && !sUserName.equals(null) && !sUserName.equals("null") &&
        !sUserName.equals("*") && !sUserName.equals("")){
      busWhere = "\"" + person.SELECT_NAME + "\" ~~ \"" + sUserName + "\"";
    }

    if ((sFirstName != null) && !sFirstName.equals(null) && !sFirstName.equals("null") &&
      !sFirstName.equals("*") && !sFirstName.equals(""))
    {
      if (busWhere != null){
        busWhere += " && \"" + person.SELECT_FIRST_NAME + "\" ~~ \"" + sFirstName + "\"";
      }
      else {
        busWhere = "\"" + person.SELECT_FIRST_NAME + "\" ~~ \"" + sFirstName + "\"";
      }
    }

    if ((sLastName != null) && !sLastName.equals(null) && !sLastName.equals("null") &&
      !sLastName.equals("*") && !sLastName.equals(""))
    {
      if (busWhere != null){
        busWhere += " && \"" + person.SELECT_LAST_NAME + "\" ~~ \"" + sLastName + "\"";
      }
      else {
        busWhere = "\"" + person.SELECT_LAST_NAME + "\" ~~ \"" + sLastName + "\"";
      }
    }

    if(projectId != null && !projectId.equals("null") && !projectId.equals("")) {
      //project.setId(projectId);
        Object objProject = null;
        if(isProgramInstalled){
                Method setId=null;
                objProject = clsProjectSpace.newInstance();
                Class[] clsArg = new Class[1];
                clsArg[0]  = String.class;
                setId = clsProjectSpace.getMethod("setId",clsArg);
                setId.invoke(objProject,new Object[] {projectId});
        }
        StringList relSelects = new StringList(2);
        if(isProgramInstalled){
                Method getMembers=null;
                Class[] clsArg = new Class[5];
                clsArg[0]  = Context.class;
                clsArg[1]  = StringList.class;
                clsArg[2]  = StringList.class;
                clsArg[3]  = String.class;
                clsArg[4]  = String.class;
                getMembers = clsProjectSpace.getMethod("getMembers",clsArg);

                Object[] arguments = new Object[5];
                arguments[0]=context;
                arguments[1]=busSelects;
                arguments[2]=relSelects;
                arguments[3]=busWhere;
                arguments[4]=null;
                queryResultList = (MapList)getMembers.invoke(objProject,arguments);
        }
      //queryResultList = project.getMembers(context, busSelects, relSelects, busWhere, null);
    }

emxPage.getTable().setObjects(queryResultList);
emxPage.getTable().setSelects(new SelectList());
}

// this Maplist is the one which is used to make the table.
  queryResultList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

StringList  routeMemList = new StringList();
if(routeId==null || routeId.equals("null") ||  routeId.equals("") || null == routeId)
{
  MapList memberMapList = null;
   try{
  	  memberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
   }catch(Exception mml){
      memberMapList = new MapList();
   }

if(memberMapList == null)
{
      memberMapList = new MapList();
}


routeMemList = new StringList();
if(memberMapList != null && memberMapList.size() >0) {
              Iterator mapMemberItr = memberMapList.iterator();
              while(mapMemberItr.hasNext()) {
                  Map mapMember     = (Map)mapMemberItr.next();
                  String smemberID  = (String)mapMember.get(DomainObject.SELECT_ID);
                   routeMemList.add(smemberID);
}
 }
}

//for Push subscription
 StringList personEventList = new StringList();

  if(flag!=null && "pushSubscription".equals(flag)){
  String eventType              = PropertyUtil.getSchemaProperty(context, "attribute_EventType");
  String type_Event             = PropertyUtil.getSchemaProperty(context, "type_Event");
  String type_Pub_Subscribe     = PropertyUtil.getSchemaProperty(context, "type_PublishSubscribe");
  String eventId  = "";
  MapList eventList = new MapList();


    DomainObject routeObject     = DomainObject.newInstance(context , routeId );//, DomainConstants.TEAM);
    String routeOwner     = routeObject.getInfo(context,DomainObject.SELECT_OWNER);


      Iterator mapItr2 = queryResultList.iterator();
      while(mapItr2.hasNext()){
        Map tempMap = (Map)mapItr2.next();
        if(routeOwner.equals((String)tempMap.get(DomainObject.SELECT_NAME))){
          mapItr2.remove();
          break;
        }
      }
    Pattern typePattern1 = new Pattern(type_Event);
    typePattern1.addPattern(type_Pub_Subscribe);

    Pattern relPattern1 = new Pattern(DomainObject.RELATIONSHIP_PUBLISH);
    relPattern1.addPattern(DomainObject.RELATIONSHIP_PUBLISH_SUBSCRIBE);

    StringList objectSelects = new StringList();

    objectSelects.add(DomainObject.SELECT_ID);
    objectSelects.add("attribute["+eventType+"]");

    eventList = routeObject.getRelatedObjects(context,
                                                  relPattern1.getPattern(),
                                                  typePattern1.getPattern(),
                                                  objectSelects,
                                                  null,
                                                  true,
                                                  true,
                                                  (short)2,
                                                  "",
                                                  "",
                                                  null,
                                                  new Pattern(DomainObject.RELATIONSHIP_PUBLISH),
                                                  null);

    Iterator mapItr1 = eventList.iterator();
    while(mapItr1.hasNext()){
      Map map = (Map)mapItr1.next();
      if(((String)map.get("attribute["+eventType+"]")).equals(chkSubscribeEvent)){
        eventId = (String)map.get(DomainObject.SELECT_ID);
        break;
      }
    }

    if(eventId !=null && !"".equals(eventId)){
      DomainObject eventObj = DomainObject.newInstance(context, eventId);
      personEventList = eventObj.getInfoList(context, "from["+DomainObject.RELATIONSHIP_PUSHED_SUBSCRIPTION+"].to.id");


      if(personEventList == null){
        personEventList = new StringList();
      }
    }
  }
%>

<html>
  <head>
    <title>
      <emxUtil:i18n localize="i18nId">emxComponents.Common.Search</emxUtil:i18n>
    </title>
  </head>
  <body class="white">
  <%@include file = "emxMQLNotice.inc" %>
    <form name="PersonSummary" onSubmit="javascript:pageSubmition(); return false" method = "post" >
    <input type="hidden" name="flag" value="<xss:encodeForHTMLAttribute><%=flag%></xss:encodeForHTMLAttribute>" > <!--16 dec-->
    <input type="hidden" name="chkSubscribeEvent" value="<xss:encodeForHTMLAttribute><%=chkSubscribeEvent%></xss:encodeForHTMLAttribute>" >

        <framework:sortInit defaultSortKey="person.SELECT_NAME" defaultSortType="string"
          mapList="<%= queryResultList %>"
          resourceBundle="emxComponentsStringResource"
          ascendText="emxComponents.Common.SortAscending"
          descendText="emxComponents.Common.SortDescending"/>
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

        <tr>
<%
      if(!"false".equalsIgnoreCase(selectMultiple)) {
        checkType = "checkbox";
%>
          <framework:ifExpr expr='<%= "true".equalsIgnoreCase(hasTarget) %>'>
        <th width="2%" style="text-align: center;">
        <span style="text-align: center;">
          <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()">
        </span>
		</th>

          </framework:ifExpr>
<%
      }else{
%>
        <th nowrap="nowrap">&nbsp;</th>
<%
      }
%>
          <th nowrap="nowrap">
            <framework:sortColumnHeader title="emxComponents.Common.Name"
              sortKey="<%= person.SELECT_NAME %>"
              sortType="string"/>
          </th>

          <th nowrap="nowrap">
                  <framework:sortColumnHeader
                    title="emxComponents.Common.Organization"
                    sortKey="<%= person.SELECT_COMPANY_NAME %>"
                    sortType="string"/>
           </th>

        </tr>

        <framework:ifExpr expr="<%= queryResultList.size() < 1 %>">
          <table border="0" width="100%">
            <tr>
              <td align="center" colspan="13" class="error">
                <emxUtil:i18n localize="i18nId">emxComponents.MemberSearch.NoMembers</emxUtil:i18n>
               </td>
            </tr>
          </table>
        </framework:ifExpr>

        <framework:mapListItr mapList="<%= queryResultList %>" mapName="personMap">
          <%
            // Person basic info URL
            String personName = (String) personMap.get(person.SELECT_NAME);
            String personId = (String) personMap.get(person.SELECT_ID);
            String treeUrl = UINavigatorUtil.getCommonDirectory(application) + "/emxTree.jsp?AppendParameters=true&objectId=" + personId;

    		    String relRouteNode           = DomainObject.RELATIONSHIP_ROUTE_NODE;
		      	com.matrixone.apps.common.Person personObject = new com.matrixone.apps.common.Person(personId);
      			StringList routeIdList        = personObject.getInfoList(context,"to["+relRouteNode+"].from.id");

			      if(routeIdList == null){
		              routeIdList                 = new StringList();
    	      }

            boolean personInEvent = false;
            if(personEventList.contains(personId)){
                personInEvent = true;
            }
%>
          <tr class='<framework:swap id="1"/>'>
<%
if(flag != null && "pushSubscription".equals(flag) )
 {
    if(personInEvent)
  {
     %>
        <td style="text-align:center">
          <img border="0" src="../common/images/utilCheckOffDisabled.gif" align="center">
        </td>
<%
  }else{
      %>
              <td width="5%"><input type="checkbox" name="selectedPerson" value="<%=(String) personMap.get("id")%>"  onClick="updateCheck()" alt="<%=personName%>"></td>
<%}
 }
else if(routeMemList.contains(personId) || routeIdList.contains(routeId)) {
%>
           <td align="center">
              <img border="0" src="../common/images/utilCheckOffDisabled.gif" align="center">
           </td>
<%
           }else{
%>

            <framework:ifExpr expr='<%= "true".equalsIgnoreCase(hasTarget) %>'>
              <td>
               <input type="checkbox" name="selectedPerson" id="selectedPerson" value="<%=personId%>" onclick="updateCheck()" alt="<%=personName%>">
              </td>
            </framework:ifExpr>
<%
				}
%>
            <td>
              <a href="javascript:showDetailsPopup('<%=treeUrl%>')">
                <img src="../common/images/iconSmallPerson.gif" border="0">
                <%=personName%>
              </a>
            </td>
            <td>
              <%=personMap.get(person.SELECT_COMPANY_NAME)%>
            </td>
          </tr>
        </framework:mapListItr>
      </table> 
     </form>

    <%@include file = "../emxUICommonEndOfPageInclude.inc" %>

    <script language = "javascript">

      function checkAll(allbox, chkprefix) {
         form = allbox.form;
         max = form.elements.length;
         for (var i=0; i<max; i++) {
            fieldname = form.elements[i].name;
            if (fieldname.substring(0,chkprefix.length) == chkprefix) {
               form.elements[i].checked = allbox.checked;
            }
         }
      }


      function pageSubmition() {
        var flag = false;
        for (var i = 0 ; i < document.PersonSummary.elements.length ; i++) {
          if (document.PersonSummary.elements[i].type == "<%=checkType%>" &&
              document.PersonSummary.elements[i].checked ) {
            flag = true;
            break;
          }
        }
    if (flag == true) {
        
        /* Quick Route Creation Start */
        if("QuickRoute"=="<%=XSSUtil.encodeForJavaScript(context,fromPage)%>")
        {
                var memberString="";
                for (var i = 0 ; i < document.PersonSummary.elements.length ; i++) 
                {
                              if (document.PersonSummary.elements[i].type == "<%=checkType%>" && document.PersonSummary.elements[i].checked  && document.PersonSummary.elements[i].name=="selectedPerson" ) 
                              {
                                    memberString=memberString+document.PersonSummary.elements[i].alt+"|"+document.PersonSummary.elements[i].value+";";
                              }
                }
                populateQuickRouteMemberList("PERSON",memberString);
                window.closeWindow();
                return;
        }
        /* Quick Route Creation End */
    <%
    if(flag!=null && !flag.equals("") && !flag.equals("null") && !"null".equals(flag) ) {
    %>
      document.PersonSummary.action = "emxRouteSubscribeWorkspaceOptions.jsp?objectId=<%=routeId%>";
      startProgressBar(true);
      document.PersonSummary.submit();
      return;
       <%
        }else{
     %>	                 document.PersonSummary.action="emxRouteSelectProjectMembersProcess.jsp?projectId=<%=XSSUtil.encodeForURL(context,projectId)%>&hasTarget=true&multiSelect=true&memberType=<%=XSSUtil.encodeForURL(context,memberType)%>&routeId=<%=XSSUtil.encodeForURL(context,routeId)%>&keyValue=<%=XSSUtil.encodeForURL(context,keyValue)%>memberType=Person";
     startProgressBar();
     document.PersonSummary.submit();
     return ;
      <%
        }
      %>
      }
        else {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PeopleSummary.SelectOneMember</emxUtil:i18nScript>");
          return;
        }
      }


	  function updateCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    chkList.checked = false;
  }

  function doCheck(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('selectedPerson') > -1){
        objForm.elements[i].checked = chkList.checked;
      }
  }
    </script>

  </body>
</html>
