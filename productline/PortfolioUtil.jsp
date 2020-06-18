<%--
  PortfolioUtil.jsp

  Performs the action that creates an incident.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/PortfolioUtil.jsp 1.8.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.productline.Model"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.Portfolio"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.productline.CandidateProductHolder"%>
<%@page import = "matrix.db.BusinessObject"%>
<%@page import = "matrix.db.Context"%>
<%@page import = "com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import = "com.matrixone.apps.domain.util.DecoratedOid"%>
<%@page import = "com.matrixone.apps.common.util.FormBean"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.productline.Product"%>



<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
    boolean bFlag=false;
    try
    {

        String strMode = emxGetParameter(request,"mode");
        

        if(strMode.equalsIgnoreCase("Form"))
        {
            try
            {
%>
                <%@include file = "PrimaryImageInclude.inc"%>
<%
            }catch(Exception e){
                session.putValue("error.message", e.getMessage());
            }
        }


        if ((strMode.equalsIgnoreCase("create")))
        {
        	ENOCsrfGuard.validateRequest(context, session, request,response);
            //Instantiating the FormBean
            com.matrixone.apps.common.util.FormBean formBean=new com.matrixone.apps.common.util.FormBean();

            //Processing the form using FormBean.processForm
            formBean.processForm(session,request);

            //Instantiating the Portfolio bean
            Portfolio portfolioBean = (Portfolio) DomainObject.newInstance(context,ProductLineConstants.TYPE_PORTFOLIO,"ProductLine");
            String strNewObjId = null;
            //Calling the create Method of Portfolio.java
            strNewObjId = portfolioBean.create(context,formBean);
            String strCommandSource = emxGetParameter(request, "txtCommandSource");
            String strTreeID        = emxGetParameter(request, "txtTreeId");

            //to refresh the Portfolio Create Dialog page

            if (strCommandSource!= null && strCommandSource.equalsIgnoreCase("action"))
            {

                     %>
                     <!--Javascript for opening the tree with the object Id of the object that has been created-->
                     <script language="javascript" type="text/javaScript">
                     <!-- hide JavaScript from non-JavaScript browsers -->
                     //<![CDATA[
                     //Modified by Enovia MatrixOne for Bug#301885 on 6 April,2005
                     var strURL    = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&treeMenu=type_Portfolio&DefaultCategory=PLCPortfolioContentTreeCategory";
                     strURL        = strURL  + "&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeID)%>";
                     var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                     contentFrameObj.document.location.href= strURL;
                     var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
                     topFrameObj.window.focus();
                     parent.window.closeWindow();
                     //]]>
                     </script>
                     <%
            }else{
                 if (strTreeID == null || "".equals(strTreeID) || "null".equalsIgnoreCase(strTreeID))
                 {
                     %>
                         <script language="javascript" type="text/javaScript">
                           <!-- hide JavaScript from non-JavaScript browsers -->
                           //<![CDATA[
                                     //Modified by Enovia MatrixOne for Bug#301885 on 6 April,2005
                                     var strURL    ="../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&treeMenu=type_Portfolio&DefaultCategory=PLCPortfolioContentTreeCategory";
                                     strURL        =strURL + "&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeID)%>";
                                     var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                                     contentFrameObj.document.location.href= strURL;
                                     //var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
                                     //topFrameObj.window.focus();
                                     parent.window.closeWindow();
                           //]]>
                         </script>

                     <%
                 }else{ 
                     %>

                         <script language="javascript" type="text/javaScript">
                           <!-- hide JavaScript from non-JavaScript browsers -->
                           //<![CDATA[
                                     var strURL    = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>";
                                     strURL        =strURL + "&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeID)%>";
                                     var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                                     contentFrameObj.document.location.href= strURL;
                                     var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
                                     topFrameObj.window.focus();
                                     parent.window.closeWindow();
                           //]]>
                         </script>
                     <%
                }
             }
        }

        if (strMode.equalsIgnoreCase("delete"))
        {
        	ENOCsrfGuard.validateRequest(context, session, request,response);
            //Instantiating ProductLineCommon.java
            ProductLineCommon productlinecommonBean = new ProductLineCommon();

            //extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds=emxGetParameterValues(request,"emxTableRowId");

            
            StringList strObjectIdList = new StringList();
            String tempRelID = "";
            String strObjectID = "";
            StringTokenizer strTokenizer = null;
            
            for(int i=0;i<arrTableRowIds.length;i++)
            {
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                if(arrTableRowIds[i].indexOf("|") > 0){
                      tempRelID = strTokenizer.nextToken();
                      strObjectID = strTokenizer.nextToken() ;                                 
                      strObjectIdList.add(strObjectID);
                  }
                  else{
                      strObjectID = strTokenizer.nextToken() ;
                      strObjectIdList.add(strObjectID);                           
                  }
            }
            String strSelectedModels = "";
            String[] arrObjectIds= new String[strObjectIdList.size()];
            
            for(int i=0; i<strObjectIdList.size();i++){
            	arrObjectIds[i] = (String)strObjectIdList.get(i);
            }
            boolean bDelete=productlinecommonBean.deleteObjects(context,arrObjectIds,false);
            %>
             <script language="javascript" type="text/javaScript">
               //<![CDATA[
                refreshTablePage();
                //]]>
               </script>
            <%
        }
        if (strMode.equalsIgnoreCase("disconnect"))
        {
        	ENOCsrfGuard.validateRequest(context, session, request,response);
            //Instantiating ProductLineCommon.java
            ProductLineCommon productlinecommonBean = new ProductLineCommon();

            ///extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");

            //extracts Object id of the Objects to be disconnected.
            Map relIdMap = ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);

            
            //Obtaining the relationship ids from the Map returned by the previous step
            String[] arrObjectIds = (String[]) relIdMap.get("ObjId");
            String[] arrRelIds    = (String[]) relIdMap.get("RelId");

            //returns true in case of successful disconnect.
            boolean bRemove=false;

            //Calling the removeObjects() method of ProductLineCommon.java
            bRemove = productlinecommonBean.removeObjects(context,arrRelIds);
            %>
            <script language="javascript" type="text/javaScript">
                <!-- hide JavaScript from non-JavaScript browsers -->
                //<![CDATA[
            <%
                //For loop for refreshing the tree
                for(int i=0;i<arrObjectIds.length;i++)
                {
            %>
                    var tree = getTopWindow().trees['emxUIDetailsTree'];
                    tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
            <%
                }
            %>

                refreshTreeDetailsPage();
                //]]>
            </script>
<%      }

        else if (strMode.equalsIgnoreCase("DisconnectContent"))
        {
        	ENOCsrfGuard.validateRequest(context, session, request,response);
            Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");

            //get the table row ids of the test case objects selected
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            //get the relationship ids of the table row ids passed
            Map relIdMap=ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
            String[] arrRelIds = (String[]) relIdMap.get("RelId");
            String[] strObjectIds = (String[]) relIdMap.get("ObjId");

            //Call the removeObjects method to remove the selected object
            bFlag = productBean.removeObjects(context,arrRelIds);
%>
           <script language="javascript" type="text/javaScript">
               //<![CDATA[
               refreshTreeDetailsPage();
               //releasing mouse events
               //]]>
           </script>
<%
        }
        else 
        if(strMode.equalsIgnoreCase("AddToPortfolioPreProcess"))
        {
            ///extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");
            String strParentOID = emxGetParameter(request,"parentOID");
            String strObjectId = emxGetParameter(request,"objectId");
            
            StringList strObjectIdList = new StringList();
            String tempRelID = "";
            String strObjectID = "";
            StringTokenizer strTokenizer = null;
            
            for(int i=0;i<arrTableRowIds.length;i++)
            {
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                if(arrTableRowIds[i].indexOf("|") > 0){
                      tempRelID = strTokenizer.nextToken();
                      strObjectID = strTokenizer.nextToken() ;                                 
                      strObjectIdList.add(strObjectID);
                  }
                  else{
                      strObjectID = strTokenizer.nextToken() ;
                      strObjectIdList.add(strObjectID);                           
                  }
            }
            String strSelectedModels = "";
            for(int i=0; i<strObjectIdList.size();i++){
                if(i==0){
                	strSelectedModels = (String)strObjectIdList.get(i);
                }else{
                	strSelectedModels = strSelectedModels + "," + (String)strObjectIdList.get(i);
                }
            }
          %>
               <script language="javascript" type="text/javaScript">
               var submitURL = "../common/emxFullSearch.jsp?relName=relationship_Portfolio&field=TYPES=type_Portfolio&table=PLCSearchPortfoliosList&selection=multiple&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId=<%=XSSUtil.encodeForURL(context,strParentOID)%>&submitURL=../productline/AddToPortfolioProcess.jsp?contentId=<%=XSSUtil.encodeForURL(context,strSelectedModels)%>&mode=AddToPortfolio&srcDestRelName=relationship_Portfolio&isTo=false";
               showModalDialog(submitURL,575,575,"true","Large");
               </script>
         <%
        }

        else if(strMode.equalsIgnoreCase("AddToPortfolioPreProcessFromDerivation"))
        {
            ///extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");
            String strParentOID = emxGetParameter(request,"parentOID");
            String strObjectId = emxGetParameter(request,"objectId");
            
            StringList strObjectIdList = new StringList();
            String tempRelID = "";
            String strObjectID = "";
            StringTokenizer strTokenizer = null;
            
            for(int i=0;i<arrTableRowIds.length;i++)
            {
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                if(arrTableRowIds[i].indexOf("|") > 0){
                      tempRelID = strTokenizer.nextToken();
                      strObjectID = strTokenizer.nextToken() ;                                 
                      strObjectIdList.add(strObjectID);
                  }
                  else{
                      strObjectID = strTokenizer.nextToken() ;
                      strObjectIdList.add(strObjectID);                           
                  }
            }
            String strSelectedModels = "";
            for(int i=0; i<strObjectIdList.size();i++){
                if(i==0){
                    strSelectedModels = (String)strObjectIdList.get(i);
                }else{
                    strSelectedModels = strSelectedModels + "|" + (String)strObjectIdList.get(i);
                }
            }
          %>
               <script language="javascript" type="text/javaScript">
               var submitURL = "../common/emxFullSearch.jsp?relName=relationship_Portfolio&field=TYPES=type_Portfolio&table=PLCSearchPortfoliosList&selection=single&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId=<%=XSSUtil.encodeForURL(context,strParentOID)%>&submitURL=../productline/AddToPortfolioProcess.jsp?contentId=<%=XSSUtil.encodeForURL(context,strSelectedModels)%>&mode=AddToPortfolio&srcDestRelName=relationship_Portfolio&isTo=false";
               showModalDialog(submitURL,575,575,"true","Large");
               </script>
          <%
        }

    }
  
    catch (Exception e)
    {
        bFlag=true;
        String strAlertString = "emxProduct.Alert." + e.getMessage();
        String i18nErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);
        if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
        {
            session.putValue("error.message", e.getMessage());
        }else
        {
            session.putValue("error.message", i18nErrorMessage);
        }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    if (bFlag)
    {
%>
    <script language="javascript" type="text/javaScript">
    var p = findFrame(parent, 'pagecontent');
    p.clicked = false;   
    parent.turnOffProgress();

          history.back();
    </script>
<%
    }
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
