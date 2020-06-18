<%--  emxpartECRAttributesDialogFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>


<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

/* Added Code written for Bug 322665 Begin */ 
session.setAttribute("flag","true");
session.setAttribute("newECREvaluator",emxGetParameter(request, "ECREvaluator"));
session.setAttribute("newResponsibleDesignEngineer",emxGetParameter(request, "ResponsibleDesignEngineer"));
session.setAttribute("RDO",emxGetParameter(request, "RDO"));
/* Added Code written for Bug 322665 End */


  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String objectId     = emxGetParameter(request,"objectId");
  String busId        = emxGetParameter(request,"busId");
  String ECREvaluatorAttr = PropertyUtil.getSchemaProperty(context, "attribute_ECREvaluator");
  String responsibleDesignEngineerAttr = PropertyUtil.getSchemaProperty(context,"attribute_ResponsibleDesignEngineer");

  if(busId==null || "".equals(busId) || "null".equals(busId)){
    busId="";
  }

  String suiteKey     = emxGetParameter(request,"suiteKey");
  String sContextMode = emxGetParameter(request, "sContextMode");
  if(sContextMode==null || "".equals(sContextMode) || "null".equals(sContextMode)){
    sContextMode="";
  }

  // Specify URL to come in middle of frameset
  String contentURL = "emxpartECRAttributesDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + objectId+"&sContextMode="+sContextMode;

  double tz = (new Double((String)session.getValue("timeZone"))).doubleValue();

  // Loop through parameters and pass on to summary page
  for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
  {
      String name = (String) names.nextElement();
      String value = emxGetParameter(request, name);
      if(name.equals("selectedType"))
      {
        String[] selPartIds = emxGetParameterValues(request, name);
        session.setAttribute("selectedType", selPartIds);
      }
 else if(name.equals("textECRType") || name.equals("hidProductLineId") || name.equals("selVault") || name.equals("selPolicy") || name.equals("description")){
         String param = "&" + name + "=" + value;
         contentURL += param;
        }
  }

  if(sContextMode.equals("true")){

    Properties createECRprop = new Properties();

    Map attr = (Map)session.getAttribute("attributeMap");

    String attrval;
    java.util.Set key = attr.keySet();
    Iterator itr1 = key.iterator();
    while (itr1.hasNext())
    {
       Map value    = (Map)attr.get((String)itr1.next());
       String attrName = (String)value.get("name");

       if (ECREvaluatorAttr != null && ECREvaluatorAttr.equals(attrName)) {
          attrval = emxGetParameter(request,"ECREvaluator");
       }
       else if (responsibleDesignEngineerAttr != null && responsibleDesignEngineerAttr.equals(attrName)) {
          attrval = emxGetParameter(request,"ResponsibleDesignEngineer");
       }
       else {
          attrval = emxGetParameter(request,attrName);
       }
       if(attrval==null){
         attrval="";
       }

       String sDataType = "";
       try {
          AttributeType attrTypeGeneric = new AttributeType(attrName);
          attrTypeGeneric.open(context);
          sDataType = attrTypeGeneric.getDataType();
          attrTypeGeneric.close(context);
       } catch (Exception ex ) {
          sDataType = "";
       }
       if (sDataType.equals("timestamp"))
       {
         if (attrval != null && !attrval.equals("null") && !attrval.equals("")) {
           attrval = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,attrval,tz,request.getLocale());
         }
       }
       createECRprop.setProperty(attrName+"_KEY",attrval);
      }

    String sProductLineId         = emxGetParameter(request,"hidProductLineId");
    String selVault               = emxGetParameter(request,"selVault");
    String selPolicy              = emxGetParameter(request,"selPolicy");
    String sDescription           = emxGetParameter(request,"description");

    createECRprop.setProperty("ProductLineId_KEY",sProductLineId);
    createECRprop.setProperty("SelVault_KEY",selVault);
    createECRprop.setProperty("SelPolicy_KEY",selPolicy);
    createECRprop.setProperty("Description_KEY",sDescription);

    session.putValue("createECRprop_KEY",createECRprop );

  }

  //contentURL = Framework.encodeURL(response, contentURL);

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.Common.DispCodes";

  // Marker to pass into Help Pages icon launches new window with help frameset inside
  String HelpMarker = "emxhelpecreditdispcodes";


  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

 // Role based access
 /*String roleList ="role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator,role_ComponentEngineer";*/
  String roleList ="role_GlobalUser";

  if (acc.has(Access.cRead)) {

  if(sContextMode.equals("true")){
    fs.createFooterLink("emxFramework.Command.Previous",
                              "goBack()",
                               roleList,
                               false,
                               true,
                               "common/images/buttonDialogPrevious.gif",
                      0);
  }

  fs.createFooterLink("emxEngineeringCentral.Button.Submit",
                      "submit()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);

  fs.createFooterLink("emxEngineeringCentral.Common.Cancel",
                      "parent.closeWindow()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      5);

  }

  fs.writePage(out);

%>





