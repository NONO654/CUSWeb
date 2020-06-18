<%-- emxRouteWizardSearchTemplateResults.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWizardSearchTemplateResults.jsp.rca 1.15 Wed Oct 22 16:18:30 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<script language="javascript">

var templateName = null;
var templateId = null;

function submitform() {

        var checkedFlag = "false";
        var radioFlag = "false";
        var remaining="";
        // force to select atleast one member to remove

        for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
                if (document.templateresults.elements[varj].type == "radio") {
                        radioFlag = "true";
                        if (document.templateresults.elements[varj].checked ){
                                checkedFlag = "true";
                                var selected = document.templateresults.elements[varj].value;
                                var index = selected.indexOf('@');
                                var lastindex = selected.lastIndexOf('@');
                                parent.window.getWindowOpener().parent.frames[1].document.forms[0].template.value=selected.substring(0,index);
                                parent.window.getWindowOpener().parent.frames[1].document.forms[0].templateId.value=selected.substring(index+1,lastindex);
                                remaining = selected.substring(lastindex+1,selected.length);
                                index = remaining.indexOf('#');
                                lastindex=remaining.lastIndexOf('#');
                                parent.window.getWindowOpener().parent.frames[1].document.forms[0].txtdescription.value=remaining.substring(0,index);
                                parent.window.getWindowOpener().parent.frames[1].document.forms[0].routeBasePurpose.value=remaining.substring(index+1,lastindex);
                                var scope = remaining.substring(lastindex+1, remaining.length);
                                parent.window.getWindowOpener().setScope(scope);
                                break;
                        }
                }
        }


        if ((checkedFlag == "false") && (radioFlag == "true")) {
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.SearchTemplate.SelectOne</emxUtil:i18nScript>");
                return;
        } else {
                window.closeWindow();
        }

}

function closeWindow() {
        window.closeWindow();
        return;
}
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

String supplierOrgId  = emxGetParameter(request,"supplierOrgId");

//Prepare the proper contentUrl with all the required parameters

boolean isFromSupplierRoute = false;

if(supplierOrgId != null && !"null".equals(supplierOrgId) && supplierOrgId.trim().length() > 0)
{

        isFromSupplierRoute = true;
}
String sStateActive          = PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ROUTE_TEMPLATE, "state_Active");

StringList supplierOrgIdList = new StringList(1);
supplierOrgIdList.add(supplierOrgId);


String sNamePattern = emxGetParameter(request,"txtName");

String sScope = emxGetParameter(request,"selScope");

String WorkspaceId = emxGetParameter(request,"objectId");


//Preload LookUp Strings
String typeRouteTemplate = PropertyUtil.getSchemaProperty(context,"type_RouteTemplate");
String relRouteTemplates = PropertyUtil.getSchemaProperty(context,"relationship_RouteTemplates");

String sUser = "User";
String sEnterprise = "Enterprise";
String sAll = "*";
String sWorkspace  = "Workspace";
String sProjectspace  = "Projectspace";

BusinessObject boPersonObj = JSPUtil.getPerson(context, session);
BusinessObject boPerson = null;

boolean isTemplate = false;

// build Relationship and Type patterns
Pattern relPattern = new Pattern(relRouteTemplates);
Pattern typePattern = new Pattern(typeRouteTemplate);

// build select params
SelectList selectStmts = new SelectList();
selectStmts.addName();
selectStmts.addDescription();
selectStmts.addRevision();
selectStmts.addOwner();
selectStmts.addId();
selectStmts.addCurrentState();
selectStmts.addAttribute(DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE);
selectStmts.addAttribute(DomainObject.ATTRIBUTE_RESTRICT_MEMBERS);

// build select params for Relationship
SelectList selectRelStmts = new SelectList();

String classname = "odd";
BusinessObject objTemplate = null;
Pattern pattern = null;
if(sNamePattern != null) {
        pattern = new Pattern(sNamePattern);
} else {
        sNamePattern = sAll;
        sScope = sAll;
        pattern = new Pattern(sAll);
}

%>

