<%--  emxengchgEBOMUpdateDialogFS.jsp   -   FS page for Mass EBOM Update dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
 //Added for IR-069928V6R2012
  String PrevJsp=emxGetParameter(request,"PrevJsp");
  framesetObject fs = new framesetObject();

  String suiteKey             = emxGetParameter(request, "suiteKey");
  fs.setSuiteKey(suiteKey);
  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String ecrId = emxGetParameter(request,"ecrId");

  String selectedObjs = (String)session.getAttribute("selectedParts");

  if(selectedObjs.indexOf(",")<0)
  {
	String[] selectedObjects = new String[1];
    selectedObjects[0] = selectedObjs;
    session.setAttribute("selectedObjs", selectedObjects);
  }
  else
  {
  	StringList busSelects = new StringList(2);
  	busSelects.add(DomainConstants.SELECT_ID);
  	busSelects.add(DomainConstants.SELECT_TYPE);
  	StringList relSelects = new StringList(2);
  	relSelects.addElement(DomainObject.SELECT_RELATIONSHIP_ID);
  	relSelects.addElement("attribute["+DomainConstants.ATTRIBUTE_FIND_NUMBER+"].value");
 
    StringTokenizer st = new StringTokenizer(selectedObjs, ",");
    String[] selectedObjects = new String[st.countTokens()];
    String selectedType = "";
    int i = 0;
    while(st.hasMoreTokens())
    {

      selectedObjects[i] = st.nextToken();
      i++;
    }

/*
Start mod by BMR on 083105

Purpose:
Orignal logic was incorrect.
*/
    ArrayList aList = new ArrayList();
    Vault vault = new Vault(JSPUtil.getVault(context,session));
    String sBaseType = "";
    String selectedObjId = null;
    DomainObject dObj = new DomainObject();

    for(i=0; i<selectedObjects.length; i++)
    {
      selectedObjId = selectedObjects[i].substring(0, selectedObjects[i].indexOf('|'));
      dObj.setId(selectedObjId);
      sBaseType = FrameworkUtil.getBaseType(context,dObj.getInfo(context, DomainObject.SELECT_TYPE),vault);

  		if(!PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS").equalsIgnoreCase(sBaseType))
  		{  
        aList.add(selectedObjects[i]);
  		}
	  }
//End mod by BMR on 083105 
	String[] partIds = (String[])aList.toArray(new String[aList.size()]);
	session.setAttribute("selectedObjs", partIds);
  }

  String selectedType = emxGetParameter(request,"selectedType");
  String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
  String checkboxValue=emxGetParameter(request,"checkboxValue");
  String Create = emxGetParameter(request,"Create");
  String prevmode  = emxGetParameter(request,"prevmode");
  String sName = emxGetParameter(request,"Name");
  String sRev = emxGetParameter(request,"Rev");
  String partsConnected =emxGetParameter(request,"partsConnected");
  String policy = emxGetParameter(request,"policy");
  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxengchgEBOMUpdateDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(emxGetParameter(request,"suiteKey"));
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(emxGetParameter(request,"jsTreeID"));
  contentURL.append("&objectId=");
  contentURL.append(emxGetParameter(request,"objectId"));
  contentURL.append("&ecrId=");
  contentURL.append(emxGetParameter(request,"ecrId"));
  contentURL.append("&selectedType=");
  contentURL.append(emxGetParameter(request,"selectedType"));
  contentURL.append("&checkedButtonValue=");
  contentURL.append(emxGetParameter(request,"checkedButtonValue"));
  contentURL.append("&checkboxValue=");
  contentURL.append(emxGetParameter(request,"checkboxValue"));
  contentURL.append("&Create=");
  contentURL.append(emxGetParameter(request,"Create"));
  contentURL.append("&prevmode=");
  contentURL.append(emxGetParameter(request,"prevmode"));
  contentURL.append("&sName=");
  contentURL.append(emxGetParameter(request,"sName"));
  contentURL.append("&sRev=");
  contentURL.append(emxGetParameter(request,"sRev"));
  contentURL.append("&partsConnected=");
  contentURL.append(emxGetParameter(request,"partsConnected"));
  contentURL.append("&Relationship=");
  contentURL.append(emxGetParameter(request,"Relationship"));
  contentURL.append("&policy=");
  contentURL.append(policy);
//Added for IR-069928V6R2012
  contentURL.append("&PrevJsp=");
  contentURL.append(PrevJsp);

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpmassebomupdate";

  StringBuffer roleList = new StringBuffer("role_DesignEngineer,");
  roleList.append("role_ECRChairman,");
  roleList.append("role_ECRCoordinator,");
  roleList.append("role_ECREvaluator,");
  roleList.append("role_ManufacturingEngineer,");
  roleList.append("role_OrganizationManager,");
  roleList.append("role_PartFamilyCoordinator,");
  roleList.append("role_ProductObsolescenceManager,");
  roleList.append("role_SeniorDesignEngineer,");
  roleList.append("role_SeniorManufacturingEngineer");


  fs.initFrameset("emxEngineeringCentral.DesignTOP.MassEBOMUpdate",
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxEngineeringCentralStringResource");
  fs.createFooterLink("emxFramework.Command.Previous",
                      "goBack()",
                      roleList.toString(),
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      0);
  fs.createFooterLink("emxFramework.Command.Done",
                      "checkInput()",
                      roleList.toString(),
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.closeWindow()",
                      roleList.toString(),
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);
  fs.writePage(out);

%>
