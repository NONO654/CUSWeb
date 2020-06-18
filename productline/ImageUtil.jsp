<%--
  ImageUtil.jsp


  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ImageUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

 --%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.Image"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>

<!-- The Declarations -->
<%!
//Static VAriables
private  final String FILE = "file";
private  final String JS_TREE_ID = "jsTreeId";
private  final String MODE = "mode";
private  final String OBJECT_ID = "objectId";
private  final String POLICY = "ImagePolicy";
private  final String REL_ID = "RelId";
private  final String TABLE_ROW_ID = "emxTableRowId";

// Static Variable for differnt mode
private  final String CREATE_MODE = "Create";
private  final String DELETE_MODE = "Delete";
private  final String DISCONNECT_MODE = "Disconnect";
private  final String DISPLAY_IMAGE_MODE = "Display";
private  final String MOVE_UP_MODE = "MoveUp";
private  final String MOVE_DOWN_MODE = "MoveDown";
private  final String NEXT_ACTION = "Next";
private  final String PREVIOUS_ACTION = "Previous";
private  final String SET_AS_PRIMARY_MODE = "SetAsPrimary";
private  final String SLIDE_SHOW_MODE = "SlideShow";
private  final String START_SLIDE_SHOW_MODE = "ShowSlide";

//Defining the static error variable
private  final String ERROR_ALREADY_PRIMARY = "emxProduct.Alert.AlreadyPrimary";
private  final String ERROR_NO_OBJECTS = "emxProduct.Alert.NoImageObject";
private  final String ERROR_NOT_MOVED_DOWN = "emxProduct.Alert.NotMovedDown";
private  final String ERROR_NOT_MOVED_UP = "emxProduct.Alert.NotMovedUp";
%>

<html>
  <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<%
