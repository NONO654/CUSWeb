<%--  emxLibraryCentralUtils.inc

    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any actual or
    intended publication of such program

    Description: Common Util Include JSP page for DC Application

                 Has utility methods for
                 1. getting formatted System error message
                 2. for checking access
                 3. for reading property values from emxLibraryCentral.property
                 4. for getting imageName for a BusinessType
                 5. for getting Vaults for a context and Type
                 6. for getting context user Info
                 7. for getting Display Name for a Person Name
                 8. browser type, IE or Netscape.  Variables in Java and JavaScript.

                 Has common imports, common variables like appDirectory,
                 propertyFileAlias, acceptLanguage, and dateFormat
    Parameters :

    Author     :
    Date       :
    History    :

    static const char RCSID[] = "$Id: emxLibraryCentralUtils.inc.rca 1.8 Wed Oct 22 16:02:19 2008 przemek Experimental przemek $"
--%>

<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.URLEncoder,
                   java.util.*,
                   java.util.Vector,
                   java.text.*" errorPage="../common/emxNavigatorErrorPage.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.Meeting,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Part,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault"%>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@ page import = "com.matrixone.apps.document.*"%>
<%@ page import = "com.matrixone.apps.library.PartLibrary"%>
<%@ page import = "com.matrixone.apps.library.PartFamily"%>
<%@ page import = "com.matrixone.apps.library.GeneralLibrary"%>
<%@ page import = "com.matrixone.apps.library.GeneralClass"%>
<%@ page import = "com.matrixone.apps.library.Classification"%>
<%@ page import = "com.matrixone.apps.library.Libraries"%>
<%@ page import = "com.matrixone.apps.library.LibraryCentralConstants"%>
<%@ page import = "com.matrixone.apps.library.LibraryCentralCommon"%>
<%@ page import = "com.matrixone.apps.document.util.*"%>
<%@ page import = "com.matrixone.apps.classification.*"%>

<%@ include file = "../emxTagLibInclude.inc"%>

