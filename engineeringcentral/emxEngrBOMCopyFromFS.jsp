<%--  emxEngrBOMCopyFromFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
  Part selPartObj = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  String strObjectId = emxGetParameter(request,"objectId");

  String strSelPartId = emxGetParameter(request,"checkBox");

  String isAVLReport = emxGetParameter(request,"AVLReport");
  if (isAVLReport==null) {
        isAVLReport = "FALSE";
  }

  String selPartRelId = emxGetParameter(request,"selPartRelId");
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  String frameName = emxGetParameter(request, "frameName");
  if (!selPartObjectId.equals("") || selPartObjectId!=null || !selPartObjectId.equals("null")) {
  strObjectId = selPartObjectId;
  }
  

  boolean showAppendReplaceOption = false;
  String strAppendReplace = emxGetParameter(request,"AppendReplaceOption");
  if(strAppendReplace == null || "".equals(strAppendReplace)) {
    SelectList resultSelects = new SelectList(1);
    resultSelects.add(Part.SELECT_ID);

    StringList selectRelStmts = new StringList(1);
    selectRelStmts.addElement(Part.SELECT_ATTRIBUTE_COMPONENT_LOCATION);

    selPartObj.setId(strObjectId);
    String selection = "from["+DomainConstants.RELATIONSHIP_EBOM+"]";
    StringList select = new StringList(1);
    select.add(selection);
    Map data = (Map)mxBus.print(context,selPartObj,select,null);
    if ("TRUE".equalsIgnoreCase((String)data.get(selection))){
        showAppendReplaceOption = true;
    }
  }


  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrBOMCopyFrom.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&AVLReport=" + isAVLReport;
	String name ="";
	String value = "";
	String param = "";

  // Loop through parameters and pass on to summary page
  for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
  {
    name = (String) names.nextElement();
    value = emxGetParameter(request, name);
    param = "&" + name + "=" + value;
    contentURL += param;
  }
  contentURL += "&AppendReplaceOption=" + strAppendReplace;

  if(showAppendReplaceOption){
    contentURL += "&showAppendReplaceOption=" + showAppendReplaceOption;
  }


  contentURL += "&selPartRelId=" + selPartRelId + "&selPartObjectId=" + selPartObjectId + "&selPartParentOId=" + selPartParentOId + "&frameName=" + frameName;
  
  
  // Page Heading - Internationalized
  //String PageHeading = "emxEngineeringCentral.CopyFrom.Step3";
  String PageHeading = "emxEngineeringCentral.CopyFrom.Header";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbomcopyfrom";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  /*String roleList = "role_DesignEngineer,role_ECRChairman,role_ECRCoordinator,role_ECREvaluator," +
                    "role_ManufacturingEngineer,role_OrganizationManager,role_PartFamilyCoordinator," +
                    "role_ProductObsolescenceManager,role_SeniorDesignEngineer,role_SeniorManufacturingEngineer";*/
  String roleList ="role_GlobalUser";

  if(!strObjectId.equals(strSelPartId)) {
    if(!showAppendReplaceOption) {
      fs.createCommonLink("emxFramework.Command.Submit",
                          "submit()",
                          roleList,
                          false,
                          true,
                          "common/images/buttonDialogDone.gif",
                          false,
                          3);

    } else {
      fs.createCommonLink("emxEngineeringCentral.Common.Append",
                          "Append()",
                          roleList,
                          false,
                          true,
                          "common/images/buttonDialogDone.gif",
                          false,
                          3);

      fs.createCommonLink("emxEngineeringCentral.Common.Replace",
                          "Replace()",
                          roleList,
                          false,
                          true,
                          "common/images/buttonDialogDone.gif",
                          false,
                          3);

     fs.createCommonLink("emxEngineeringCentral.Common.Merge",
                               "Merge()",
                               roleList,
                               false,
                               true,
                               "common/images/buttonDialogDone.gif",
                               false,
                          3);
    }
  }
  fs.createCommonLink("emxFramework.Command.Cancel",
                      "parent.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>