String strMode = "";
String showWarning= "";
try
{
  //Get the mode called
  strMode = emxGetParameter(request, MODE);
  String jsTreeID = emxGetParameter(request, JS_TREE_ID);
  String objectId = emxGetParameter(request, OBJECT_ID);
  String Policy   = emxGetParameter(request, POLICY);

  //Get the showWarning parameter
  showWarning=emxGetParameter(request,"showWarning");


  String imageId    = "";
  //Instantiating the Image bean
  com.matrixone.apps.productline.Image imageBean = (com.matrixone.apps.productline.Image)DomainObject.newInstance(context,ProductLineConstants.TYPE_IMAGE,"PRODUCTLINE");

  //Instantiating the FormBean
  com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
  //Processing the form using FormBean.processForm
  formBean.processForm(session,request);


  //Start of Slide Show Functionality
  if(strMode.equalsIgnoreCase(SLIDE_SHOW_MODE) == true)
  {
    try
    {

      //Getting the object id of the parent object
      String parentObjectID= emxGetParameter(request,OBJECT_ID);
      //Instantiating MapList to store the objects details
      MapList imageList = new MapList();
      //Calling the getsortedImageList Method of Image.java
      imageList = imageBean.getsortedImageList(context,parentObjectID);
      //Varaible for keeping count for slide show
      int iMaxCount = imageList.size();
      Integer intMaxCount = new Integer(iMaxCount);
      String strMaxCount = intMaxCount.toString();
      int iCount = 1;
      Integer intCount = new Integer(iCount);
      String strCount = intCount.toString();
      //String is initialized to store the object id
      String strObjectIdList = "";
      //All the object id's of related object is stored in one string separated by |
      for (int i = 0; i < iMaxCount; i++) {
        String strObjectId = (String)((Hashtable)imageList.get(i)).get(DomainConstants.SELECT_ID);
        strObjectIdList = strObjectIdList + strObjectId + "|";
      }
      //If no image object connected display alert
      if (imageList.size() == 0)
      {
        String strAlertMessage = i18nStringNowUtil(ERROR_NO_OBJECTS,bundle,acceptLanguage);
        //XSSOK, parentObjectID is used in API to create BusinessObject
        strAlertMessage = com.matrixone.apps.framework.ui.UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,strAlertMessage,parentObjectID);

%>
        <script language="javascript" type="text/javaScript">
        alert("<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>");
        </script>
<%
      }
      // If atleast one object present calls util jsp with mode = ShowSlide
      else
      {

      %>
        <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strMode)%>")>
          <FORM name="ShowSlide" method="post" >
            <INPUT type="hidden" name="forNetscape" >
            &nbsp
          </FORM>
        </BODY>

        <script language="javascript" type="text/javaScript">
        function loadUtil(strMode)
        {
          var formName = document.ShowSlide;
          formName.action = "../productline/ImageUtil.jsp?mode=ShowSlide&action=None&showWarning=false&strObjectIdList=<%=XSSUtil.encodeForURL(context,strObjectIdList)%>&strMaxCount=<%=XSSUtil.encodeForURL(context,strMaxCount)%>&strCount=<%=XSSUtil.encodeForURL(context,strCount)%>&strParentObjectId=<%=XSSUtil.encodeForURL(context,parentObjectID)%>";
          formName.submit();
        }
        </script>
<%
      }
    }catch(Exception e){
      session.putValue("error.message", e.getMessage());
    }
  }
  //End of Slide Show Functionality



  //Start of Show Slide Functionality. Called only if atleast one image object is connected to parent
  else if (strMode.equalsIgnoreCase(START_SLIDE_SHOW_MODE) == true)
  {
    try
    {
      //Getting the parameters passed
      //Getting the object id's of related objects separated by |
      String strObjectIdList = emxGetParameter(request, "strObjectIdList");
      //Getting the parent object id
      String strParentObjectId = emxGetParameter(request, "strParentObjectId");
      //Getting the total number of object
      String strMaxCount = emxGetParameter(request, "strMaxCount");
      //Getting the number of object to be displayed
      String strCount = emxGetParameter(request, "strCount");
      //Getting the value of action: Can be "Next" or "Previous"
      String strAction = emxGetParameter(request, "action");
      int iMaxCount = Integer.parseInt(strMaxCount);
      int iCount = Integer.parseInt(strCount);
      //if Next button is clicked increse the count by 1
      if (strAction.equals(NEXT_ACTION))
      {
        iCount = iCount + 1;
        Integer intCountTemp = new Integer(iCount);
        strCount = intCountTemp.toString();
      }
      //if Previous button is clicked decrease the count by 1
      else if (strAction.equals(PREVIOUS_ACTION))
      {
        iCount = iCount - 1;
        Integer intCountTemp = new Integer(iCount);
        strCount = intCountTemp.toString();
      }

      String strObjectId ="";
      /*if total no image object is only 1. Get details of the object
       * and call FS jsp with parameter to show only Cancel button
       */
      if (iMaxCount == 1)
      {
        strObjectId = strObjectIdList.substring(0, strObjectIdList.indexOf("|"));
        //Calling the downloadImageFile Method of Image.java to get details about the object
        Map fileDetailMap = imageBean.downloadImageFile(context,strObjectId);
        StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
        String strFile = (String)(strFileList.get(0));
        String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT));
        String strDescription = (String)(fileDetailMap.get(DomainConstants.SELECT_DESCRIPTION));
        //Calling the isPrimaryImage Method of Image.java to check if the object is primary or not
        String strIsPrimary = imageBean.isPrimaryImage(context, strObjectId, strParentObjectId);
%>
        <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strMode)%>")>
          <FORM name="SlideShow" method="post" >
            <INPUT type="hidden" name="forNetscape" >
            &nbsp
          </FORM>
        </BODY>

        <script language="javascript" type="text/javaScript">
        function loadUtil(strMode)
        {
          var formName = document.SlideShow;
          emxShowModalDialog('../components/emxCommonFS.jsp?functionality=ImageSlideShowOneFSInstance&showWarning=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&strParentObjectId=<%=XSSUtil.encodeForURL(context,strParentObjectId)%>&strObjectIdList=<%=XSSUtil.encodeForURL(context,strObjectIdList)%>&strMaxCount=<%=XSSUtil.encodeForURL(context,strMaxCount)%>&strCount=<%=XSSUtil.encodeForURL(context,strCount)%>&strFile=<%=XSSUtil.encodeForURL(context,strFile)%>&strFormat=<%=XSSUtil.encodeForURL(context,strFormat)%>&strIsPrimary=<%=XSSUtil.encodeForURL(context,strIsPrimary)%>&strDescription=<%=XSSUtil.encodeForURL(context,strDescription)%>&suiteKey=ProductLine',780,500,false);
          window.closeWindow();
        }
        </script>
