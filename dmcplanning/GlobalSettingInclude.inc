<%--
  GlobalSettingInclude.jsp


  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>
 <%  /******************************************************************************************************************
  * Description       :
   *
   * This jsp contains the business logic. The module name is obtained from a start page by a emxGetParameter(request)
   * Againts this module the property file is searched to obtain the
   * Autonamer,PolicyAwareness and ShowVault values
   *
   * Known Bugs           :
   *
   * Modification Log
   * Date                 Author                                           Description
   * -----------------------------------------------------------------------------------------------------------------
   * 05-11-2009     Praveen Voggu - IVU (3DPLM)
  ********************************************************************************************************************
*/
        //The variables that will be accessed in the jsp that will include this jsp.
    //these variables are initialized by default values
    //the PolicyAwareness and ValutAwareness variables will be available in String as well as
    //boolean format %>
    <%@page import= "com.matrixone.apps.domain.util.i18nNow"%>
    <%@page import= "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
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
    

    String strCompareAutoNamerString = "DMCPLanning.".concat(strModule).concat(".AutoNamer");
    String strComparePolicyString = "emxProduct.PolicyAwareness";

    // for getting the ShowVault Setting in emxProduct.properties
    String strCompareShowVault = "emxProduct.ShowVault";

    //To get the Property entries for Autonamer, Policy Awareness and Vault Awareness.
    strProperty = EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration.PropertyFileAlias");
    strAutoNamer = EnoviaResourceBundle.getProperty(context,strCompareAutoNamerString);
    strShowVault = EnoviaResourceBundle.getProperty(context,strCompareShowVault);
    strPolicyAwareness = EnoviaResourceBundle.getProperty(context,strComparePolicyString);
    
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