<%!
    // Application Directory and Property File Alias for the DC App
    public static String appDirectory  = null;


    /**
     * call this method to parse the ugly system error messages and
     * generate a user friendly message.
     * e.g. for a system error like:
     * Error: #1900068: print business object failed
     * Error: #1500029: No business object 'Error getting object name * *' found
     * System Error: #1500178: business type '0' does not exist
     *
     * this method will return following message:
     * business type '0' does not exist
     *
     * the return values are JavaScript Friendly.
     *
     * @param msgString
     * @return formatted error message
     * @throws Exception
     */
    public String getSystemErrorMessage(String msgString) throws Exception
    {
        /*
        *  Author     : amitv
        *  Date       : 11/08/02
        *  Notes      :
        *  History    :
        *
        */

        StringTokenizer st = new StringTokenizer(msgString.trim(), "\n");

        String msg = "";

        while(st.hasMoreTokens())
        {
            // only last line of error is relevant to us

            msg = st.nextToken();
        }
        int index = msg.lastIndexOf(":");

        String retMsg = "";

        if(index == -1)
        {
            retMsg = msg;
        }
        else
        {
            retMsg = msg.substring(index+1);
        }
        retMsg = retMsg.trim();

        // now format message for escape characters
        // e.g. replace a " by \", :::: \ by \\ :::: etc ...

        retMsg = formatMessage(retMsg);

        return retMsg;
    }

    /**
     * Formats The error Message
     *
     * @param msg : Message to be formatted
     * @return formatted Message
     */
    public String formatMessage(String msg)
    {

        StringBuffer sbuf = new StringBuffer();

        char [] cArray = msg.toCharArray();

        for(int i=0; i<cArray.length; i++)
        {
            String strChar = String.valueOf( cArray[i] );

            if( "\'".equals( strChar ) || "\\".equals( strChar ) || "\"".equals( strChar )  ) {
                sbuf.append( "\\" );
                sbuf.append( strChar );
            } else {
                sbuf.append( strChar );
            }
        }

        return sbuf.toString();
    }

    /**
     * This Utility function return the Icon Name for type by
     * reading from properties file
     *
     * @param application
     * @param session
     * @param context
     * @param typeName the BusinessType
     * @return the iconImage name for the type passed In
     * @throws Exception If Unsuccessfull
     */
     // this is only ever used in ENOVBMAccelerator/CNext/webroot/documentcentral/VBM_emxLibraryCentralCreateClassFindSummary.jsp...
    public String getIconNameforType(ServletContext application,
                                     HttpSession session,
                                     Context context,
                                     String typeName) throws Exception
    {

        // Getting the ObjectIcon name from the type from Property file name
        //
        String objectIcon ="";
        String alias = FrameworkUtil.getAliasForAdmin(context,"type",
                typeName,true);

        /*String objectIcon  = getDocumentCentralProperty(application,
                session, alias,"SmallIcon");*/
        try{
          objectIcon  = EnoviaResourceBundle.getProperty(context,alias + ".SmallIcon");
        }catch(Exception e)
        {
        }

        // Setting default Icon if no icon found for type in Properties file
        // for pariculat type
        //
        if (objectIcon==null|| objectIcon.equals("null")||objectIcon.length()<1)
        {
            /*objectIcon = getDocumentCentralProperty(application,
                    session, "type_Default","SmallIcon");*/
            objectIcon  = EnoviaResourceBundle.getProperty(context,"type_Default.SmallIcon");

        }

        return objectIcon;
    }

    /**
     * This Utility function return the Cached System Vaults
     *
     * @param context
     * @param session
     * @param type
     * @return Vaults Array
     * @throws Exception if unsuccessfull
     */
    public String[] getDCVaults(Context context,
                                HttpSession session,
                                String type) throws Exception
    {


        Map typeVaultMap = (HashMap) session.getAttribute("DCVaults");
        if(typeVaultMap == null)
        {
            typeVaultMap = new HashMap();
        }

        String [] vaults = (String []) typeVaultMap.get(type);
        if (vaults == null)
        {
            vaults = LibraryCentralCommon.getVaults(context, type);
            typeVaultMap.put(type, vaults);
            session.setAttribute("DCVaults", typeVaultMap);
        }

        return vaults;
    }

    // Constants for getting Required User Details
    //
    public static final int CTXT_USER_NAME         = 0; // User Name
    public static final int CTXT_USER_FIRST_NAME   = 1; // User First Name
    public static final int CTXT_USER_LAST_NAME    = 2; // User Last Name
    public static final int CTXT_USER_DISPLAY_NAME = 3; // Display Name viz.,

    /**
     *  This Utility function returns the cached Logged-In User's Details
     *
     * @param context
     * @param userInfo : can take any of above constants
     * @param session
     * @return String  the required User Info
     * @throws Exception if unsuccessfull
     */
    public String getContextUserInfo(Context context,
                                     HttpSession session,
                                     int userInfo) throws Exception

    {

        String [] userInfoArray = (String []) session.getAttribute (
                                                           "DCContextUserInfo");
        String userDetail = null;

        // if userInfoArray not found in session
        // populate the array and put it back in session
        //
        if(userInfoArray == null)
        {
            userInfoArray = new String[4];

            Person person = new Person();
            person = person.getPerson(context);

            StringList selects = new StringList();
            selects.add(person.SELECT_NAME);
            selects.add(person.SELECT_FIRST_NAME);
            selects.add(person.SELECT_LAST_NAME);

            Map personInfo = person.getInfo(context, selects);

            userInfoArray[0] = (String) personInfo.get(person.SELECT_NAME);            userInfoArray[1] = (String) personInfo.get(person.SELECT_FIRST_NAME);
            userInfoArray[2] = (String) personInfo.get(person.SELECT_LAST_NAME);
            userInfoArray[3] =  getFormattedPersonName (
                    userInfoArray[1], userInfoArray[2], userInfoArray[0]);

            session.setAttribute("DCContextUserInfo", userInfoArray);
        }

        switch(userInfo)
        {
            case CTXT_USER_NAME :
                userDetail = userInfoArray[CTXT_USER_NAME];
                break;

            case CTXT_USER_FIRST_NAME :
                userDetail = userInfoArray[CTXT_USER_FIRST_NAME];
                break;

            case CTXT_USER_LAST_NAME :
                userDetail = userInfoArray[CTXT_USER_LAST_NAME];
                break;

            case CTXT_USER_DISPLAY_NAME :
                userDetail = userInfoArray[CTXT_USER_DISPLAY_NAME];
                break;
        }

        // For Webshphere, which shows null values as "null"
        //
        userDetail = ( userDetail != null )
                           ?
                userDetail : DomainConstants.EMPTY_STRING ;

        return userDetail;
    }

    /**
     * This function returns formatted person name, suitable for displaying.
     *
     * @param firstName
     * @param lastName
     * @param personName
     * @return User Name in the format : Last Name, First Name
     */
    public String getFormattedPersonName(String firstName,
                                         String lastName,
                                         String personName)
    {

        String displayName = DomainConstants.EMPTY_STRING;

        if(firstName == null || firstName.equals("null") ||
                                         (firstName.trim().equals("")))
        {
            firstName = DomainConstants.EMPTY_STRING;
        }

        if(lastName == null || lastName.equals("null") ||
                                          (lastName.trim().equals("")))
        {
            lastName = DomainConstants.EMPTY_STRING;
        }

        // if both first name and last name are empty
        // return personName.Also display
        // only the last Name if the first name is null or empty
        // and the vice-versa.

        if ( firstName.length() == 0 && lastName.length() == 0 )
        {
            displayName = personName;
        }
        else if( firstName.length() == 0 && lastName.length() != 0)
        {
            displayName = lastName;
        }
        else if( firstName.length() != 0 && lastName.length() == 0)
        {
            displayName = firstName;
        }
        else
        {
            displayName = lastName + ", " + firstName;
        }

        return displayName;
    }
   
    /**
     *
     * @param context, strType, strName
     * @return boolean
     * @throws no Exception
     * @author
     */
     // used in ENOVBMAccelerator/CNext/webroot/documentcentral/VBM_emxLibraryCentralLibraryCreateProcess.jsp & ENOVBMAccelerator/CNext/webroot/vbm/emxVBMBrandLibraryCreateProcess.jsp
    public boolean isObjectExists(Context context,
                                  String strType,
                                  String strName) throws Exception
    {

      // Check for object with Given Type and Name
      try
      {
        if (strName != null)
        {
          ContextUtil.pushContext(context);
          MapList resultMapList = DomainObject.findObjects(
                                            context,
                                            strType,
                                            strName,
                                            "*",
                                            "*",
                                            "*",
                                            "",
                                            false,
                                            null );
          ContextUtil.popContext(context);
          if(resultMapList != null && resultMapList.size() > 0)
          {
            return true;
          }
        }
      }
      catch (Exception e)
      {

      }
      return false;
    }


    /**
     * get Formated Row IDs
     *
     * @param emxRowid
     * @return StringList
     * @throws Exception
     */
    public StringList getTableRowIDs(String tableRowIdList[]) throws Exception
    {
        StringList slFormatedRowIds = new StringList();
        if (tableRowIdList != null && tableRowIdList.length > 0)
        {
            for (int ii = 0; ii < tableRowIdList.length; ii++)
            {
                String[] tokens = tableRowIdList[ii].trim().split("[|]");
                if (tokens.length > 1)
                {
                    slFormatedRowIds.add(tokens[1]);

                }
                else if (tokens.length == 1)
                {
                    slFormatedRowIds.add(tokens[0]);
                }
            }
        }
        return slFormatedRowIds;
    }
    
     /**
     * get Formated Row IDs
     *
     * @param emxRowid
     * @return String
     * @throws Exception
     */
    public String getTableRowIDsString(String tableRowIdList[]) throws Exception
    {
        StringBuffer sbFormatedRowIds   = new StringBuffer();
        String objectId                 = "";
        if (tableRowIdList != null && tableRowIdList.length > 0)
        {
            for (int ii = 0; ii < tableRowIdList.length; ii++)
            {
                String[] tokens = tableRowIdList[ii].trim().split("[|]");
                if (tokens.length > 1)
                {
                      objectId = tokens[1];
                }
                else if (tokens.length == 1)
                {
                     objectId = tokens[0];
                }
                sbFormatedRowIds.append(objectId);
                sbFormatedRowIds.append(",");
            }
        }
        String sFormatedRowIds = sbFormatedRowIds.toString();
        if(sFormatedRowIds.length() >0) {
            sFormatedRowIds= sFormatedRowIds.substring(0,sFormatedRowIds.length()-1);
        }
        return (sFormatedRowIds);  
    }
    
         /**
     * get Formated Row IDs
     *
     * @param emxRowid
     * @return String
     * @throws Exception
     */
    public String[] getTableRowIDsArray(String emxTableRowIds[]) throws Exception
    {
       StringList slObjectIds   = getTableRowIDs(emxTableRowIds);
       return (slObjectIds.size()>0?(String[]) slObjectIds.toArray(new String[slObjectIds.size()]):null);  
    }

