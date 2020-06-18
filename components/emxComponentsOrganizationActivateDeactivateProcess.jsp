<%--  emxComponentsOrganizationActivateDeactivateProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsOrganizationActivateDeactivateProcess.jsp.rca 1.8 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
--%>


<%@include file = "emxComponentsDesignTopInclude.inc"%>

<%
String accessUsers = "role_BuyerAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  MapList businessUnitMapList = null;
  StringList selectRelStmts  = new StringList();
  StringList selectTypeStmts = new StringList();
  Hashtable businessUnitData  = null;
  ArrayList businessUnits     = null;
  String sRelDivision         = PropertyUtil.getSchemaProperty(context, "relationship_Division" );
  String sTypeBusinessUnit    = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String id                   = null;
  int index = 0;
  if(objectId != null )
  {
      try
      {
          String stateActive = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_ORGANIZATION, "state_Active");
          DomainObject domObject = new DomainObject(objectId);
          domObject.open(context);
          String sState = domObject.getInfo(context,DomainObject.SELECT_CURRENT);

          if(sState.equals(stateActive))
          {
              try
              {
                  domObject.demote(context);
				  //Deactivate the BusinessUnits under that company 
                    // This code can be moved to the Company bean when we do the clean up.
                    selectTypeStmts.add(domObject.SELECT_NAME);
                    selectTypeStmts.add(domObject.SELECT_ID);
                    businessUnitMapList =  domObject.expandSelect(context,
                                                                        sRelDivision,
                                                                        sTypeBusinessUnit,
                                                                        selectTypeStmts,
                                                                        selectRelStmts,
                                                                        false,
                                                                        true,
                                                                        (short)0,
                                                                        "",
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        null,
                                                                      false);
                    businessUnits = (ArrayList)businessUnitMapList;
                    int busUnitSize  =  0;
                    busUnitSize = businessUnits.size(); 
                    for (index=0; index <busUnitSize ; index++) {
                        businessUnitData = (Hashtable)businessUnits.get(index);
                        BusinessObject businessunit = new BusinessObject((String) businessUnitData.get("id"));
                        businessunit.demote(context);
                    }
              }
              catch (MatrixException me)
              {
				  session.setAttribute("error.message", me.getMessage());
              }
          }
          else
          {
              try
              {
                  domObject.promote(context);
              }
              catch (MatrixException me)
              {
                  session.setAttribute("error.message", me.getMessage());
              }
          }
         domObject.close(context);

     }catch(Exception Ex)
     {
        session.putValue("error.message", Ex.toString());
     }
  }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"type="text/javascript"> </script>
<script language="JavaScript" src="../common/scripts/emxUICore.js"type="text/javascript"> </script>
<script language="Javascript">
  var frameContent = findFrame(getTopWindow(), "detailsDisplay");
  frameContent.document.location.href=frameContent.document.location.href;
  if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
	getTopWindow().opener.getTopWindow().RefreshHeader();
  }else if(getTopWindow().RefreshHeader){
	getTopWindow().RefreshHeader();
  }

</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

