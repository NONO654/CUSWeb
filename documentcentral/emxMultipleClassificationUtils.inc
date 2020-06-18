<%--  emxMultipleClassificationUtils.inc

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

    static const char RCSID[] = "$Id: emxMultipleClassificationUtils.inc.rca 1.2.3.2 Wed Oct 22 16:02:12 2008 przemek Experimental przemek $"
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
<%@ include file = "../emxI18NMethods.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%!
    // Application Directory and Property File Alias for the DC App
    public static String appDirectory  = null;


       /**
        * call this method to parse the ugly system error messages and
        * generate a user friendly message.It will first find the last occurance of Error:
        * then, returns the string that is after the next occurance of :
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
        * @return  error message after Error:
        * @throws Exception
        */
        public String getErrorMessage(String msgString) throws Exception
       {
            int index = msgString.lastIndexOf("Error:");

            String retMsg = "";

            if(index == -1)
            {
                retMsg = msgString;
            }
            else
            {
                msgString = msgString.substring(index+7);
                index = msgString.indexOf(":");
                if(index == -1)
                {
                       retMsg = msgString;
                }
                else
                {
                      retMsg = msgString.substring(index+1);
                }
            }
            retMsg = retMsg.trim();

            return retMsg;
       }
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
    String DateFrm   = "";
// Setting AppDirectory

    if (appDirectory == null)
    {
        //appDirectory =  (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteMultipleClassification.Directory");
        appDirectory =  (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteLibraryCentral.Directory");
    }

    String sLanguage = request.getHeader("Accept-Language");


%>

<%-- Start Internationalization --%>
<%-- XSSOK --%>
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<%=sLanguage%>'/>



