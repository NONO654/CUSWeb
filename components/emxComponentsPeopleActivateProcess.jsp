<%--  emxComponentsPeopleActivateProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPeopleActivateProcess.jsp.rca 1.5 Wed Oct 22 16:18:34 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  
  String url = "";
  String delId  ="";
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  String selectedPeople[] = new String[checkBoxId.length];

//  Added for 297703
  MapList mapList=new MapList();
  StringList stList=new StringList();
  String sOwner1="";
  String sPerson="";
  String sType="";
  String sName="";
  String sRev="";
  String sRouteType="";
  String sRouteName="";
  String sRouteRev="";
  String ObjectId="";
  String sOwner="";
// End for 297703 

  if(checkBoxId != null )
  {
      try
      {  
          DomainObject domObject = null;
          String sState = null;
          String stateActive = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_PERSON, "state_Active");
          StringTokenizer st = null;
          String sRelId = "";
          String sObjId = "";
          for(int i=0;i<checkBoxId.length;i++)
          {
            // In inactive people Summary page, only the persob object id is passed, no relationship id
            // so, condition is being checked for "|", which divides relId and objectId
            if(checkBoxId[i].indexOf("|") != -1)
            {
             st = new StringTokenizer(checkBoxId[i], "|");
             sRelId = st.nextToken();
             sObjId = st.nextToken();
            }
            else
            {
              sObjId = checkBoxId[i];
            }

             domObject = new DomainObject(sObjId);
             sOwner1=domObject.getInfo(context,DomainConstants.SELECT_OWNER);
             domObject.open(context);
             
             sState = domObject.getInfo(context,DomainObject.SELECT_CURRENT);

             if(!sState.equals(stateActive))
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

         //  Added for 297703 to get all the related objects of selected member list
             String personName = domObject.getInfo(context,DomainConstants.SELECT_NAME);
             stList.addElement(DomainConstants.SELECT_ID);
             mapList=domObject.getRelatedObjects(context,
                                                "*",
                                                "*",
                                                stList,
                                                null,
                                                true,
                                                true,
                                                (short)1,
                                                "",
                                                null);

             Iterator itr=mapList.iterator();
             while(itr.hasNext())
             {
                  Map map=(Map)itr.next();
                  String objectID=(String)map.get("id");
                  DomainObject domObj=new DomainObject(objectID);

				  //Retrieving all the owner names of object ID
                  sOwner=domObj.getInfo(context,DomainConstants.SELECT_OWNER);
                  sType=domObj.getInfo(context,DomainConstants.SELECT_TYPE);
                  sName=domObj.getInfo(context,DomainConstants.SELECT_NAME);
                  sRev=domObj.getInfo(context,DomainConstants.SELECT_REVISION);

                   String[] arguments = new String[20];
                   arguments[0]  = sOwner;
                   arguments[1]  = "emxFramework.ProgramObject.ActivateNotice";
                   arguments[2]  = "0";
                   arguments[3]  = "emxFramework.ProgramObject.ActivateMessage";
                   arguments[4]  = "7";
                   arguments[5]  = "name";
                   arguments[6]  =  sOwner1;
                   arguments[7]  = "Type";
                   arguments[8]  = sType;
                   arguments[9]  = "Name";
                   arguments[10]  = sName;
                   arguments[11]  = "Rev";
                   arguments[12]  = sRev;
                   arguments[13]  = "PersonName";
                   arguments[14]  = personName;
                
				   //When person is activated 
				   //sending notification mail to all the users whcih are connected to objects

                   int strMsg=(int)JPO.invoke(context,
                                               "emxMailUtilBase",
                                                null,
                                               "sendNotificationToUser",
                                               arguments);
               }
// End for 297703 
            
             domObject.close(context);
          }       
 
      }catch(Exception Ex){
           session.putValue("error.message", Ex.toString());
      }
  }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">
      getTopWindow().refreshTablePage();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