<form name="templateresults" id="templateresults" method="post" onSubmit="return false">


 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

        <tr>
                <th width="5%" style="text-align:center">&nbsp;</th>
                <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></th>
                <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n></th>
                <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></th>
        </tr>
<%
        //select member company ids
        String SELECT_MEMBER_COMPANY_ID = "from[" + DomainObject.RELATIONSHIP_ROUTE_NODE + "].to.to[" + DomainObject.RELATIONSHIP_EMPLOYEE + "].from.id";
        selectStmts.add(SELECT_MEMBER_COMPANY_ID);

        if ((sAll.equals(sScope)) || (sEnterprise.equals(sScope)))
        {

                BusinessObject boOrg = JSPUtil.getOrganization(context, session,boPersonObj);
                if(boOrg != null)
                {
                        boOrg.open(context);
                    //    ExpansionWithSelect templateSelect = boOrg.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                      //                       selectStmts,selectRelStmts,false, true, (short)1);
                          ExpansionWithSelect templateSelect =  boOrg.expandSelect(context, relPattern.getPattern(),typePattern.getPattern(),
                         selectStmts,selectRelStmts,false, true, (short)1,
                         "(revision ~~ last) && (current ==" + sStateActive +")", null);
                        RelationshipWithSelectItr relTemplateItr = new RelationshipWithSelectItr(templateSelect.getRelationships());
                        
                        while (relTemplateItr != null && relTemplateItr.next())
                        {
                                objTemplate = relTemplateItr.obj().getTo();
                                Hashtable templateHash = relTemplateItr.obj().getTargetData();
                                String strRevision = (String)templateHash.get("revision");
                                String templateId = (String)templateHash.get("id");
                                String templateName = (String)templateHash.get("name");
                                String templateDesc = (String)templateHash.get("description");
                                String templateState = (String)templateHash.get("current");
                                String basePurpose = (String)templateHash.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
                                String restrictmembers=(String)templateHash.get("attribute["+DomainObject.ATTRIBUTE_RESTRICT_MEMBERS+"]");

                                String memberCompanyId = "";
                                StringList memberCompanyIds = new StringList();
                                try
                                {
                                        memberCompanyId = (String)templateHash.get(SELECT_MEMBER_COMPANY_ID);
                                        memberCompanyIds.add(memberCompanyId);
                                }catch(Exception e){
                                        memberCompanyIds = (StringList)templateHash.get(SELECT_MEMBER_COMPANY_ID);
                                }
                                if (pattern.match((String) templateName) && templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE))
                                {
                                        memberCompanyIds.removeAll(supplierOrgIdList);
                                        boolean templateHasOnlySupplierPerson = (memberCompanyIds.size() > 0)?false:true;
                                        if(!isFromSupplierRoute || (isFromSupplierRoute && templateHasOnlySupplierPerson))
                                        {
                                                isTemplate = true;
%><!-- //XSSOK -->
                                                <tr class="<%=classname%>">
                                                        <td><input type="radio" name ="radList" id="radList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, templateName)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateId)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateDesc)%>#<%=XSSUtil.encodeForHTMLAttribute(context, basePurpose)%>#<%=XSSUtil.encodeForHTMLAttribute(context, restrictmembers)%>" /></td>
                                                        <td><%=XSSUtil.encodeForHTML(context, templateName)%>&nbsp;</td>
                                                        <td><%=XSSUtil.encodeForHTML(context, strRevision)%>&nbsp;</td>
                                                        <td><%=XSSUtil.encodeForHTML(context, templateDesc)%>&nbsp;</td>
                                                </tr>
<%
                                                if(classname == "odd") {
                                                        classname = "even";
                                                }else
                                                {
                                                        classname = "odd";
                                                }
                                        }
                                }
                        }
                        boOrg.close(context);
                }
        }

    // To retrieve templates Owned by Current User
        Collection obPersonIds = null;
        Iterator personItr  = null;
        if ((sAll.equals(sScope)) || (sUser.equals(sScope)))
        {

                HashMap personHash = new HashMap();
                personHash.put("",boPersonObj.getObjectId());
                obPersonIds = personHash.values();

                personItr = obPersonIds.iterator();
                while(personItr.hasNext())
                {
                        boPerson = new BusinessObject((String)personItr.next());
                        boPerson.open(context);
                        ExpansionWithSelect templateSelect = boPerson.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                       selectStmts,selectRelStmts,false, true, (short)1);
                        RelationshipWithSelectItr relTemplateItr = new RelationshipWithSelectItr(templateSelect.getRelationships());
                        while (relTemplateItr != null && relTemplateItr.next())
                        {
                                objTemplate = relTemplateItr.obj().getTo();
                                Hashtable templateUserHash = relTemplateItr.obj().getTargetData();

                                String strRevision = (String)templateUserHash.get("revision");
                                String strOwner = (String)templateUserHash.get("owner");
                                String templateId = (String)templateUserHash.get("id");
                                String templateName = (String)templateUserHash.get("name");
                                String templateDesc = (String)templateUserHash.get("description");
                                String templateState = (String)templateUserHash.get("current");
                                String basePurpose=(String)templateUserHash.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
                                String restrictmembers=(String)templateUserHash.get("attribute["+DomainObject.ATTRIBUTE_RESTRICT_MEMBERS+"]");

                                String memberCompanyId = "";
                                StringList memberCompanyIds = new StringList();
                                try
                                {
                                        memberCompanyId = (String)templateUserHash.get(SELECT_MEMBER_COMPANY_ID);
                                        memberCompanyIds.add(memberCompanyId);
                                }catch(Exception e){
                                        memberCompanyIds = (StringList)templateUserHash.get(SELECT_MEMBER_COMPANY_ID);
                                }

                                if ((pattern.match((String) templateName)) && (strOwner.equals(context.getUser())) && templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE))
                                {
                                        memberCompanyIds.removeAll(supplierOrgIdList);
                                        boolean templateHasOnlySupplierPerson = (memberCompanyIds.size() > 0)?false:true;
                                        if(!isFromSupplierRoute || (isFromSupplierRoute && templateHasOnlySupplierPerson))
                                        {
                                                isTemplate = true;
%><!-- //XSSOK -->
                                                <tr class="<%=classname%>">
                                                        <td><input type="radio" name ="radList" id="radList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, templateName)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateId)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateDesc)%>#<%=XSSUtil.encodeForHTMLAttribute(context, basePurpose)%>#<%=XSSUtil.encodeForHTMLAttribute(context, restrictmembers)%>" /></td>
                                                        <td><%=XSSUtil.encodeForHTML(context, templateName)%>&nbsp;</td>
                                                        <td><%=XSSUtil.encodeForHTML(context, strRevision)%>&nbsp;</td>
                                                        <td><%=XSSUtil.encodeForHTML(context, templateDesc)%>&nbsp;</td>
                                                </tr>
<%
                                                if(classname == "odd")
                                                {
                                                        classname = "even";
                                                }
                                                else
                                                {
                                                        classname = "odd";
                                                }
                                        }
                                }
                        }
                        boPerson.close(context);
                }
        }

   // To retrieve templates attached to the Workspace
   //to fix bug# 280873 - start
        if ((sAll.equals(sScope)) || (sWorkspace.equals(sScope)))
        {
                
                com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
                String spersonName = com.matrixone.apps.common.Person.getDisplayName(context, person.getName());

                //get the vaults of the Person's company
                DomainObject domainPerson = DomainObject.newInstance(context,person);
                String personVault = person.getVaultName(context);
                String objectId = emxGetParameter(request,"objectId");
                String expandTypeWhere  = "";
                String queryTypeWhere   = "";
                queryTypeWhere = "('" + DomainObject.SELECT_CURRENT + "' == 'Active')";
                expandTypeWhere = "('" + DomainObject.SELECT_CURRENT + "' == 'Active')";
                //query selects
                StringList objectSelects = new StringList();
                objectSelects.add(DomainObject.SELECT_ID);
                //have to include SELECT_TYPE as a select since the expand has includeTypePattern
                objectSelects.add(DomainObject.SELECT_TYPE);
                //build type and rel patterns
                typePattern = new Pattern(DomainConstants.TYPE_PROJECT_MEMBER);
                typePattern.addPattern(DomainConstants.TYPE_PROJECT);
                relPattern = new Pattern(DomainConstants.RELATIONSHIP_PROJECT_MEMBERSHIP);
                relPattern.addPattern(DomainConstants.RELATIONSHIP_PROJECT_MEMBERS);
                // type and rel patterns to include in the final resultset
                Pattern includeTypePattern = new Pattern(DomainConstants.TYPE_PROJECT);
                Pattern includeRelPattern = new Pattern(DomainConstants.RELATIONSHIP_PROJECT_MEMBERS);

                // get all workspaces that the user is a Project-Member
                MapList workspaceList = person.getRelatedObjects(context,
                                        relPattern.getPattern(),  //String relPattern
                                        typePattern.getPattern(), //String typePattern
                                        objectSelects,            //StringList objectSelects,
                                        null,                     //StringList relationshipSelects,
                                        true,                     //boolean getTo,
                                        true,                     //boolean getFrom,
                                        (short)2,                 //short recurseToLevel,
                                        expandTypeWhere,          //String objectWhere,
                                        "",                       //String relationshipWhere,
                                        includeTypePattern,       //Pattern includeType,
                                        includeRelPattern,        //Pattern includeRelationship,
                                        null);                    //Map includeMap


                // get all workspaces that the current user is a member since one of his roles is a member
                MapList roleWorkspaceList = DomainObject.querySelect(context,
                                      DomainConstants.TYPE_PROJECT,                // type pattern
                                      DomainObject.QUERY_WILDCARD, // namePattern
                                      DomainObject.QUERY_WILDCARD, // revPattern
                                      DomainObject.QUERY_WILDCARD, // ownerPattern
                                      personVault,                 // get the Person Company vault
                                      queryTypeWhere,              // where expression
                                      true,                        // expandType
                                      objectSelects,               // object selects
                                      null,                        // cached list
                                      true);                       // use cache

                Iterator workspaceListItr = workspaceList.iterator();
                Iterator roleWorkspaceListItr = roleWorkspaceList.iterator();

                // get a list of workspace id's for the member
                StringList workspaceIdList = new StringList();
                while(workspaceListItr.hasNext())
                {
                        Map workspaceMap = (Map)workspaceListItr.next();
                        String workspaceId = (String)workspaceMap.get(DomainObject.SELECT_ID);
                        workspaceMap.remove("relationship");
                        workspaceMap.remove("level");
                        workspaceIdList.addElement(workspaceId);
                }

                while(roleWorkspaceListItr.hasNext())
                {
                        Map workspaceMap = (Map)roleWorkspaceListItr.next();
                        String workspaceId = (String)workspaceMap.get(DomainObject.SELECT_ID);
                        if(!workspaceIdList.contains(workspaceId))
                        {
                                workspaceIdList.addElement(workspaceId);
                                workspaceList.add(workspaceMap);
                        }
                }

                workspaceListItr = workspaceList.iterator();

                StringList tempIdList = new StringList();
                while(workspaceListItr.hasNext())
                {
                        Map workspaceMap = (Map)workspaceListItr.next();
                        String workspaceId = (String)workspaceMap.get(DomainObject.SELECT_ID);
                        tempIdList.addElement(workspaceId);
                }

                MapList workspaceMapList =  new MapList();

                //build object-select statements
                StringList selectTypeStmts = new StringList();
                selectTypeStmts.add(DomainObject.SELECT_TYPE);
                selectTypeStmts.add(DomainObject.SELECT_NAME);
                selectTypeStmts.add(DomainObject.SELECT_ID);

                if(tempIdList.size() > 0)
                {
                        //get the details of the workspace objects
                        workspaceMapList = DomainObject.getInfo(context, (String [])tempIdList.toArray(new String []{}), selectTypeStmts);
                }
 
                if(workspaceMapList.size() > 0)
                {
                        Iterator workspaceIdsItr = workspaceMapList.iterator();
                        while(workspaceIdsItr.hasNext())
                        { 
                                Map workspaceIDMap = (Map)workspaceIdsItr.next();
                                WorkspaceId = (String)workspaceIDMap.get(DomainObject.SELECT_ID);
                                //to fix bug# 280873 - end
                                DomainObject domObject = DomainObject.newInstance(context);
                                domObject.setId(WorkspaceId);
                                domObject.open(context);

                                if((domObject.TYPE_WORKSPACE_VAULT).equals(domObject.getTypeName())){
                                        WorkspaceId = domObject.getInfo(context,"to["+domObject.RELATIONSHIP_WORKSPACE_VAULTS+"].from.id");
                                        domObject.setId(WorkspaceId);
                                }


                                MapList workspaceTemplateList = getTemplateList(context,domObject,sNamePattern);
                                // templateList.addAll(workspaceTemplateList);

                                Iterator workspaceTemplateListItr = workspaceTemplateList.iterator();

                                // get a list of workspace id's for the member
                                while(workspaceTemplateListItr.hasNext())
                                {
                                        Map workspaceMap = (Map)workspaceTemplateListItr.next();
                                        String strRevision = (String)workspaceMap.get("revision");
                                        String strOwner = (String)workspaceMap.get("owner");
                                        String templateId = (String)workspaceMap.get("id");
                                        String templateName = (String)workspaceMap.get("name");
                                        String templateDesc = (String)workspaceMap.get("description");
                                        String templateState = (String)workspaceMap.get("current");

%><!-- //XSSOK -->
                                        <tr class="<%=classname%>">
                                                <td><input type="radio" name ="radList" id="radList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, templateName)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateId)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateDesc)%>" /></td>
                                                <td><%=XSSUtil.encodeForHTML(context, templateName)%>&nbsp;</td>
                                                <td><%=XSSUtil.encodeForHTML(context, strRevision)%>&nbsp;</td>
                                                <td><%=XSSUtil.encodeForHTML(context, templateDesc)%>&nbsp;</td>
                                        </tr>
<%
                                        if(classname == "odd")
                                        {
                                                classname = "even";
                                        }else
                                        {
                                                classname = "odd";
                                        }
                                }
                                if(workspaceTemplateList.size()>0)
                                {
                                        isTemplate = true;
                                }
                        }
                }
        }//Workspace
        // To retrieve templates attached to the Projectspace
        //to fix bug# 282270 - start
        if ((sAll.equals(sScope)) || (sProjectspace.equals(sScope)))
        {

                com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
                String spersonName = com.matrixone.apps.common.Person.getDisplayName(context, person.getName());

                //get the vaults of the Person's company
                DomainObject domainPerson = DomainObject.newInstance(context,person);
                String personVault = person.getVaultName(context);

                MapList routetemplateList = new MapList();
                DomainObject project = DomainObject.newInstance(context);

                String objectId = emxGetParameter(request,"objectId");
                String expandTypeWhere  = "";
                String queryTypeWhere   = "";
                queryTypeWhere = "('" + DomainObject.SELECT_CURRENT + "' == 'Active')";
                expandTypeWhere = "('" + DomainObject.SELECT_CURRENT + "' == 'Active')";
                //query selects
                StringList objectSelects = new StringList();
                objectSelects.add(DomainObject.SELECT_ID);
                objectSelects.add(DomainObject.SELECT_TYPE);
                objectSelects.add(DomainObject.SELECT_REVISION);
                objectSelects.add(DomainObject.SELECT_NAME);
                objectSelects.add(DomainObject.SELECT_DESCRIPTION);
                objectSelects.add(DomainObject.SELECT_CURRENT);
                objectSelects.add(DomainObject.SELECT_OWNER);
                //build type and rel patterns
                typePattern = new Pattern(DomainConstants.TYPE_PROJECT_SPACE);
                typePattern.addPattern(DomainConstants.TYPE_ROUTE_TEMPLATE);
                relPattern = new Pattern(DomainConstants.RELATIONSHIP_MEMBER);
                relPattern.addPattern(DomainConstants.RELATIONSHIP_ROUTE_TEMPLATES);

                // get all workspaces that the user is a Project-Member
                MapList projectspaceList = person.getRelatedObjects(context,
                                        relPattern.getPattern(),  //String relPattern
                                        typePattern.getPattern(), //String typePattern
                                        objectSelects,            //StringList objectSelects,
                                        null,                     //StringList relationshipSelects,
                                        true,                     //boolean getTo,
                                        true,                     //boolean getFrom,
                                        (short)2,                 //short recurseToLevel,
                                        ""              ,          //String objectWhere,
                                        "",                       //String relationshipWhere,
                                        null,       //Pattern includeType,
                                        null,        //Pattern includeRelationship,
                                        null);                    //Map includeMap
                int size =0;
                Map projectMap=null;
                if( (projectspaceList != null) && ( projectspaceList.size() >0) )
                {
                        size = projectspaceList.size();
                        String projectType="";
                        for(int i=0;i<size;i++)
                        {
                                projectMap = (Map)projectspaceList.get(i);
                                projectType = (String)projectMap.get(DomainObject.SELECT_TYPE);
                                if( ( projectType !=null) && (projectType.equals("")) && (projectType.equals(DomainConstants.TYPE_ROUTE_TEMPLATE)) )
                                        routetemplateList.add(projectMap);
                        }
                }
                StringList objectSelects1 = new StringList();
                objectSelects1.add(DomainObject.SELECT_ID);
                //getting null when the person doesn't have access to project.
                //objectSelects1.add("from["+DomainConstants.RELATIONSHIP_PROJECT_ACCESS_LIST+"].to.id");
                // get all projectspaces that the current user is a member since one of his roles is a member and groups is a member
                MapList roleProjectspaceList = DomainObject.querySelect(context,
                                      DomainConstants.TYPE_PROJECT_ACCESS_LIST,                // type pattern
                                      DomainObject.QUERY_WILDCARD, // namePattern
                                      DomainObject.QUERY_WILDCARD, // revPattern
                                      DomainObject.QUERY_WILDCARD, // ownerPattern
                                      personVault,                 // get the Person Company vault
                                      "",              // where expression
                                      true,                        // expandType
                                      objectSelects1,               // object selects
                                      null,                        // cached list
                                      true);                       // use cache
                DomainObject PALObj = null;
                if( (roleProjectspaceList != null) && ( roleProjectspaceList.size() >0) )
                {
                        PALObj=DomainObject.newInstance(context);
                        size = roleProjectspaceList.size();
                        String projectId ="";
                        //build type and rel patterns
                        typePattern = new Pattern(DomainConstants.TYPE_ROUTE_TEMPLATE);
                        relPattern = new Pattern(DomainConstants.RELATIONSHIP_ROUTE_TEMPLATES);
                        for(int i=0;i<size;i++)
                        {
                                projectMap = (Map)roleProjectspaceList.get(i);
                                projectId= (String)projectMap.get(DomainObject.SELECT_ID);
                                PALObj.setId(projectId);
                                projectId= (String)PALObj.getInfo(context,"from["+DomainConstants.RELATIONSHIP_PROJECT_ACCESS_LIST+"].to.id");
                                MapList tempList=null;
                                if( (projectId != null) && (!projectId.equals("")) )
                                {
                                        project.setId(projectId);
                                        tempList = project.getRelatedObjects(context,
                                                        relPattern.getPattern(),  //String relPattern
                                                        typePattern.getPattern(), //String typePattern
                                                        objectSelects,            //StringList objectSelects,
                                                        null,                     //StringList relationshipSelects,
                                                        true,                     //boolean getTo,
                                                        true,                     //boolean getFrom,
                                                        (short)1,                 //short recurseToLevel,
                                                        ""              ,          //String objectWhere,
                                                        "",                       //String relationshipWhere,
                                                        null,       //Pattern includeType,
                                                        null,        //Pattern includeRelationship,
                                                        null);                    //Map includeMap
                                }
                                if( (tempList != null) &&  (tempList.size() > 0) )
                                {
                                        routetemplateList.addAll(tempList);
                                }
                        }
                }
                Iterator routetemplateListItr = routetemplateList.iterator();

                       // get a list of workspace id's for the member
                       while(routetemplateListItr.hasNext())
                       {
                                        Map routetemplateMap = (Map)routetemplateListItr.next();
                                          String strRevision = (String)routetemplateMap.get("revision");
                                          String strOwner = (String)routetemplateMap.get("owner");
                                          String templateId = (String)routetemplateMap.get("id");
                                          String templateName = (String)routetemplateMap.get("name");
                                          String templateDesc = (String)routetemplateMap.get("description");
                                          String templateState = (String)routetemplateMap.get("current");
                                          String basePurpose=(String)routetemplateMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
                                          String restrictmembers=(String)routetemplateMap.get("attribute["+DomainObject.ATTRIBUTE_RESTRICT_MEMBERS+"]");
        %><!-- //XSSOK -->
                                          <tr class="<%=classname%>">
                                                <td><input type="radio" name ="radList" id="radList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, templateName)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateId)%>@<%=XSSUtil.encodeForHTMLAttribute(context, templateDesc)%>#<%=XSSUtil.encodeForHTMLAttribute(context, basePurpose)%>#<%=XSSUtil.encodeForHTMLAttribute(context, restrictmembers)%>" /></td>
                                                <td><%=XSSUtil.encodeForHTML(context, templateName)%>&nbsp;</td>
                                                <td><%=XSSUtil.encodeForHTML(context, strRevision)%>&nbsp;</td>
                                                <td><%=XSSUtil.encodeForHTML(context, templateDesc)%>&nbsp;</td>
                                          </tr>
         <%
                                                      if(classname == "odd") {
                                                        classname = "even";
                                                      }
                                                      else {
                                                        classname = "odd";
                                                        }
                        }//While

                        if(routetemplateList.size()>0)
                        {
                                isTemplate = true;
                        }
                }//Projectspace
                if(!isTemplate)
                {
%>
                        <tr>
                               <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.SearchTemplate.NoRouteTemplatesFound</emxUtil:i18n></td>
                        </tr>

<%
                }
