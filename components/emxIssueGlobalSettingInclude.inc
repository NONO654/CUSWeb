<%  /******************************************************************************************************************
  * Description       :
   *
   * This jsp contains the business logic.
   * Againts this module the property file is searched to obtain the
   * PolicyAwareness and VaultAwareness values
   *
*/
    //The variables that will be accessed in the jsp that will include this jsp.
    //these variables are initialized by default values
    //the PolicyAwareness and ValutAwareness variables will be available in String as well as
    //boolean format
%>  <%@page import= "com.matrixone.apps.domain.util.i18nNow,
    				 com.matrixone.apps.common.Person,
    				 com.matrixone.apps.domain.util.FrameworkProperties"%>
<%
    boolean bPolicyAwareness = false;

    boolean bVaultAwareness = false;
    boolean bShowVault = false;
    String strPolicyAwareness = "";

    String strVaultAwareness = "";
    // for checking the value of ShowVault setting in the emxComponents.properties
    String strShowVault = "";

    //To get the Property entries for Policy Awareness and Vault Awareness.

    String strProperty = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.PropertyFileAlias");

    strVaultAwareness = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.VaultAwareness");
    strPolicyAwareness = (String)FrameworkProperties.getProperty(context,"emxComponents.AllowChangePolicy");
    // fetching the value of ShowVault setting in the emxComponents.properties
    strShowVault = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.ShowVault");

    if((strPolicyAwareness != null) && !"null".equalsIgnoreCase(strPolicyAwareness))
    {
        if(strPolicyAwareness.equalsIgnoreCase("true")){
          bPolicyAwareness = true;
        }else if(strPolicyAwareness.equalsIgnoreCase("false")){
          bPolicyAwareness = false;
        }
    }



    if((strVaultAwareness != null) && !"null".equalsIgnoreCase(strVaultAwareness))
    {
        if(strVaultAwareness.equalsIgnoreCase("true")){
              bVaultAwareness = true;
        }else if(strVaultAwareness.equalsIgnoreCase("false")){
              bVaultAwareness = false;
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

    if (!bVaultAwareness)
    {
      Person person = Person.getPerson(context);
      strUserVault =  person.getVaultName(context);
      strUserVaultDisplay = i18nNow.getI18NVaultNames(context,strUserVault,acceptLanguage);
    }

    if (bShowVault)
        {
          Person person = Person.getPerson(context);
          strUserVault =  person.getVaultName(context);
          strUserVaultDisplay = i18nNow.getI18NVaultNames(context,strUserVault,acceptLanguage);
    }

%>
