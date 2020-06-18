 
<%--
  ProductLineUtil.jsp

  Performs the action that creates an incident.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /web/productline/ProductLineUtil.jsp 1.4.2.1.1.1.1.2.1.1 Mon Dec 29 21:50:58 2008 GMT vkrishnamoorthy Experimental$";

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLine"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.framework.ui.*"%>


<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<html>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
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
    if (strMode.equalsIgnoreCase("create"))
    {
      //Instantiating the FormBean
      com.matrixone.apps.common.util.FormBean formBean=new com.matrixone.apps.common.util.FormBean();

      //Processing the form using FormBean.processForm
      formBean.processForm(session,request);

      //Instantiating the ProductLine bean
      ProductLine productlineBean = (ProductLine)DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCT_LINE,"ProductLine");
      String strNewObjId = null;
      String strCommandSource = emxGetParameter(request, "strCommandSource");
      //Calling the create Method of ProductLine.java
      //and checking to see if Enterprise Change module is installed
      if (ProductLine.isDisplayProgramField(context))
        {
            productlineBean = (ProductLine) DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCT_LINE,"EnterpriseChange");;
            strNewObjId = productlineBean.create(context,formBean);
          
         }else{
             productlineBean = (ProductLine) DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCT_LINE,"ProductLine");
             strNewObjId = productlineBean.create(context,formBean);
         }
      


	  /* Start-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/
	  String strDesRelId = emxGetParameter(request, "txtDRId");
	   if (strDesRelId != null && !"".equals(strDesRelId))
		{
	  		productlineBean.connectRDO(context,strNewObjId,strDesRelId);
		}
	  /* End-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/

      String strTreeID=emxGetParameter(request,"txtTreeId");
      
      if (strCommandSource.equalsIgnoreCase("action"))
      {
%>
<!--Javascript for opening the tree with the object Id of the object that has been created-->
  <script language="javascript" type="text/javaScript">
    //<![CDATA[
      var strURL= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&treeMenu=type_PLCProductLine";
      //nextgenUi Changes need to take out "mode=insert" as this independent of context
     // strURL    = strURL + "&mode=insert&jsTreeID=<%=strTreeID%>";

         var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
        contentFrameObj.document.location.href= strURL;
        try
        {
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
        }catch(e){
            //alert if anything other than permission denied
            if(-2146828218 != e.number){
                alert(e.description)
            }
        }  
        parent.window.closeWindow();
    //]]>
  </script>
<%
      }else{     
                  /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
                  String strObjId = emxGetParameter(request, "txtObjectId");
                  String strRelName = productlineBean.getRelName(context,strObjId);
                  String strSelectRelId = "to["+strRelName+"].id";
                  DomainObject domObjPL = DomainObject.newInstance(context,strNewObjId);
                  String strRelId = domObjPL.getInfo(context,strSelectRelId);
                  /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/

        if (strObjId == null || "".equals(strObjId) || "null".equalsIgnoreCase(strObjId))
        {//comig here for productline create form Mydesk-->productline-->create
%>
  <script language="javascript" type="text/javaScript">
    <!-- hide JavaScript from non-JavaScript browsers -->
    //<![CDATA[
      var strURL= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&treeMenu=type_PLCProductLine";
      //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
      strURL    = strURL +"&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
         var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
        contentFrameObj.document.location.href = strURL;

        try
        {
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
        }catch(e){
            //alert if anything other than permission denied
            if(-2146828218 != e.number){
                alert(e.description)
            }
        }        
        parent.window.closeWindow();
    //]]>
  </script>

<%
        }else{
%>
  <script language="javascript" type="text/javaScript">
    <!-- hide JavaScript from non-JavaScript browsers -->
    //<![CDATA[
    var strURL="../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&treeMenu=type_PLCProductLine";
    //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
    strURL    = strURL+"&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
    var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
    contentFrameObj.document.location.href= strURL;
    try
        {
    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
    topFrameObj.window.focus();
        }catch(e){
            //alert if anything other than permission denied
            if(-2146828218 != e.number){
                alert(e.description)
            }
        }  
    parent.window.closeWindow();

    //]]>
  </script>

<%
        }
      }
    }

    if (strMode.equalsIgnoreCase("delete"))
    {
      PropertyUtil.setGlobalRPEValue(context,"ContextRemoveCheckForMCF","TRUE");
      //Instantiating ProductLineCommon.java
      ProductLineCommon ProductLinecommonBean = new ProductLineCommon();

      //extract Table Row ids of the checkboxes selected.
      String[] arrTableRowIds=emxGetParameterValues(request,"emxTableRowId");

      //extracts Object id of the Objects to be deleted
      boolean bIsFromTree = false;
      String[] arrObjectIds=null;
      if (arrTableRowIds[0].indexOf("|") > 0 )
      {
        arrObjectIds=(String[])ProductLineUtil.getObjectIds(arrTableRowIds);
        bIsFromTree = true;
      }
      else
      {
        arrObjectIds   = arrTableRowIds;
      }
      //returns true in case of successful deletion.
      boolean bDelete=ProductLinecommonBean.deleteObjects(context,arrObjectIds,false);
      if (bIsFromTree)
      {
        //For loop for refreshing the tree
        for(int i=0;i<arrObjectIds.length;i++)
        {
%>
  <script language="javascript" type="text/javaScript">
    <!-- hide JavaScript from non-JavaScript browsers -->
    //<![CDATA[
  var tree = getTopWindow().trees['emxUIDetailsTree'];
    tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
    //]]>
  </script>
<%
          }
%>
  <script language="javascript" type="text/javaScript">
    //<![CDATA[
    refreshTreeDetailsPage();
    //]]>
  </script>

<%
      }
      else
      {
%>
  <script language="javascript" type="text/javaScript">
    //<![CDATA[
    //IR-091956V6R2012 
    //refreshContentPage();
    refreshTablePage();
    //]]>
  </script>
<%
      }
    }

    if (strMode.equalsIgnoreCase("disconnect"))
    {
      //Instantiating ProductLineCommon.java
      ProductLineCommon ProductLinecommonBean = new ProductLineCommon();

      //extract Table Row ids of the checkboxes selected.
      String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");


      //extracts Object id of the Objects to be disconnected.
      Map relIdMap = ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);

      //Obtaining the relationship ids from the Map returned by the previous step
      String[] arrObjectIds = (String[]) relIdMap.get("ObjId");
      String[] arrRelIds    = (String[]) relIdMap.get("RelId");

      //returns true in case of successful disconnect.
      boolean bRemove=false;

      //Calling the removeObjects() method of ProductLineCommon.java
      bRemove = ProductLinecommonBean.removeObjects(context,arrRelIds);
%>
  <script language="javascript" type="text/javaScript">
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
<%
    }
	// Start Code Added by 3dPLM , RDO Enhancements

    if (strMode.equalsIgnoreCase("populateRDO"))
    {
	          String timeStamp = emxGetParameter(request, "timeStamp");  
			  HashMap tableData = tableBean.getTableData(timeStamp);			  
			  HashMap RequestMap =(HashMap) tableData.get("RequestMap");
			  String strFieldNameDisplay = (String)RequestMap.get("fieldNameDisplay");			  
 			  String strFieldNameActual = (String)RequestMap.get("fieldNameActual");			  
			  MapList objectList = (MapList)tableData.get("ObjectList");
			  String strName = "" ;
			  String strObjId = "" ;

			  if (objectList.get(0) instanceof HashMap){

				HashMap map = (HashMap)objectList.get(0); 
			    strName = (String)map.get("Name");
				strObjId = (String)map.get(DomainConstants.SELECT_ID);

			  }else if (objectList.get(0) instanceof Hashtable){
  				Hashtable table = (Hashtable)objectList.get(0); 
			    strName = (String)table.get("Name");
				strObjId = (String)table.get(DomainConstants.SELECT_ID);
			  }
			ProductLineCommon plcBean = new ProductLineCommon();
			String strDesResId = plcBean.getDefaultRDO(context,strObjId);
			String strDesReName = "" ;
			if (strDesResId != null ){
				DomainObject domObj = new DomainObject(strDesResId);
				strDesReName = domObj.getInfo(context , DomainConstants.SELECT_NAME);
			}

			%>
			  <script language = "javascript">
				try{
				  var vPLDisplay = window.parent.getWindowOpener().document.getElementById('<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)%>');
				  var vPLId = window.parent.getWindowOpener().document.getElementById('<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)%>');
			      var vRDOId = window.parent.getWindowOpener().document.getElementById('txtDRId');
				  var vRDOName = window.parent.getWindowOpener().document.getElementById('txtProductDesResp');

				  vPLDisplay.value= "<%=XSSUtil.encodeForJavaScript(context,strName)%>";
				  vPLId.value= "<%=XSSUtil.encodeForJavaScript(context,strObjId)%>";
				
				  vRDOId.value= "<%=XSSUtil.encodeForJavaScript(context,strDesResId)%>";
				  vRDOName.value= "<%=XSSUtil.encodeForJavaScript(context,strDesReName)%>";

				  window.parent.closeWindow();
				  

			  }catch(exec){
				  alert(exec);
			  }
			  </script>	
			<%
	}
    else if(strMode.equals("isDuplicateName")){
        String type = emxGetParameter(request,"type");
        String name = emxGetParameter(request,"name");
        String revision = emxGetParameter(request,"revision");
        String prdDup  = ProductLineUtil.isProductNameDuplicate(context,type ,name,revision);
        out.println("isDup=");
        out.println(prdDup);
        out.println("#");
    }
  	// End Code Added by 3dPLM , RDO Enhancements
	
  }
   catch (Exception e)
  {
    bFlag=true;
    String alertString = "emxProduct.Alert." + e.getMessage();
    String i18nErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);
    if(i18nErrorMessage.equals((DomainConstants.EMPTY_STRING)))
    {
    	emxNavErrorObject.addMessage(e.getMessage());
    }else{
    	emxNavErrorObject.addMessage(i18nErrorMessage);
    }
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  if (bFlag==true)
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
</html>