%>
        </table>
</form>

<%!
// Method to get Route Template list.
public MapList getTemplateList(Context context,
                                    DomainObject domObj,
                                     String sNamePattern) throws FrameworkException {


  MapList TemplateList = new MapList();

  String sObjectWhere   = "";
  String sStateActive          = PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ROUTE_TEMPLATE, "state_Active");

  StringList objectSelects = new StringList();
  objectSelects.add(domObj.SELECT_ID);
  objectSelects.add(domObj.SELECT_NAME);
  objectSelects.add(domObj.SELECT_REVISION);
  objectSelects.add(domObj.SELECT_DESCRIPTION);
  objectSelects.add(domObj.SELECT_OWNER);
  objectSelects.add("current");
  objectSelects.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
  objectSelects.add("attribute["+DomainObject.ATTRIBUTE_RESTRICT_MEMBERS+"]");


  Pattern relPattern;
  Pattern typePattern;
  String sWhere = "*";


   // build select params for Relationship
   relPattern  = new Pattern(domObj.RELATIONSHIP_ROUTE_TEMPLATES);
   // build Relationship and Type patterns
   typePattern = new Pattern(domObj.TYPE_ROUTE_TEMPLATE);



  try {
    if(domObj !=null) {
      if(!sNamePattern.trim().equals("*")) {
        sObjectWhere="('" + domObj.SELECT_NAME + "' ~= '"+sNamePattern+"')";
      }
      if(domObj.TYPE_PERSON.equals(domObj.getTypeName())) {
        sObjectWhere = "(owner == \""+domObj.getName()+"\")"+(("".equals(sObjectWhere))?"":(" && "+sObjectWhere));
      }
      sObjectWhere += "".equals(sObjectWhere)?"(revision ~~ last)" : " && (revision ~~ last)";

      sObjectWhere +=" &&(current ==" + sStateActive +")";


      TemplateList = domObj.getRelatedObjects(context,
                                                   relPattern.getPattern(),
                                                   typePattern.getPattern(),
                                                   objectSelects,
                                                   null,
                                                   true,
                                                   true,
                                                   (short)1,
                                                   sObjectWhere,
                                                    "",
                                                   null,
                                                   null,
                                                   null);

    }
    return TemplateList;
  } catch (Exception ex) {
      throw new FrameworkException(ex);
  }
}

%>
<%
  // ----- Common Page End Include  -------
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