<%
      }
      /*if total number image object is more then 1 and current image
       *is first image to be displayed. Get details of the object
       * and call FS jsp with parameter to show Next & Cancel button
       */
      else if (iCount == 1 && iMaxCount>1)
      {
        strObjectId = strObjectIdList.substring(0, strObjectIdList.indexOf("|"));
        //Calling the downloadImageFile Method of Image.java to get details about the object
        Map fileDetailMap = imageBean.downloadImageFile(context,strObjectId);
        StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
        String strFile = (String)(strFileList.get(0));
        String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT));
        String strDescription = (String)(fileDetailMap.get(DomainConstants.SELECT_DESCRIPTION));
        //Calling the isPrimaryImage Method of Image.java to check if the object is primary or not
        String strIsPrimary = imageBean.isPrimaryImage(context, strObjectId, strParentObjectId);
%>
        <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strMode)%>")>
          <FORM name="SlideShow" method="post" >
            <INPUT type="hidden" name="forNetscape" >
            &nbsp
          </FORM>
        </BODY>

        <script language="javascript" type="text/javaScript">
        function loadUtil(strMode)
        {
          var formName = document.SlideShow;
  <%
          if (strAction.equalsIgnoreCase("None"))
          {
  %>
            emxShowModalDialog('../components/emxCommonFS.jsp?functionality=ImageSlideShowFirstFSInstance&showWarning=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&strParentObjectId=<%=XSSUtil.encodeForURL(context,strParentObjectId)%>&strObjectIdList=<%=XSSUtil.encodeForURL(context,strObjectIdList)%>&strMaxCount=<%=XSSUtil.encodeForURL(context,strMaxCount)%>&strCount=<%=XSSUtil.encodeForURL(context,strCount)%>&strFile=<%=XSSUtil.encodeForURL(context,strFile)%>&strFormat=<%=XSSUtil.encodeForURL(context,strFormat)%>&strIsPrimary=<%=XSSUtil.encodeForURL(context,strIsPrimary)%>&strDescription=<%=XSSUtil.encodeForURL(context,strDescription)%>&suiteKey=ProductLine',780,500,false);
         <%
          }
          else {
  %>
            formName.target= "_top";
            formName.action = "../components/emxCommonFS.jsp?functionality=ImageSlideShowFirstFSInstance&showWarning=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&strParentObjectId=<%=XSSUtil.encodeForURL(context,strParentObjectId)%>&strObjectIdList=<%=XSSUtil.encodeForURL(context,strObjectIdList)%>&strMaxCount=<%=XSSUtil.encodeForURL(context,strMaxCount)%>&strCount=<%=XSSUtil.encodeForURL(context,strCount)%>&strFile=<%=XSSUtil.encodeForURL(context,strFile)%>&strFormat=<%=XSSUtil.encodeForURL(context,strFormat)%>&strIsPrimary=<%=XSSUtil.encodeForURL(context,strIsPrimary)%>&strDescription=<%=XSSUtil.encodeForURL(context,strDescription)%>&suiteKey=ProductLine";
            formName.submit();
  <%
          }
%>
        }
        </script>
<%
  }
      /*If the Current image other then first image but not the last image
       * Get details of the object and call FS jsp with parameter
       * to show Previous, Next & Cancel button
       */
      else if (iCount > 1 && iCount < iMaxCount)
      {
        // Get the object id of Image dpending upon the Count
        strObjectId = strObjectIdList.substring(0, strObjectIdList.lastIndexOf("|"));
        for (int i = 0; i < iCount-1; i++) {
          strObjectId = strObjectId.substring(strObjectId.indexOf("|")+1, strObjectId.length());
        }
        for (int i = 0; i<(iMaxCount-iCount); i++) {
          strObjectId = strObjectId.substring(0, strObjectId.lastIndexOf("|"));
        }
        //Calling the downloadImageFile Method of Image.java to get details about the object
        Map fileDetailMap = imageBean.downloadImageFile(context,strObjectId);
        StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
        String strFile = (String)(strFileList.get(0));
        String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT));
        String strDescription = (String)(fileDetailMap.get(DomainConstants.SELECT_DESCRIPTION));
        //Calling the isPrimaryImage Method of Image.java to check if the object is primary or not
        String strIsPrimary = imageBean.isPrimaryImage(context, strObjectId, strParentObjectId);
