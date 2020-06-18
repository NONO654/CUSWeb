<%--  emxCommonAppInitialization.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
  static const char RCSID[] = $Id: emxCommonAppInitialization.jsp.rca 1.28 Wed Oct 22 15:48:11 2008 przemek Experimental przemek $
--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, com.matrixone.apps.domain.*, com.matrixone.apps.framework.ui.*, com.matrixone.apps.domain.util.*, java.util.*, java.io.*" errorPage="emxNavigatorErrorPage.jsp"%>

<%
    // initialization programs which are global/common across the applications
    // The login servlet does not properly set the locale in the context.
    // This code fixes up the locale by calling an external function.
    // The code should ultimately be moved into the LoginServlet
    String lang     = request.getHeader("Accept-Language");             
    Locale locale   = new Locale(lang);   
    try
    {
        matrix.db.Context context = Framework.getFrameContext(session);
        context.setLocale(i18nNow.getLocale(lang));

        if (PersonUtil.isPersonObjectSchemaExist(context))
        {
            DomainObject personDomainBean   = PersonUtil.getPersonObject(context);
            String personTypeName           = PropertyUtil.getSchemaProperty(context,"type_Person");
            String employeeRel              = PropertyUtil.getSchemaProperty(context,"relationship_Employee");                    
            String currPersonStateName      = "";
            String currCompanyStateName     = "";

            // Check if the person business object exist.
            String sCmd             = "print businessobject $1 $2 $3 select $4 dump $5";
            String personExistName  = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,sCmd,personTypeName,context.getUser(),"-","exists",";");
  

            // Check if the person state is in "inactive" state.
            if(personExistName.startsWith("TRUE"))
            {
                currPersonStateName = personDomainBean.getInfo(context, "current");
            }

            if ( currPersonStateName != null && (!currPersonStateName.trim().equals("Active")) )
            {
                String personErrorMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, "emxFramework.Login.ErrorIncativePersonState");

                session.setAttribute("emxNavigator.error.message", personErrorMsg );
                %> <jsp:include page ="../emxLogout.jsp" flush="true"/> <%
            }

            // Check if the company state is in "inactive" state.
            currCompanyStateName = personDomainBean.getInfo(context, "to["+employeeRel+"].from.current");

            if ( (currCompanyStateName == null) || (currCompanyStateName != null && (!currCompanyStateName.trim().equals("Active"))) )
            {
                String companyErrorMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, "emxFramework.Login.ErrorIncativeCompanyState");

                session.setAttribute("emxNavigator.error.message", companyErrorMsg );
                %> <jsp:include page ="../emxLogout.jsp" flush="true"/> <%
            }
        }
        //begin set context vault for SSO
        if (context.getVault().getName() == null || "".equals(context.getVault().getName()))
        {
            try
            {
                String sCommand = "print $1 $2 select $3 dump $4";
                String vaultName = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,sCommand,"Person",context.getUser(),"vault",";");
                if ((vaultName != null) && (!"".equals(vaultName))){

                    context.setVault(vaultName);

                }

            } catch(Exception ex) {
                %> <jsp:include page ="../emxLogout.jsp" flush="true"/> <%
            }
        }

    } catch(Exception e) {
        System.out.println("emxCommonAppInitialization: Error while initializing : " + e.toString());
    }
%>

