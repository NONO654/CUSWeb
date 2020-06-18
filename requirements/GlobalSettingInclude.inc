<%--
  GlobalSettingInclude.jsp


  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>
<%
   /******************************************************************************************************************
    * Description       :
    *
    * This jsp contains the business logic. The module name is obtained from a start page by a request.getParameter()
    * Againts this module the property file is searched to obtain the
    * Autonamer,PolicyAwareness and ShowVault values
    *
    * Known Bugs           :
    *
    * Modification Log
    * Date                 Author                                           Description
    * ----------------------------------------------------------------------------------------------------------------
    * 18-02-2003      Tanmoy Chatterjee(Enovia MatrixOne Technologies)
    * 20-02-2003      Tanmoy Chatterjee(Enovia MatrixOne Technologies) implemented the reading of parameters from
    *                 property file using the class i18nNow
    * 21-02-2003      Tanmoy Chatterjee(Enovia MatrixOne Technologies) the property file name will be read using
    *                 properties.getProperty()
    * 09-05-2003      A S Prakash (Enovia MatrixOne Technologies) used the System.properties for making the Policy and
    *                 Vault a application settings
    ******************************************************************************************************************/

   //The variables that will be accessed in the jsp that will include this jsp.
   //these variables are initialized by default values
   //the PolicyAwareness and ValutAwareness variables will be available in String as well as
   //boolean format
%>
<%@page import= "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import= "com.matrixone.apps.common.Person"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
   String strAutoNamer = "";
   boolean bPolicyAwareness = false;
   boolean bShowVault = false;
   String strPolicyAwareness = "";
   String strShowVault = "";
   String strProperty = "";

   /* the format of the 3 global settings variables are as follows:
    *
    * AutoNamer: emxRequirements.{ModuleName}.AutoNamer = [ true | false | ]
    *   values can be true/false or can also be left blank
    * PolicyAwareness: emxRequirements.PolicyAwareness = [ true | false ]
    *   values can be true or false
    * ShowVault: emxRequirements.ShowVault = [ true | false ]
    *   values can be true or false
    * If the above values are not found in the property file then the
    * default values will be passed
    */

   String strModule = emxGetParameter(request, "PRCFSParam1");

   String strCompareAutoNamerString = "emxRequirements.".concat(strModule).concat(".AutoNamer");
   String strComparePolicyString = "emxRequirements.PolicyAwareness";

   // for getting the ShowVault Setting in emxRequirements.properties
   String strCompareShowVault = "emxRequirements.ShowVault";

   // To get the Property entries for Autonamer, Policy Awareness and Vault Awareness.
   // Removed application.getAttribute() calls as it has been deprecated for Bug 327623
   strProperty = EnoviaResourceBundle.getProperty(context, "eServiceSuiteRequirements.PropertyFileAlias");
   strAutoNamer = EnoviaResourceBundle.getProperty(context, strCompareAutoNamerString);
   strShowVault = EnoviaResourceBundle.getProperty(context, strCompareShowVault);
   strPolicyAwareness = EnoviaResourceBundle.getProperty(context, strComparePolicyString);

   if ((strAutoNamer != null) && !"null".equalsIgnoreCase(strAutoNamer))
   {
      if (!((strAutoNamer.equalsIgnoreCase("true")) || (strAutoNamer.equalsIgnoreCase("false")) || (strAutoNamer.equals(""))))
         strAutoNamer = "";
   }
   else
   {
      strAutoNamer = "";
   }

   if ((strPolicyAwareness != null) && !"null".equalsIgnoreCase(strPolicyAwareness))
   {
      if (strPolicyAwareness.equalsIgnoreCase("true"))
         bPolicyAwareness = true;
      else if (strPolicyAwareness.equalsIgnoreCase("false"))
         bPolicyAwareness = false;
   }

   if ((strShowVault != null) && !"null".equalsIgnoreCase(strShowVault))
   {
      if (strShowVault.equalsIgnoreCase("true"))
         bShowVault = true;
      else if (strShowVault.equalsIgnoreCase("false"))
         bShowVault = false;
   }

   // Getting the default for the user in case of vault awareness setting turned on
   String strUserVault = null;
   String strUserVaultDisplay = null;

   if (bShowVault)
   {
      Person person = Person.getPerson(context);
      strUserVault = person.getVaultName(context);
      strUserVaultDisplay = i18nNow.getI18NVaultNames(context, strUserVault, acceptLanguage);
   }
%>
