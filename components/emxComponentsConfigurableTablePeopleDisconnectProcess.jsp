<%--  emxComponentsConfigurableTablePeopleDisconnectProcess.jsp   -  This page disconnects the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsConfigurableTablePeopleDisconnectProcess.jsp.rca 1.8 Wed Oct 22 16:18:25 2008 przemek Experimental przemek $
--%>


<%@page import="com.matrixone.apps.common.Plant"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  DomainObject rel = DomainObject.newInstance(context);

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String summaryPage = emxGetParameter(request,"summaryPage");

  // we need to get the type of the object that we want to connect the eople to so that
  // we know what relationship to use later
  BusinessObject busObj = new BusinessObject(objectId);
  busObj.open(context);
  String sObjectTypeName = busObj.getTypeName();
  String sObjectName = busObj.getName();
  String typeAlias = FrameworkUtil.getAliasForAdmin(context, "type", sObjectTypeName, true);
  busObj.close(context);

  String url = "";
  String delId  ="";
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  String selectedPeople[] = new String[checkBoxId.length];
  String selectedPeopleRelIds[] = new String[checkBoxId.length];
  if(checkBoxId != null )
  {
      try{

          for(int i=0;i<checkBoxId.length;i++){
             StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
             String sRelId = st.nextToken();
             String sObjId = st.nextToken();

             // save list of ids to delete from the tree
             delId=delId+sObjId+";";
             // create string array of ids
             selectedPeople[i] = sObjId;
             selectedPeopleRelIds[i] = sRelId;
          }
		  DomainObject doOrgObj = new DomainObject(objectId);
		  String sRelName = PropertyUtil.getSchemaProperty(context,"relationship_LeadResponsibility");
		  RelationshipType relType = new RelationshipType(sRelName);
		  for(int i=0;i<selectedPeople.length;i++)
		  {
			try
			{
			  DomainObject doPersonObj = new DomainObject(selectedPeople[i]);
			  doOrgObj.disconnect(context,relType,true,doPersonObj);
			}
			catch (Exception ex)
			{
			}
		  }
          // Disconnect The Person from The Specified Company / Business Unit / Organization
           String hostCompanyName = PropertyUtil.getSchemaProperty(context, "role_CompanyName");
          if ("type_Department".equals(typeAlias) || "type_BusinessUnit".equals(typeAlias) || "type_Company".equals(typeAlias)) {
             com.matrixone.apps.common.Organization orgObj = new com.matrixone.apps.common.Organization(objectId);

             orgObj.removeMemberPersons(context, selectedPeople);
	         if ("type_Company".equals(typeAlias)){
	        	 orgObj.removeEmployeePersons(context, selectedPeople);
	         }
			 if("type_BusinessUnit".equals(typeAlias))
			 {
				 com.matrixone.apps.common.BusinessUnit buObj = new com.matrixone.apps.common.BusinessUnit(objectId);
				 buObj.removeEmployeePersons(context, selectedPeople);
			 }
          } else if ("type_SpecificationOffice".equals(typeAlias)){
             //Disconnect the Persons from the Spec Office
             DomainRelationship.disconnect(context,selectedPeopleRelIds);
          }
           else if ("type_Plant".equals(typeAlias)){
           //Disconnect the Persons from the Plant
           	Plant.disconnectSecurityContextsFromPlant(context, selectedPeople, objectId);
            DomainRelationship.disconnect(context,selectedPeopleRelIds);
          }
           /*Begin of add by Infosys for Bug # 301242 on 3/31/2005*/
             String userName = "";
             for(int i=0;i<selectedPeople.length;i++)
             {
                 //clear the persons RDO cache
                 BusinessObject personBusObj = new BusinessObject(selectedPeople[i]);
                 personBusObj.open(context);
                 userName = personBusObj.getName();
                 personBusObj.close(context);
                 PersonUtil.clearUserCacheProperty(context, userName, "RDO");
                 // clear application cache too
                 HashMap paramMap = new HashMap();
                 paramMap.put("userName", userName);
                 paramMap.put("propertyName", "RDO");
                 String[] methodargs = JPO.packArgs(paramMap);
                 JPO.invoke(context, "emxUtil", null, "clearPersonCacheProperty", methodargs);
             }
           /*End of  add by Infosys for Bug # 301242 on 3/31/2005*/
          url = summaryPage + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;
		  session.setAttribute("company.hashtable", new Hashtable());
      }catch(Exception Ex){
           session.putValue("error.message", Ex.toString());
      }
  }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;
  if (tree)
  {
  	if (tree.root != null) {  
  var parentId = tree.root.id;
  var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
  while (sIdsToken.hasMoreTokens()) {
    String RelId = sIdsToken.nextToken();
%>
    var objId = '<%=XSSUtil.encodeForJavaScript(context, RelId)%>';
    tree.deleteObject(objId);

     if(parentId == objId ){
        isRootId = true;
     }
<%
  }
%>
  }
}
    if(isRootId) {
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=XSSUtil.encodeForURL(context, appDirectory)%>";
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      if (contentFrame) {
        contentFrame.location.replace(url);
      }
      else {
		 if(getTopWindow().refreshTablePage) {
        getTopWindow().refreshTablePage();
         }  
         else {   
         	getTopWindow().location.href = getTopWindow().location.href;
         }      
      }
    } else {
      	if(getTopWindow().refreshTablePage) {  
      getTopWindow().refreshTablePage();
        }  
        else {  
        	getTopWindow().location.href = getTopWindow().location.href;
        }
    }
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

