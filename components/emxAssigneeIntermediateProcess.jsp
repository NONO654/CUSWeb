<%--  emxAssigneeIntermediateProcess.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxAssigneeIntermediateProcess.jsp.rca 1.5.3.2 Tue Oct 28 19:01:08 2008 przemek Experimental przemek $";
--%> 

<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.common.EngineeringChange"%>
<%@page import="com.matrixone.apps.common.Change"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<html>
<head>
</head>
<body>
  <form name="hFrm" method="post" target="_parent">
</body>


<%
    boolean boolIsConfirm      = false;
    String strAlertMessage     = "Sample Alert Message";
    String strConfirmMessage   = "Sample Confirmation Message";
    String strMode             = emxGetParameter(request, "mode");
    String strFunctionality    = emxGetParameter(request, "functionality");
    String strTreeId           = emxGetParameter(request,"jsTreeID");
    String objectId            = emxGetParameter(request, "objectId");
    String strLanguage         = context.getSession().getLanguage();
    //String strTargetURL        = "emxCommonSearch.jsp";
    String strLoginPersonID    = "";
    com.matrixone.apps.common.Person loginPerson = (com.matrixone.apps.common.Person) DomainObject.newInstance(context,DomainConstants.TYPE_PERSON);
    loginPerson = com.matrixone.apps.common.Person.getPerson(context);
    strLoginPersonID = (String)loginPerson.getObjectId();
     String[] strTableRowIds1   = (String[]) emxGetParameterValues(request, "emxTableRowId");
    int count = 0;
    if(strTableRowIds1 !=null)
    {
        count = strTableRowIds1.length;
    }

    String strTargetURL        = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&count="+count+"&loginPersonId="+strLoginPersonID+"&txtExcludeOIDs="+strLoginPersonID;
    String timeStamp           = emxGetParameter(request, "timeStamp");
    Change changeObject        = new Change();
    //HashMap requestMap         = (HashMap)request.getParameterMap();
    Map requestMap         = (Map)request.getParameterMap();
    //HashMap requestMap         = (HashMap)tableBean.getRequestMap(timeStamp);
    String strParentId         = (String)requestMap.get("productID");
    StringList slArrObjIds     = new StringList();
    StringList slArrRelIds     = new StringList();
    StringList slPersonNames   = new StringList();
    boolean bHasAffectedItems  = false;

    String strContextPersonsAssigneeRelID = "";
    if (strMode.equalsIgnoreCase("Delegate"))
    {
        try
        {
			String strMemberClause = "";

			DomainObject doChange = new DomainObject(objectId);

			String strCompId = null;

			if (doChange.isKindOf(context, DomainConstants.TYPE_ECR))
			{
				strCompId = doChange.getInfo(context, "to["+ PropertyUtil.getSchemaProperty(context,"relationship_ChangeResponsibility") + "].from.name");
			}
			else if (doChange.isKindOf(context, DomainConstants.TYPE_ECO))
			{
				strCompId = doChange.getInfo(context, "to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.name");
			}

			if (strCompId != null && strCompId.length() > 0)
			{
				strMemberClause = ":MEMBER=" + strCompId;
			}


            //Retrieves context Change Object Id
            String strParentId1 = emxGetParameter(request, "objectId");
            Map mDelegateMap = new HashMap();
            mDelegateMap.put("strChangeObjID",strParentId1);

            boolean bResultAssignee = changeObject.isContextPersonAssignee(context, mDelegateMap);
            boolean bResultOwner = changeObject.isContextPersonOwner(context, mDelegateMap);
            boolean bRowSelection = false;

            // If some Objects are selected
            if(strTableRowIds1 == null)
            {
                strContextPersonsAssigneeRelID = changeObject.getContextPersonAssigneeRelID(context, mDelegateMap);
                slArrObjIds.add(strLoginPersonID);
                slArrRelIds.add(XSSUtil.encodeForJavaScript(context, strContextPersonsAssigneeRelID));

            }else // If no Objects are selected
            {
                bRowSelection = true;

                Map mapObjIdRelId1       = EngineeringChange.getObjectIdsRelIds(strTableRowIds1);
                //storing Object ids in a String array
                String[] arrObjIds1 = (String[])mapObjIdRelId1.get("ObjId");
                StringList arrObjIds1List = new StringList();

                //storing relationship ids in a String array
                String[] arrRelIds1 = (String[])mapObjIdRelId1.get("RelId");

                if(strTableRowIds1.length>0)
                {
                    for (int j=0; j<strTableRowIds1.length; j++)
                    {
                        //Appending Object Ids and RelIds to the StringLists
                        slArrObjIds.add(arrObjIds1[j]);
                        slArrRelIds.add(arrRelIds1[j]);
                    }
                }
            }
            // If context Person is Owner
            if (bResultOwner)
            {
                // If context Person is Owner + Assignee
                if (bResultAssignee)
                {
                    if (bRowSelection) // some rows selected
                    {
                        strConfirmMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ConfirmMessage.OwnerUserSelect.DelegateAssignee"); 
                        //strConfirmMessage = "You have chosen to Delegate the Affected Items of the selected Users of the List. Delegating the Affected Item of a user changes its ownership. To continue with the delegation, click OK. To cancel the delegation, click Cancel." ;
                        boolIsConfirm = true;
                        //Modified for 379030 
                        //strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&selection=single&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&txtExcludeOIDs="+strLoginPersonID;
                        
                        //Modified for IR-129365V6R2013
                        //strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&includeOIDprogram=emxCommonEngineeringChange:includeAssigneeOIDs&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&selection=single&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;                                                
                        strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&selection=single&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+XSSUtil.encodeForURL(context, strParentId1)+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;
                    }
                    else // no row selection
                    {
                        strConfirmMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ConfirmMessage.UserNoSelect.DelegateAssignee");
                        //strConfirmMessage = "You have chosen to Delegate your Affected Items. This will change their ownership . To continue with the delegation, click OK. To cancel the delegation, click Cancel.";
                        boolIsConfirm = true;
						//Modified for 379030
                        //strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&txtExcludeOIDs=strLoginPersonID&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&txtExcludeOIDs="+strLoginPersonID;
                       
						//Modified for IR-129365V6R2013
						//strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&includeOIDprogram=emxCommonEngineeringChange:includeAssigneeOIDs&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;                                               
                        strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+XSSUtil.encodeForURL(context, strParentId1)+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;
                    }
                }
                else if (!(bResultAssignee)) // If context Person is Owner but not an Assignee
                {
                    if (bRowSelection) // some rows selected
                    {
                        strConfirmMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ConfirmMessage.OwnerUserSelect.DelegateAssignee");
                        //strConfirmMessage = "You have chosen to Delegate the Affected Items of the selected Users of the List. Delegating an Affected Item changes its ownership . To continue with the delegation, click OK. To cancel the delegation, click Cancel." ;
                        boolIsConfirm = true;
                        //strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&txtExcludeOIDs=strLoginPersonID&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&txtExcludeOIDs="+strLoginPersonID;
                        //Modified for 379030
                        
                        //Modified for IR-129365V6R2013
                       // strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&includeOIDprogram=emxCommonEngineeringChange:includeAssigneeOIDs&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;                                              
                        strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+XSSUtil.encodeForURL(context, strParentId1)+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;
                    }else // no row selection
                    {
                        strAlertMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.AlertMessage.OwnerNonAssigneeNoSelect.DelegateAssignee");
                        //strAlertMessage = "You are not a Designated Assignee and hence do not have any Affected Items for Delegation. Hence you cannot perform this action on yourself." ;
                    }
                }

            }
            else if ((!(bResultOwner))& bResultAssignee)// If context Person is Not an Owner but an Assignee
            {
                if (!(bRowSelection)) // some rows selected
                {
                    strConfirmMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ConfirmMessage.UserNoSelect.DelegateAssignee");
                    //strConfirmMessage = "You have chosen to Delegate your Affected Items. Delegating an Affected Item changes its ownership . To continue with the delegation, click OK. To cancel the delegation, click Cancel.";
                    boolIsConfirm = true;
                    //strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&txtExcludeOIDs=strLoginPersonID&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&txtExcludeOIDs="+strLoginPersonID;
                    //Modified for 379030
                    
                     //Modified for IR-129365V6R2013
                    //strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&includeOIDprogram=emxCommonEngineeringChange:includeAssigneeOIDs&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+strParentId1+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;                                       
                    strTargetURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_SeniorDesignEngineer,role_DesignEngineer" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=ECSearchPersonsTable&selection=single&excludeOIDprogram=emxCommonEngineeringChange:getDelegateAssigneesExcludePersonList&hideHeader=true&submitURL=../components/emxComponentsECRECODelegateAssignmentProcess.jsp&strParentId="+XSSUtil.encodeForURL(context, strParentId1)+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&count="+count+"&loginPersonId="+strLoginPersonID+"&excludeOID="+strLoginPersonID;
                }else
                {
                    strAlertMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.AlertMessage.AssigneeNonOwnerSelect.DelegateAssignee");
                    //strAlertMessage = "Please unselect the selected user/users and then try." ;
                }
            }

        }catch (Exception e)
            {
                System.out.println(e.toString());
            }



    }

    //Adding the parameters from the previous page to the URL.
    strTargetURL += "&"+XSSUtil.encodeURLwithParsing(context, emxGetQueryString(request));

    //Alert or Confirm the user
    if(boolIsConfirm)
    {
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script src="scripts/emxUIModal.js" type="text/javascript"></script>
    <script language="javascript">
        var vConfirm = confirm("<%=XSSUtil.encodeForJavaScript(context, strConfirmMessage)%>");
        if(vConfirm)
         {
        	//XSSOK
        	showModalDialog(<%=strTargetURL%>);
         }
         else
         {
            window.closeWindow();
         }
    </script>
<%
    }else
    {
%>
    <script language="javascript">
        alert("<%=XSSUtil.encodeForJavaScript(context, strAlertMessage)%>");
        window.closeWindow();
    </script>
<%
    }
%>
</html>
