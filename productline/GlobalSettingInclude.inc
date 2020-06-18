<%--
  GlobalSettingInclude.jsp


  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>
 <%-- 
    //The variables that will be accessed in the jsp that will include this jsp.
    //these variables are initialized by default values
    //the PolicyAwareness and ValutAwareness variables will be available in String as well as
    //boolean format 
 --%>
    <%@page import= "com.matrixone.apps.domain.util.i18nNow"%>
    <%@page import= "com.matrixone.apps.common.Person"%>

    <%

    String strAutoNamer = "";
    boolean bPolicyAwareness = false;
    boolean bShowVault = false;
    String strPolicyAwareness = "";
    String strShowVault = "";
    String strProperty = "";

    /*the format of the 3 global settings variables are as follows:
    *
    *AutoNamer-> emxProduct.<ModuleName>.AutoNamer = <true/flase/ >
    *   values can be true/false or can also be left blank
    *PolicyAwareness-> emxProduct.PolicyAwareness = <true/flase>
    *   values can be true or false
    *ShowVault-> emxProduct.ShowVault = <true/flase>
    *   values can be true or false
    *in case in the property file the above values are not found then the default values
    *will be passed
    */

    String strModule = emxGetParameter(request,"PRCFSParam1");

    String strCompareAutoNamerString = "emxProduct.".concat(strModule).concat(".AutoNamer");
    String strComparePolicyString = "emxProduct.PolicyAwareness";

    // for getting the ShowVault Setting in emxProductLine.properties
    String strCompareShowVault = "emxProduct.ShowVault";

    //To get the Property entries for Autonamer, Policy Awareness and Vault Awareness.
    //Removed application.getAttribute() calls as it has been deprecated for Bug 327623
    strProperty = FrameworkProperties.getProperty("eServiceSuiteProductLine.PropertyFileAlias");
    strAutoNamer = FrameworkProperties.getProperty(strCompareAutoNamerString);
    strShowVault = FrameworkProperties.getProperty(strCompareShowVault);
    strPolicyAwareness = FrameworkProperties.getProperty(strComparePolicyString);
    
    if((strAutoNamer != null) && !"null".equalsIgnoreCase(strAutoNamer)) {
        if(!((strAutoNamer.equalsIgnoreCase("true"))||(strAutoNamer.equalsIgnoreCase("false"))||(strAutoNamer.equals("")))){
          strAutoNamer = "";
        }
    }
    else
    {
        strAutoNamer = "";
    }

    if((strPolicyAwareness != null) && !"null".equalsIgnoreCase(strPolicyAwareness))
    {
        if(strPolicyAwareness.equalsIgnoreCase("true")){
          bPolicyAwareness = true;
        }else if(strPolicyAwareness.equalsIgnoreCase("false")){
          bPolicyAwareness = false;
        }
    }

    if((strShowVault != null) && !"null".equalsIgnoreCase(strShowVault))
        {
                if(strShowVault.equalsIgnoreCase("true")){
                      bShowVault = true;
                }else if(strShowVault.equalsIgnoreCase("false")){
                      bShowVault = false;
                }
    }

    // getting the default for the user in case of vault awareness setting turned on
    String strUserVault = null;
	String strUserVaultDisplay=null;

    if (bShowVault)
    {
      Person person = Person.getPerson(context);
      strUserVault =  person.getVaultName(context);
      strUserVaultDisplay = i18nNow.getI18NVaultNames(context,strUserVault,acceptLanguage);
    }
%>
