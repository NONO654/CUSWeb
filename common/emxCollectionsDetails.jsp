<%--  emxCollectionsDetails.jsp   - Detail page for Collections.
   Copyright (c) 2005-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsDetails.jsp.rca 1.14 Wed Oct 22 15:47:45 2008 przemek Experimental przemek $
--%>
   
<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "emxCompCommonUtilAppInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@ page import="com.matrixone.apps.domain.util.MapList,
                 com.matrixone.apps.domain.util.FrameworkUtil,
                 com.matrixone.apps.domain.util.SetUtil,
                 com.matrixone.apps.framework.taglib.*,
                 java.util.*" %>

    <%
    
              String languageStr    = request.getHeader("Accept-Language");
              String sCharSet       = Framework.getCharacterEncoding(request);
              String jsTreeID       = emxGetParameter(request,"jsTreeID");
              String strSetId       = emxGetParameter(request, "relId");
              String objectName     = SetUtil.getCollectionName(context, strSetId);
              
              /* Validating if the objectName is Clipboard Collections. If yes then change the objectName label to System Generated collection Name*/
              String strobjectNameLabel                 = objectName; 
              String strSystemGeneratedCollectionName   = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
              if(objectName.equals(strSystemGeneratedCollectionName))
              {
                    strobjectNameLabel = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel");
              }
    %>
 
        
<script language="Javascript" >
        function editCollection()
        {
            
            winHeight = Math.round(screen.height*75/100);
            winWidth = Math.round(screen.width*50/100); 
            emxShowModalDialog("emxCollectionsEditDialogFS.jsp?objectName=<%=XSSUtil.encodeForURL(context, objectName)%>&relId=<%=XSSUtil.encodeForURL(context, strSetId)%>", winWidth, winHeight );
        }

        </script>


        <%@include file = "../emxUICommonHeaderEndInclude.inc" %>

        <%
                
                long collectionCnt = SetUtil.getCount(context, objectName);    
                String output = MqlUtil.mqlCommand(context, "list property on set $1 ;",objectName);

                int endNameIndex = output.indexOf("value");
                String  descriptionName ="";
                
                if(endNameIndex > -1)
                    descriptionName = output.substring(endNameIndex+6);

                if(descriptionName.equalsIgnoreCase("null")||  descriptionName==null)
                    descriptionName="";
        %>

        <table border="0" width="100%" cellpadding="5" cellspacing="2">
                <tr>
                        <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></td>
                        <!-- To Display the Label Name -->
                        <td class="field"><xss:encodeForHTML><%=strobjectNameLabel%></xss:encodeForHTML>&nbsp;</td>
                </tr>

                <tr>
                        <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Description</emxUtil:i18n></td>
                        <td class="field"><xss:encodeForHTML><%=descriptionName%></xss:encodeForHTML>&nbsp;</td>
                </tr>

              <tr>
                    <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Collections.ItemCount</emxUtil:i18n></td>
                    <td class="field"><%=collectionCnt%>&nbsp;</td>
            </tr>
      </table>
      <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
