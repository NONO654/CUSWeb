<%-- emxEngineeringChangeImpactAnalysisUtil.jsp 
  
  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
  
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
  
  static const char RCSID[] = $Id: emxEngineeringChangeImpactAnalysisUtil.jsp.rca 1.6 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $  
 --%>


<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import  = "com.matrixone.apps.common.ImpactAnalysis"%>
<%@page import  = "com.matrixone.apps.common.EngineeringChange"%>
<%@page import  = "com.matrixone.apps.domain.*"%>

<html>
  <!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
  <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  
<%

    String strMode = null;
    boolean bIsError = false;
    try {

        //Instantiating the Impact Analysis bean
        ImpactAnalysis iaBean = (ImpactAnalysis)DomainObject.newInstance(context,DomainConstants.TYPE_IMPACT_ANALYSIS);

        //Instantiating the FormBean
        com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();

        //Processing the form using FormBean.processForm
        formBean.processForm(session,request);

        //Getting the mode from the Command
        strMode = emxGetParameter(request,"mode");

        //gets tree Id from Dialog page
        String strTreeId = emxGetParameter(request,"jsTreeID");
        

        //when Done button is clicked on Create Dialog page
        if (strMode.equalsIgnoreCase("create") ) {
            String strImpactOId     = null;
            String strContextType   = DomainConstants.TYPE_IMPACT_ANALYSIS;

            //Calling the createImpactAnalysis Method of ImpactAnalysis.java

            strImpactOId = iaBean.create(context,formBean,strContextType);
            //STart Changes for teh bug IR-079593V6R2012WIM

            if (strTreeId == null || "".equals(strTreeId) || "null".equalsIgnoreCase(strTreeId)) {
 %>
                <script language="javascript" type="text/javaScript">
                  //<![CDATA[
               
                   var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                   contentFrameObj.document.location.href ="../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, strImpactOId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context, strTreeId)%>";
                  //releasing mouse events after creation of Impact Analysis
                  
                  window.closeWindow();
                 
                  
                  //]]>
                </script>

 <%
            } else {
%>
                <script language="javascript" type="text/javaScript">
                  //<![CDATA[
                  var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                  contentFrameObj.document.location.href="../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, strImpactOId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context, strTreeId)%>";

                  //releasing mouse events after creation of Impact Analysis
                  window.closeWindow();
                 
                 
                  //]]>
                </script>
<%
          }//end IR-079593V6R2012WIM

        }//if Delete Selected Command link on List page is pressed
        else if(strMode.equalsIgnoreCase("delete")) {
            //getting table row ids from the list page
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            String strObjectIds[] = null;
            //getting object ids for the corresponding row ids
            strObjectIds = EngineeringChange.getObjectIds(strTableRowIds);

            boolean bIsDeleted = false;
            //deleting objects from database by calling common bean
            bIsDeleted = iaBean.deleteObjects(context,strObjectIds,true);
            /* for deleting an object which is in a parent context,
             * delete the object from list page as well as from tree category
             */
            if (!DomainConstants.EMPTY_STRING.equals(strTreeId)) {
%>
                <script language="javascript" type="text/javaScript">
<%
                for(int i=0;i<strObjectIds.length;i++) {
 %>
                      //<![CDATA[
                      var tree = getTopWindow().trees['emxUIDetailsTree'];
                      tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strObjectIds[i])%>");
                      //]]>
<%
                }
%>
                  //<![CDATA[
                  /*refreshTreeDetailsPage();*/
				  var treeDetailsFrame = findFrame (getTopWindow(), "detailsDisplay");
				  if (treeDetailsFrame){
				      treeDetailsFrame.location.href = treeDetailsFrame.location.href;
				   }
                   var contTree = getTopWindow().objDetailsTree;
      			   var structTree = getTopWindow().objStructureTree;
      			   if(structTree!=null) {
            			structTree.refresh();
          		   }
          		   if(contTree!=null) {
            			contTree.refresh();
          		   }
                  //releasing mouse events after deletion of Impact Analysis
                  //]]>
                </script>
<%

            }//for deleting an object from MyDesk list page
            else {
 %>
                <script language="javascript" type="text/javaScript">
                  //<![CDATA[
                  refreshContentPage();
                  //releasing mouse events after deletion of Impact Analysis
                  //]]>
                </script>
 <%    }

        } else if (strMode.equalsIgnoreCase("disconnect")) {
            //if Remove Selected Command link on List page is pressed
            //storing table row ids in a String array
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            Map mapObjIdRelId       = ImpactAnalysis.getObjectIdsRelIds(strTableRowIds);

            //storing Object ids in a String array
            String[] arrObjIds = (String[])mapObjIdRelId.get("ObjId");
            //storing relationship ids in a String array
            String[] arrRelIds = (String[])mapObjIdRelId.get("RelId");

            //Retrieves context Object Id
            String strParentId = emxGetParameter(request, "objectId");

            boolean bIsRemoved = iaBean.remove(context,arrRelIds,strParentId);

            /* for disconnecting an object which is in a parent context,
             * remove the object from list page as well as from tree category
             */
            if (!DomainConstants.EMPTY_STRING.equals(strTreeId)) {
%>
                <script language="javascript" type="text/javaScript">
<%
                for(int i=0;i<arrObjIds.length;i++) {
%>
                     //<![CDATA[
                     var tree = getTopWindow().trees['emxUIDetailsTree'];
                     tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, arrObjIds[i])%>");
                     //]]>
<%
                }
%>
                  //<![CDATA[
                  refreshTreeDetailsPage();
                  //]]>
             </script>
<%
              } else {
            //for removing an object from MyDesk list page
%>
                <script language="javascript" type="text/javaScript">
                  //<![CDATA[
                  refreshContentPage();
                  //]]>
                </script>
 
 <%
            }
        }

    }
    catch(Exception ex)
    {
        bIsError=true;
        session.putValue("error.message", ex.toString());
    }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript" type="text/javaScript">
    <%
  if (bIsError==true && (strMode.equalsIgnoreCase("create")) ) {
    %>
    var pc = findFrame(parent, 'pagecontent');
    pc.clicked = false;         
    parent.turnOffProgress();
    history.back();
    <%
  }
    %>
</script>
</html>