%>

<%
    // Setting AppDirectory
    //
    if (appDirectory == null)
    {
        appDirectory =  (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteLibraryCentral.Directory");
    }

    // Language Encoding for Localization
    //
    String sLanguage = request.getHeader("Accept-Language");

    // TODO! Date format to be read from emxSystem.properties
    //
    //String DateFrm   = (new Integer(java.text.DateFormat.MEDIUM)).toString();
    String DateFrm   = "";
    // set Java variable with browser type.
    String  userAgent = request.getHeader("User-Agent");
    boolean isIE      = (userAgent != null && userAgent.indexOf("MSIE") != -1);


%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" >

  // set Java variable with browser type.

  // BROWSER DETECT
  var agt=navigator.userAgent.toLowerCase();

  // Note: On IE5, these return 4, so use is_ie5up to detect IE5.
  var is_major = parseInt(navigator.appVersionm,10);
  var is_minor = parseFloat(navigator.appVersion);

  var is_ie     = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
  var is_ie3    = (is_ie && (is_major < 4));
  var is_ie4    = (is_ie && (is_major == 4) && (agt.indexOf("msie 4")!=-1) );
  var is_ie4up  = (is_ie && (is_major >= 4));
  var is_ie5    = (is_ie && (is_major == 4) && (agt.indexOf("msie 5.0")!=-1) );
  var is_ie5_5  = (is_ie && (is_major == 4) && (agt.indexOf("msie 5.5") !=-1));
  var is_ie5up  = (is_ie && !is_ie3 && !is_ie4);
  var is_ie5_5up =(is_ie && !is_ie3 && !is_ie4 && !is_ie5);
  var is_ie6    = (is_ie && (is_major == 4) && (agt.indexOf("msie 6.")!=-1) );
  var is_ie6up  = (is_ie && !is_ie3 && !is_ie4 && !is_ie5 && !is_ie5_5);

</script>


<%-- Start Internationalization --%>
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<%=sLanguage%>'/>
