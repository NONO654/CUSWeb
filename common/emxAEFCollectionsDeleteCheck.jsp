<%--  emxAEFCollectionDeleteCheck.jsp  -   Collections Delete Process page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"emxTableRowId");
  StringBuffer contentURL = new StringBuffer("emxAEFCollectionsDeleteFS.jsp");
	
  
  boolean bflag = false;
  String strSystemCollectionName =  EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");

  
  // ----------------- Do Not Edit Above ------------------------------
  
  /* 
  *	 This jsp page validates whether the selected collection for deleted should contains system generated    *  collection. If it contains
  *  then it displays an alert message says that system generated collection cannot be deleted else it will  *  go thro delete process.
  */

   String strSelectedCollections[] = emxGetParameterValues(request, "emxTableRowId");
   String strCharSet = Framework.getCharacterEncoding(request);
   StringBuffer strbufCollections = new StringBuffer(80);
   String strTempFlag = "";
   if(strSelectedCollections!=null) {
    for (int iIndex = 0; iIndex < strSelectedCollections.length ; iIndex++)
    {
        StringTokenizer strTokenizer = new StringTokenizer(strSelectedCollections[iIndex] , "|");
        String strCollectionId = strTokenizer.nextToken() ;
        String strCollectionName = SetUtil.getCollectionName(context, strCollectionId);
        if(!strCollectionName.equals(strSystemCollectionName))
        {
			 strbufCollections.append(XSSUtil.encodeForURL(context, strCollectionId));
             strbufCollections.append("|");
        }
        else
        {
            bflag = true;
            break;
        }
    }
   }

  if(bflag) 
  {
      %>
      <script language="javascript">
      alert("<emxUtil:i18n localize="i18nId">emxFramework.Collections.SystemCollectionCannotDelete</emxUtil:i18n>");
      </script>
      <%
  }
  else
  {
	   String strTemp = (strbufCollections.toString()).substring(0, strbufCollections.length() - 1);
	   strbufCollections = new StringBuffer(50);
	   strbufCollections.append(strTemp);
	   
	   contentURL.append("?jsTreeID=");
	   contentURL.append(XSSUtil.encodeForURL(context, jsTreeID));
	   contentURL.append("&suiteKey=");
	   contentURL.append(XSSUtil.encodeForURL(context, suiteKey));
	   contentURL.append("&strCollections=");
	   contentURL.append(strbufCollections.toString());
	   contentURL.append("&objectId=");
	   contentURL.append(XSSUtil.encodeForURL(context, objectId));
   %>
            <html>
            <head>
                <title></title>
                <script language="JavaScript">
                  function launchModalWin()
                  {
					//XSSOK
                    emxShowModalDialog("<%=contentURL%>",550,550);
                  }
                </script>
            </head>
            <body onload="launchModalWin()">
            </body>
            </html>
            <%
      
  
  }

%>


