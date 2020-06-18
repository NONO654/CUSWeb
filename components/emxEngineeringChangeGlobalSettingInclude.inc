<%--  emxEngineeringChangeGlobalSettingInclude.inc

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxEngineeringChangeGlobalSettingInclude.inc.rca 1.6 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $";

--%>

<%@page import= "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import= "com.matrixone.apps.common.Person"%>
<%@page import= "com.matrixone.apps.domain.util.FrameworkProperties"%>

<%
    boolean bPolicyAwareness  = false;
    boolean bVaultAwareness   = false;
    boolean bShowVault        = false;
    String strAutoNamer       = "";
    String strPolicyAwareness = "";
    String strVaultAwareness  = "";
    String strShowVault       = "";
    //To get the Property entries for Policy Awareness and Vault Awareness.
    String strProperty = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.PropertyFileAlias");

    strAutoNamer = (String)FrameworkProperties.getProperty(context,"emxComponents.EngineeringChange.AutoNamer");
    strVaultAwareness = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.VaultAwareness");
    strPolicyAwareness = (String)FrameworkProperties.getProperty(context,"emxComponents.AllowChangePolicy");
    strShowVault = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.ShowVault");
        
    

    if((strAutoNamer != null) && !"null".equalsIgnoreCase(strAutoNamer)) {
        if(!((strAutoNamer.equalsIgnoreCase("true"))||(strAutoNamer.equalsIgnoreCase("false"))||(strAutoNamer.equals("")))) {
          strAutoNamer = "";
        }
    } else {
        strAutoNamer = "";
    }

    if((strPolicyAwareness != null) && !"null".equalsIgnoreCase(strPolicyAwareness)) {
        if(strPolicyAwareness.equalsIgnoreCase("true")) {
            bPolicyAwareness = true;
        }else if(strPolicyAwareness.equalsIgnoreCase("false")) {
            bPolicyAwareness = false;
        }
    }

    if((strVaultAwareness != null) && !"null".equalsIgnoreCase(strVaultAwareness)) {
        if(strVaultAwareness.equalsIgnoreCase("true")) {
            bVaultAwareness = true;
        }else if(strVaultAwareness.equalsIgnoreCase("false")) {
            bVaultAwareness = false;
        }
    }

    if((strShowVault != null) && !"null".equalsIgnoreCase(strShowVault)) {
        if(strShowVault.equalsIgnoreCase("true")) {
            bShowVault = true;
        }else if(strShowVault.equalsIgnoreCase("false")) {
            bShowVault = false;
        }
    }

    // getting the default for the user in case of vault awareness setting turned on
    String strUserVault = null;
    String strUserVaultDisplay=null;

    if (!bVaultAwareness) {
        Person person = Person.getPerson(context);
        strUserVault =  person.getVaultName(context);
        strUserVaultDisplay = i18nNow.getI18NVaultNames(context,strUserVault,acceptLanguage);
    }

    if (bShowVault) {
        Person person = Person.getPerson(context);
        strUserVault =  person.getVaultName(context);
        strUserVaultDisplay = i18nNow.getI18NVaultNames(context,strUserVault,acceptLanguage);
    }

%>
