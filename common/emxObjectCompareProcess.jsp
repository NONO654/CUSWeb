<%-- emxObjectCompareProcess.jsp 
     Copyright (c) 1992-2018 Dassault Systemes.
     All Rights Reserved.
     This program contains proprietary and trade secret information of MatrixOne,Inc.
     Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program
     static const char RCSID[] = $Id: emxObjectCompareProcess.jsp.rca 1.7 Wed Oct 22 15:48:37 2008 przemek Experimental przemek $
--%>
 
<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
    try
    {

          String objectId[] = emxGetParameterValues(request,"emxTableRowId");
          StringBuffer contentURL = new StringBuffer("emxObjectCompareBaseObjectSelect.jsp");

          //For enforcing user to select atleast two objects for compare.
          if(objectId == null || objectId.length < 2 )
          {
%>
               <script language="javascript">
                alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ObjectCompare.SelectMinObjects</emxUtil:i18nScript>");
               </script>
<%
          }
          else
          {
             compare.setObjectIDS(context,objectId);
             compare.pivot=false;
%>

            <html>
            <head>
                <title></title>
                <script language="JavaScript">
                  function launchModalWin()
                  {
                    emxShowModalDialog('<%=XSSUtil.encodeURLwithParsing(context, contentURL.toString())%>',930,650);
                  }
                </script>
            </head>
            <body onload="launchModalWin()">
            </body>
            </html>
<%
          }
    } catch (Exception ex) 
         {
           if (ex.toString()!=null && ex.toString().length()>0) 
           {
              emxNavErrorObject.addMessage(ex.toString());
           }
         }
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