%>
        <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strMode)%>")>
          <FORM name="SlideShow" method="post" >
            <INPUT type="hidden" name="forNetscape" >
            &nbsp
          </FORM>
        </BODY>

        <script language="javascript" type="text/javaScript">
        function loadUtil(strMode)
        {
          var formName = document.SlideShow;
          formName.target= "_top";
          formName.action = "../components/emxCommonFS.jsp?functionality=ImageSlideShowIntermediateFSInstance&showWarning=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&strParentObjectId=<%=XSSUtil.encodeForURL(context,strParentObjectId)%>&strObjectIdList=<%=XSSUtil.encodeForURL(context,strObjectIdList)%>&strMaxCount=<%=XSSUtil.encodeForURL(context,strMaxCount)%>&strCount=<%=XSSUtil.encodeForURL(context,strCount)%>&strFile=<%=XSSUtil.encodeForURL(context,strFile)%>&strFormat=<%=XSSUtil.encodeForURL(context,strFormat)%>&strIsPrimary=<%=XSSUtil.encodeForURL(context,strIsPrimary)%>&strDescription=<%=XSSUtil.encodeForURL(context,strDescription)%>&suiteKey=ProductLine";
          formName.submit();
        }
        </script>
<%
      }
      /*When the Image to be displayed is last. Get details of the object and
       *call FS jsp with parameter to show Previous & Cancel button
       */
      else if (iCount==iMaxCount)
      {
        // Get the object id of Image dpending upon the Count
        strObjectId = strObjectIdList.substring(0, strObjectIdList.lastIndexOf("|"));
        strObjectId = strObjectId.substring(strObjectId.lastIndexOf("|")+1, strObjectId.length());
        //Calling the downloadImageFile Method of Image.java to get details about the object
        Map fileDetailMap = imageBean.downloadImageFile(context,strObjectId);
        StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
        String strFile = (String)(strFileList.get(0));
        String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT));
        String strDescription = (String)(fileDetailMap.get(DomainConstants.SELECT_DESCRIPTION));
        //Calling the isPrimaryImage Method of Image.java to check if the object is primary or not
        String strIsPrimary = imageBean.isPrimaryImage(context, strObjectId, strParentObjectId);
%>
        <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strMode)%>")>
          <FORM name="SlideShow" method="post" >
            <INPUT type="hidden" name="forNetscape" >
                &nbsp
          </FORM>
        </BODY>
        <script language="javascript" type="text/javaScript">
        function loadUtil(strMode)
        {
          var formName = document.SlideShow;
          formName.target= "_top";
          formName.action = "../components/emxCommonFS.jsp?functionality=ImageSlideShowLastFSInstance&showWarning=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&strParentObjectId=<%=XSSUtil.encodeForURL(context,strParentObjectId)%>&strObjectIdList=<%=XSSUtil.encodeForURL(context,strObjectIdList)%>&strMaxCount=<%=XSSUtil.encodeForURL(context,strMaxCount)%>&strCount=<%=XSSUtil.encodeForURL(context,strCount)%>&strFile=<%=XSSUtil.encodeForURL(context,strFile)%>&strFormat=<%=XSSUtil.encodeForURL(context,strFormat)%>&strIsPrimary=<%=XSSUtil.encodeForURL(context,strIsPrimary)%>&strDescription=<%=XSSUtil.encodeForURL(context,strDescription)%>&suiteKey=ProductLine";
          formName.submit();
        }
        </script>
