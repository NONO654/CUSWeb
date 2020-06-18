<%--  emxpartEditEBOMsFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<%@ include file="emxEngrFramesetUtil.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>


<%@ page import="
                com.matrixone.apps.domain.util.*,
                com.matrixone.apps.domain.DomainRelationship,
                com.matrixone.apps.engineering.Part"  %>

<%   
  String initSource   = emxGetParameter(request,"initSource");
  String objectId     = emxGetParameter(request,"objectId");
  String removalFlag  = emxGetParameter(request,"removalFlag");
  String tstamp       = emxGetParameter(request,"timeStamp");
   if(tstamp==null){
    tstamp       = (String)session.getAttribute("timeStamp");
  }else{
        session.setAttribute("timeStamp",tstamp);
  }

  // will return null for the first time the window is opened from the summary page.
 removalFlag         = (removalFlag==null)?"":removalFlag;

String SelEbomIds  = null;
if(removalFlag.equals("true")){
  // will return null for the first time the window is opened from the summary page.
  SelEbomIds   = (String)session.getAttribute("SelEbomIds");
}
  // check if the window is opened for the first time then construct the relationship id list
  if(SelEbomIds==null)
  {
    SelEbomIds = "";
    MapList objList = tableBean.getObjectList(tstamp);
    for (int i=0;i<objList.size();i++) 
    {
      Map relIdMap= (Map)objList.get(i);
      String relId= (String)relIdMap.get("id[connection]");
      if (i==0) 
      {
        SelEbomIds = relId;
      }
      else 
      {
        SelEbomIds += relId;
      }
      if (i < objList.size() -1) 
      {
        SelEbomIds += ",";
      }
    }
    
  }
  if (initSource == null)
  {
    initSource = "";
  }

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxpartEditEBOMs.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(emxGetParameter(request,"suiteKey"));
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(emxGetParameter(request,"jsTreeID"));
  contentURL.append("&objectId=");
  contentURL.append(emxGetParameter(request,"objectId"));
  contentURL.append("&removalFlag=");
  contentURL.append(emxGetParameter(request,"removalFlag"));
  contentURL.append("&timeStamp=");
  contentURL.append(tstamp);
  
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  //save the ids in the session because they will blow out the max url buffer length  
  session.setAttribute("SelEbomIds",SelEbomIds);

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.Common.EditBOM";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbomeditall";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.setObjectId(objectId);
  
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

//  if (acc.has(Access.cRead)) {

  // Role based access
  /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer";*/
  String roleList ="role_GlobalUser";

//  fs.createFooterLink("emxEngineeringCentral.Button.RemoveSelected","removeSelected()",roleList,false,true,"default",3);

  fs.createFooterLink("emxFramework.Command.Done","submit()",roleList,false,true,"common/images/buttonDialogDone.gif",3);

  fs.createFooterLink("emxFramework.Command.Cancel","cancel()",roleList,false,true,"common/images/buttonDialogCancel.gif",5);

  //}
  fs.setToolbar("ENCpartEditEBOMsToolBar");
  fs.writePage(out);
%>
