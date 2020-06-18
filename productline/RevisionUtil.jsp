<%--
  RevisionUtil.jsp

  Performs the actions that creates a Feature.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>

<%--Page directives for imports --%>
<%@page import = "com.matrixone.apps.common.util.FormBean"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.util.Hashtable"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>


<%

  String strMode = "";
  String jsTreeID = "";
  String strObjectId = "";
  String strNewRevision ="";
  String strContextObjectId = "";
  boolean bIsError = false;

    //Get the mode called
    strMode = emxGetParameter(request, "mode");
    jsTreeID = emxGetParameter(request, "jsTreeID");
    strContextObjectId = emxGetParameter(request, "objectId");
    String[] arrObjectIds = null;
  try{


        ProductLineCommon prcCommonbean = new ProductLineCommon();

        if (strMode.equalsIgnoreCase("create"))
        {
            //instanciating form bean
            com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
            formBean.processForm(session,request);
            //Setting the latest Locale in context
            Locale Local = request.getLocale();
            context.setLocale(Local);
            //create Revision method returns the Id of the newly created Revision
            strNewRevision = prcCommonbean.createRevision(context,formBean);

 
        }else if(strMode!=null && strMode.equalsIgnoreCase("delete")){

            //Getting the table row ids of the selected objects from the request
            String TableRowId = emxGetParameter(request, "emxTableRowId");
            String[] arrTableRowId={TableRowId};
            //Instantiating ProductLineUtil bean
            ProductLineUtil utilBean = new ProductLineUtil();
            //Getting the object ids from the table row ids
            arrObjectIds = utilBean.getObjectIds(arrTableRowId);
            //Only one object Id is returned since only the latest revision can be deleted
            strObjectId = arrObjectIds[0];
            DomainObject dObj = new DomainObject(strObjectId);
            if(!strContextObjectId.equals(strObjectId)){

                    if(dObj.isLastRevision(context)){
                    //Calling the deleteObjects() method of ProductLineCommon.java
                    prcCommonbean.deleteRevision(context,strObjectId);

                    }else{
                        %>
                            <script language="javascript" type="text/javaScript">
                            alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.DeleteRevision</emxUtil:i18n>");
                            </script>
                        <%
                    }

                        %>
                         <script language="javascript" type="text/javaScript">
                         var tree = getTopWindow().trees['emxUIDetailsTree'];
                         tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>");
                         refreshTreeDetailsPage();
                         refreshTablePage();
                         </script>
                        <%

                }else{
                    %>
                        <script language="javascript" type="text/javaScript">
                        alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.Delete.ContextOfLastRevision</emxUtil:i18n>");
                        refreshTreeDetailsPage();
                        refreshTablePage();
                        </script>
                    <%
                }

        }else if(strMode!=null && strMode.equalsIgnoreCase("update")){

            //Instantiating ProductLineCommon.java
            ProductLineCommon commonBean = new ProductLineCommon();
            //Instantiating ProductLineUtil.java bean
            ProductLineUtil utilBean = new ProductLineUtil();
            //Getting the table row ids of the selected objects from the request
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            //Getting the Map of object ids and Rel Ids from the table row ids
            Map oIdrelIdMap = (Hashtable)utilBean.getObjectIdsRelIds(arrTableRowIds);
            arrObjectIds = (String[]) oIdrelIdMap.get("ObjId");
            /*Begin of Modify Mayukh,Enovia MatrixOne Bug# 299957, 3/7/2005*/
            //The context, object id and a Map containing relationship Ids, the object Ids  are passed to UpdateRevision Method.
			//Begin of modify by RashmiL_Joshi, Enovia MatrixOne for bug# 300600 Date: 3/23/2005
			boolean bLatest = commonBean.updateRevision(context,strContextObjectId,oIdrelIdMap);
			/*End of Modify Mayukh,Enovia MatrixOne Bug# 299957, 3/7/2005*/
			if (bLatest)
			{
			%>
                <script language="javascript" type="text/javaScript">
                        alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.UpdateLatestRevision</emxUtil:i18n>");
                </script>
            <%
			}else{
            %>
                <script language="javascript" type="text/javaScript">
                        alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.UpdateRevision</emxUtil:i18n>");
                </script>
            <%
			}
    	  //End of modify for bug# 300600 Date: 3/23/2005
        }

    if(strMode!=null && strMode.equalsIgnoreCase("create"))
     {
    	String strRevision = i18nStringNowUtil("emxProduct.Tree.Revisions",bundle,acceptLanguage);
        DomainObject domObj = new DomainObject(strNewRevision);
        String objName = domObj.getName(context);
        String objRevision = domObj.getRevision(context);
        String strLabel = "";
     // Check if the FTR is installed or not
        boolean isConfigurationInstall = FrameworkUtil.isSuiteRegistered(
                context, "appVersionVariantConfiguration", false, null,
                null);
        
        if(isConfigurationInstall){
        	HashMap paramMap = new HashMap();
        	paramMap.put("objectId", strNewRevision);
            HashMap mapArgs = new HashMap();
            mapArgs.put("paramMap",paramMap);

            String[] mapPacked = (String[]) JPO.packArgs(mapArgs);
            strLabel = (String)JPO.invoke(context, "LogicalFeature", null,
                    "getDisplayNameForNavigator", mapPacked, String.class);
        }
        else{
        	strLabel = objName+" "+objRevision;	
        }
        
        
        
        %>
        <script language="javascript" type="text/javaScript">
            var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
           //var tree = parent.window.getWindowOpener().parent.window.getTopWindow().objDetailsTree;

        //Next_genUi adoption
            //var node = tree.findNodeByName("<%=strRevision%>");
			//Finding the Context Object Id where the new Revision has to be inserted.
			//var objNode = tree.findNodeByObjectID("<%=strContextObjectId%>");

			//Setting the Node in the tree
			//tree.setSelectedNode();

			//Expanding the Node
			//objNode.expanded = true;

			//Setting the variable to the Node - 'Revisions' in the tree.
			//var revision = "<%=strRevision%>";

			//Finding the node of name - 'Revisions'.
			//for (var i=0; i < objNode.childNodes.length-1; i++)
			//{
				//if (objNode.childNodes[i].getName() == revision){
				//	node = objNode.childNodes[i];
			//	}
			//}
            //var node = tree.getSelectedNode();
            //Getting the Node Id of the Revisions
			//var strNodeID = node.nodeID;
            //Defining the link for inserting the new Revision object
            //changes for nes gen UI
			

			var link = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewRevision)%>&mode=insert";

			//contentFrameObj.changeObjectIDInTree("<%=XSSUtil.encodeForJavaScript(context,strContextObjectId)%>","<%=strNewRevision%>");
			//contentFrameObj.changeObjectLabelInTree("<xss:encodeForJavaScript><%=strNewRevision%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=strLabel%></xss:encodeForJavaScript>");
	        
            //setting the href for the frame
            contentFrameObj.document.location.href = link;
 	        parent.window.closeWindow();
			
        </SCRIPT>

        <%

    }else if(strMode!=null && strMode.equalsIgnoreCase("update")){

       for (int iCount = 0; iCount < arrObjectIds.length; iCount++){
            //Begin of modify by Enovia MatrixOne on 16-May-2005 for Bug#304479
           DomainObject domObj = DomainObject.newInstance(context,arrObjectIds[iCount]);
           String strLatestRev = (String)((BusinessObject)(domObj.getLastRevision(context))).getObjectId();
           if(!strLatestRev.equals(arrObjectIds[iCount])){
        %>
              <script language="javascript" type="text/javaScript">
                 var tree = getTopWindow().trees['emxUIDetailsTree'];
                 tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[iCount])%>");
                 refreshTreeDetailsPage();
                 refreshTablePage();
                 </SCRIPT>
        <%
           }
        //End of modify by Enovia MatrixOne on 16-May-2005 for Bug#304479
       }
    }

  }catch(Exception ex){
        bIsError=true;
        emxNavErrorObject.addMessage(ex.getMessage().toString().trim());
    }
%>


     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
     <%@include file = "../emxUICommonEndOfPageInclude.inc"%>
<%
  if (bIsError && !(strMode.equalsIgnoreCase("delete") || strMode.equalsIgnoreCase("update"))) //||strMode.equalsIgnoreCase("Create")))

  {
%>
    <script language="javascript" type="text/javaScript">
    var pc =findFrame(parent,"pagecontent");
    pc.clicked = false;
    parent.turnOffProgress();   
      history.back();
    </script>
<%
  }
%>