<%
      }
    }catch(Exception e){
      session.putValue("error.message", e.getMessage());
    }
  }
  //End of Show Slide Functionality.



  //Start of Set As Primary Image Functionality
  else if(strMode.equalsIgnoreCase(SET_AS_PRIMARY_MODE) == true)
  {
    try
    {
      ENOCsrfGuard.validateRequest(context, session, request,response);
      String parentObjectID= emxGetParameter(request,OBJECT_ID);
      //Instantiating ProductLineUtil.java bean
      com.matrixone.apps.productline.ProductLineUtil productLineUtil = new com.matrixone.apps.productline.ProductLineUtil();
      //Getting the table row ids of the selected objects from the request
      String[] arrTableRowIds = emxGetParameterValues(request, TABLE_ROW_ID);
      //Getting the object ids from the table row ids
      String arrObjectIds[] = null;
      arrObjectIds = productLineUtil.getObjectIds(arrTableRowIds);
	  String strErrorMessage = "";
      boolean bIsPrimary = false;
      //Calling the setAsPrimaryImage () method of Image.java
      bIsPrimary = imageBean.setAsPrimaryImage(context,arrObjectIds[0], parentObjectID);
      //Show alert if the selected item is already Primary
      if (bIsPrimary == false)
      {
		// Changes added for IR-608667-3DEXPERIENCER2019x
        strErrorMessage = i18nStringNowUtil(ERROR_ALREADY_PRIMARY,bundle,acceptLanguage);
        //session.putValue("error.message", strErrorMessage);
      }
%>
      <!--Javascript to reload the tree-->
      <script language="javascript" type="text/javaScript">
      	  
	  // Changes added for IR-608667-3DEXPERIENCER2019x
	    var strErrorMessage = "<%=strErrorMessage%>";
		if(strErrorMessage != null && strErrorMessage != ""){
			alert(strErrorMessage);
		} else {
			//Refreshing page after Make Selected Primary Operation
			//refreshTreeDetailsPage();
	       var contentFrameObj = findFrame(getTopWindow(),"PLCProductImageTreeCategory");                     
		   if (contentFrameObj == null) {
			   contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");  					                     
			}				    
			contentFrameObj.location.href = contentFrameObj.location.href;
			//Refreshing page after Make Selected Primary Operation
		}	   
	   </script>
<%
    }catch(Exception e){
      session.putValue("error.message", e.getMessage());
    }
  }
  //End of Set As Primary Image Functionality



  //Start of Delete Functionality
  else if(strMode.equalsIgnoreCase(DELETE_MODE) == true)
  {
    try
    {
      ENOCsrfGuard.validateRequest(context, session, request,response);
      //Getting the table row ids of the selected objects from the request
      String arrRowIds[] = emxGetParameterValues(request,TABLE_ROW_ID);
      String parentObjectID= emxGetParameter(request,OBJECT_ID);
      //Instantiating ProductLineUtil.java bean
      com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
      //Getting the object ids from the table row ids
      String arrObjectIds[] = null;
      arrObjectIds = productlineUtil.getObjectIds(arrRowIds);
      // Calling the delete method of the Image bean
      boolean bReturnVal= imageBean.delete(context,arrObjectIds);
%>
      <script language="javascript" type="text/javaScript">
<%
      for(int i=0;i<arrObjectIds.length;i++)
      {
%>
        <!-- hide JavaScript from non-JavaScript browsers -->
  var tree = getTopWindow().trees['emxUIDetailsTree'];
        tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
<%
      }
%>
     // refreshTreeDetailsPage();
                      //Modify for PLC Categories consolidation
                   var contentFrameObj = findFrame(getTopWindow(),"PLCProductImageTreeCategory");                     
					 if (contentFrameObj == null) {
					     contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");  					                     
					      }				    
					contentFrameObj.location.href = contentFrameObj.location.href;
      </script>
<%
    }catch(Exception e){
      session.putValue("error.message", e.getMessage());
    }
  }
  //End of Delete Functionality



  //Start of Disconnect Functionality
  else if(strMode.equalsIgnoreCase(DISCONNECT_MODE) == true)
  {
    try
    {
      ENOCsrfGuard.validateRequest(context, session, request,response);
      //Getting the table row ids of the selected objects from the request
      String arrRowIds[] = emxGetParameterValues(request,TABLE_ROW_ID);
      String parentObjectID= emxGetParameter(request,OBJECT_ID);
      //Instantiating productlineUtil.java bean
      com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
      //Getting the object ids from the table row ids
      String arrObjectIds[] = null;
      arrObjectIds = productlineUtil.getObjectIds(arrRowIds);
      //Getting the Rel ids from the table row ids
      String[] arrRelIdsToRemove = (String[])(productlineUtil.getObjectIdsRelIds(arrRowIds)).get(REL_ID);
      // Calling the removeObject method of the Image bean
      boolean bReturnVal= imageBean.removeObject(context,arrRelIdsToRemove,arrObjectIds,parentObjectID);

      MapList imageList = new MapList();
      StringList objectSelects = new StringList(DomainConstants.SELECT_ID);

      StringBuffer sbRelWhereCondition = new StringBuffer(25);
      sbRelWhereCondition = sbRelWhereCondition.append("attribute["+ ProductLineConstants.ATTRIBUTE_SEQUENCE_ORDER +"]==1");
      String strRelWhereCondition = sbRelWhereCondition.toString();

      Image image = new Image();
      DomainObject domParent = DomainObject.newInstance(context, parentObjectID);

      String strPrimaryImageId = domParent.getInfo(context,
                                                   "from[" + ProductLineConstants.RELATIONSHIP_PRIMARY_IMAGE + "].to.id");
      if(bReturnVal== true)
      {
          if(strPrimaryImageId == null)
          {
               imageList = domParent.getRelatedObjects(context,
                                                       ProductLineConstants.RELATIONSHIP_IMAGES,
                                                       DomainConstants.QUERY_WILDCARD,
                                                       objectSelects,
                                                       null,
                                                       false,
                                                       true,
                                                       (short)1,
                                                       DomainConstants.EMPTY_STRING,
                                                       strRelWhereCondition);

               if(imageList.size() !=0)
               {
                   String strImageId = (String)((Map)imageList.get(0)).get(DomainConstants.SELECT_ID);

                   image.setImageAsPrimary(context,
                                           parentObjectID,
                                           ProductLineConstants.TYPE_IMAGE,
                                           ProductLineConstants.RELATIONSHIP_PRIMARY_IMAGE,
                                           strImageId);
               }
          }
      }

%>
      <script language="javascript" type="text/javaScript">
<%
      for(int i=0;i<arrObjectIds.length;i++)
      {
%>
  var tree = getTopWindow().trees['emxUIDetailsTree'];
        tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
<%
      }
%>
      //refreshTreeDetailsPage();
                 //Modify for PLC Categories consolidation
                   var contentFrameObj = findFrame(getTopWindow(),"PLCProductImageTreeCategory");                     
					 if (contentFrameObj == null) {
					     contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");  					                     
					      }				    
					contentFrameObj.location.href = contentFrameObj.location.href;
   //  refreshTablePage();  
      </script>
<%
    }catch(Exception e){
        session.putValue("error.message", e.getMessage());
    }
  }

  //Strat of Move Up and Down Functionality
  else if(strMode.equalsIgnoreCase(MOVE_UP_MODE) == true || strMode.equalsIgnoreCase(MOVE_DOWN_MODE))
  {
    try
    {
      ENOCsrfGuard.validateRequest(context, session, request,response);
      boolean bMoveUp = false;
      if (strMode.equalsIgnoreCase(MOVE_UP_MODE))
      {
        bMoveUp = true;
      }
      String parentObjectID= emxGetParameter(request,OBJECT_ID);
      //Instantiating productlineUtil.java bean
      com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
      //Getting the table row ids of the selected objects from the request
      String[] arrTableRowIds = emxGetParameterValues(request, TABLE_ROW_ID);
      //Getting the object ids from the table row ids
      String arrObjectIds[] = null;
      arrObjectIds = productlineUtil.getObjectIds(arrTableRowIds);
      //Getting the relationship ids from the table row ids
      Map relIdMap = productlineUtil.getObjectIdsRelIds(arrTableRowIds);
      String sRelIds[] = null;
      sRelIds = (String[]) relIdMap.get(REL_ID);
      //Calling the moveImage method of Image.java
      boolean bIsMoved = false;
	  String strErrorMessage = "";
      bIsMoved = imageBean.moveImage(context,arrObjectIds[0],sRelIds[0], parentObjectID, bMoveUp);
      //If the selected item cannot be moved up or down display appropriate alert
      if ( bIsMoved == false && bMoveUp == true )
      {
		// Changes added for IR-608667-3DEXPERIENCER2019x
        strErrorMessage = i18nStringNowUtil(ERROR_NOT_MOVED_UP,bundle,acceptLanguage);
        //session.putValue("error.message", strErrorMessage);
      }
      else if ( bIsMoved == false && bMoveUp == false )
      {
		// Changes added for IR-608667-3DEXPERIENCER2019x
        strErrorMessage = i18nStringNowUtil(ERROR_NOT_MOVED_DOWN,bundle,acceptLanguage);
        //session.putValue("error.message", strErrorMessage);
      }
%>
      <!--Javascript to reload the tree-->
      <script language="javascript" type="text/javaScript">
      
	  // Changes added for IR-608667-3DEXPERIENCER2019x
	  var strErrorMessage = "<%=strErrorMessage%>";	
	  if(strErrorMessage != null && strErrorMessage != ""){
		   alert(strErrorMessage);
	   } else {
		   //Refreshing page after Image Up & Down - Starts
		   //refreshTreeDetailsPage();		  
		   var contentFrameObj = findFrame(getTopWindow(),"PLCProductImageTreeCategory");                     
		   if (contentFrameObj == null) {
			   contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");  					                     
			}				    
			contentFrameObj.location.href = contentFrameObj.location.href;
			//Refreshing page after Image Up & Down - Ends
	   }
	
      </script>
<%
    }catch(Exception e){
      session.putValue("error.message", e.getMessage());
    }
  }
  else if(strMode.equalsIgnoreCase("FormImage"))
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
  //End of Move Up and Down Functionality

}catch(Exception e){
    session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  if (strMode.equalsIgnoreCase(CREATE_MODE))
  {
%>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[
    history.back();
  //]]>
  </script>
<%
  }
%>
</html>
