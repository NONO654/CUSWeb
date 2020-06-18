<%--  emxCommonAppInitializationInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
  static const char RCSID[] = $Id: emxCommonAppInitializationInclude.inc.rca 1.32 Wed Oct 22 16:09:56 2008 przemek Experimental przemek $
--%>

<%
String requestURI = request.getRequestURI();
if(context.getPasswordStatus() != 0)
{
    String dispatcherURL = "";
    if (requestURI != null && requestURI.indexOf("emxNavigator.jsp") > 0)
    {
        dispatcherURL = "emxChangeExpiredPassword.jsp";
    } else {
        dispatcherURL = "common/emxChangeExpiredPassword.jsp";
    }
    request.getRequestDispatcher(dispatcherURL).forward(request, response);
} else {
      //load system properties
    String DateStr="";

    boolean personSchemaExist = PersonUtil.isPersonObjectSchemaExist(context);
    Boolean emxCommonAppInitialized = null;

    //set the filter pattern for parameters in the Request bean
    String filterParameterPattern = FrameworkProperties.getProperty(context, "emxFramework.FilterParameterPattern");
    if (filterParameterPattern != null)
    {
      Request.setFilterPattern(filterParameterPattern);
    }

    // Check for the seesion to verify if the same initialization is already run once
    if (session.getAttribute("emxCommonAppInitialized") == null)
    {
        emxCommonAppInitialized = Boolean.valueOf(false);
    } else {
        emxCommonAppInitialized = (Boolean)session.getAttribute("emxCommonAppInitialized");
    }
    if (!emxCommonAppInitialized.booleanValue())
    {
        try
        {

            context.setLocale(com.matrixone.apps.domain.util.i18nNow.getLocale(request.getHeader("Accept-Language")));
              // Set the eMatrixDateFormat based on the property settings.
            eMatrixDateFormat.setEMatrixDateFormat(context);

            boolean isCreate=false;//flag to dictate whether a person object is to be created.
            boolean isNewPerson=false;//flag to dictate whether a connection needs to be made.
            String sCreatePerson="";
            String sCompanyName="";

            BusinessObject companyObj =null;
            BusinessObject personObj = null;

            //Get username and vault
            String sVault=context.getVault().toString();
            String sUser=context.getUser().toString().trim();


            if (personSchemaExist)
            {
                try{
                    sCreatePerson = FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.emxCreatePersonBusObject");
                }catch(Exception e){
                    sCreatePerson = "";
                    DebugUtil.debug(e.toString());
                }

                if((sCreatePerson==null) || ("".equals(sCreatePerson)))
                {
                    isCreate=false;
                } else {
                    if(sCreatePerson.equalsIgnoreCase("TRUE")){
                        isCreate=true;
                    }
                }

                //Check to see if a default Vault has been assigned for User. If Not, Use Vault from emxSystem.Properties
                if ((sVault == null) || ("".equals(sVault)))
                {
                    try{
                        sVault= FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.emxSafetyVault");
                    } catch(Exception e){
                         sVault = "";
                         DebugUtil.debug(e.toString());
                    }
                    if((sVault==null) || ("".equals(sVault))){
                        isCreate=false;
                    }
                }

                String sPersonType = PropertyUtil.getSchemaProperty(context,"type_Person");
                String sPersonPolicy = PropertyUtil.getSchemaProperty(context,"policy_Person");

                String sPersonId = "";

                String sRev="-";
                String slResult = MqlUtil.mqlCommand(context,"print bus $1 $2 $3 select $4 dump;",true,sPersonType,sUser,sRev,"exists");
                if(isCreate) {
                    if(slResult.equals("FALSE")) {
                        personObj= new BusinessObject(sPersonType, sUser, "-",sVault);
                        Policy policyObj = new Policy (sPersonPolicy);
                        policyObj.open(context);
                        personObj.create(context, policyObj.getName());
                        try {
                            personObj.promote(context);
                        } catch (MatrixException me) {
                            DebugUtil.debug("Promotion failed:"+me.toString());
                        }

                        isNewPerson=true;
                        policyObj.close(context);
                    }
                } else {
                    if(slResult.equals("FALSE"))
                    {
%>
                        <script language="JavaScript">
                            alert("<emxUtil:i18nScript localize='i18nId'>emxFramework.Login.ErrorIncativePersonState</emxUtil:i18nScript>");
<%
                            if (requestURI != null && requestURI.indexOf("emxHome.jsp") > 0)
                            {
%>
                                document.location.href = "emxLogout.jsp";
<%
                            } else {
%>
                                document.location.href = "../emxLogout.jsp";
<%
                            }
%>
                        </script>
<%
                    }
                }

                if(isNewPerson)
                {
                    String error = "";
                    String sErrorCode = "";
                    String prMQLString;
                    String strRole = PropertyUtil.getSchemaProperty(context,"role_CompanyName");
                    String sCompany = PropertyUtil.getSchemaProperty(context,"type_Company");
                    String relPattern = PropertyUtil.getSchemaProperty(context,"relationship_Employee");
                    RelationshipType relType = new RelationshipType(relPattern);
                    String slResults = MqlUtil.mqlCommand(context ,"print Person $1 select $2 dump $3",true,sUser,"assignment[" +strRole+ "]","|");
                    if(!slResults.equals("")) {
                        StringTokenizer st = new StringTokenizer(slResults, "|");
                        while(st.hasMoreTokens())
                            sCompanyName=st.nextToken().trim();
                    }

                    personObj.open(context);

                    sPersonId=personObj.getObjectId();
                    //Get the business id from a function for the company name
                    String sCompanyId = com.matrixone.apps.common.util.ComponentsUtil.getBusIdForTNR(context, sCompany, sCompanyName, "-");
                    boolean isConnect=false;
                    if(sCompanyId.length()==0)
                        isConnect=false;
                    else
                        isConnect=true;

                    if(isConnect)
                    {
                        companyObj=new BusinessObject(sCompanyId);
                        companyObj.open(context);
                        //USE SHADOW AGENT TO CONNECT BUSINESS OBJECTS
                        MQLCommand connectMQL = new MQLCommand();
                        connectMQL.open(context);

                        connectMQL.executeCommand(context,"execute program $1 $2 $3 $4 $5 $6",
                                                                   "eServicecommonConnectDisconnectObjects.tcl","connect",sCompanyId,sPersonId,"relationship_Employee","");
                        String result = connectMQL.getResult().trim();
                        String err = connectMQL.getError();
                        connectMQL.close(context);

                        StringTokenizer sTokenErrorMsg = new StringTokenizer(err, "|");
                        while (sTokenErrorMsg.hasMoreTokens())
                        {
                            String sErrCode = sTokenErrorMsg.nextToken().trim();
                            if(sErrCode.equals("1"))
                                throw new MatrixException(sTokenErrorMsg.nextToken().trim());
                        }
                    }//End of if condition

                    if(personObj.isOpen())
                        personObj.close(context);

                    if(companyObj.isOpen())
                       companyObj.close(context);
                }
            }

        } catch(Exception e) {
            DebugUtil.debug("Error while initializing : "+ e.toString());
        }
        emxCommonAppInitialized = Boolean.valueOf(false);
        session.setAttribute("emxCommonAppInitialized", emxCommonAppInitialized);
        try{
			MqlUtil.mqlCommand(context, "trigger off", true);
            com.matrixone.apps.domain.util.PersonUtil.updateLastLogin(context);
        }
        catch(Exception e) {
            DebugUtil.debug("Error while updating Last Login : "+ e.toString());
        }finally{
              MqlUtil.mqlCommand(context, "trigger on", true);
        }
    }
}
%>
