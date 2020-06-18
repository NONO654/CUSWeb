<%--  emxEngrCreateApplicationPartAddAttributesFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ include file    ="../emxUIFramesetUtil.inc"%>
<%@ include file    ="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

       String type           = DomainConstants.TYPE_APPLICATION_PART;

    String partNum        = emxGetParameter(request, "partNum");
    String revision       = emxGetParameter(request, "revision");
    String policy         = emxGetParameter(request, "policy");
    String rev            = emxGetParameter(request, "rev");
    String Vault          = emxGetParameter(request, "Vault");
    String Owner          = emxGetParameter(request, "Owner");
    String description    = emxGetParameter(request, "description");
    String RDO            = emxGetParameter(request, "RDO");
    String RDOId          = emxGetParameter(request, "RDOOID");
    String locName        = emxGetParameter(request, "loc");
  String locId          = emxGetParameter(request, "locOID");
    String defaultLocation = "HostCompany";

    if (locId == null || "null".equals(locId) || locName == null || locName.equals(defaultLocation))
    {
        locId = "";
    }

    String checkAutoName  = emxGetParameter(request,"checkAutoName");
    if(checkAutoName == null || "null".equals(checkAutoName)){
        checkAutoName="";
    }

    String objectId  = emxGetParameter(request,"objectId");
    if(objectId==null || "null".equals(objectId)){
       objectId="";
    }

    String initSource = emxGetParameter(request,"initSource");
    String jsTreeID = emxGetParameter(request,"jsTreeID");
    String suiteKey = emxGetParameter(request,"suiteKey");
    String SuiteDirectory = emxGetParameter(request,"SuiteDirectory");
    String assemblyPartId = emxGetParameter(request,"assemblyPartId");

    if(jsTreeID==null || "null".equals(jsTreeID)){
       jsTreeID="";
    }

    if(initSource == null){
       initSource = "";
    }

    Properties createPartprop = new Properties();
       createPartprop.setProperty("type_KEY",type);
       createPartprop.setProperty("partNum_KEY",partNum);
       createPartprop.setProperty("revision_KEY",revision);
       createPartprop.setProperty("policy_KEY",policy);
       createPartprop.setProperty("rev_KEY",rev);
       createPartprop.setProperty("Vault_KEY",Vault);
       createPartprop.setProperty("Owner_KEY",Owner);
       createPartprop.setProperty("description_KEY",description);
       createPartprop.setProperty("RDO_KEY",RDO);
       createPartprop.setProperty("RDOId_KEY",RDOId);
       createPartprop.setProperty("checkAutoName_KEY",checkAutoName);
       createPartprop.setProperty("objectId_KEY",objectId);
       createPartprop.setProperty("locName_KEY",locName);
       createPartprop.setProperty("locId_KEY",locId);
       createPartprop.setProperty("suiteKey_KEY",suiteKey);
       createPartprop.setProperty("suiteDirectory_KEY",SuiteDirectory);
       createPartprop.setProperty("jsTreeID_KEY",jsTreeID);
       createPartprop.setProperty("assemblyPartId_KEY",assemblyPartId);

   session.putValue("createPartprop_KEY",createPartprop );



   // Specify URL to come in middle of frameset
   String contentURL = "emxEngrCreateApplicationPartAddAttributes.jsp";

   // add these parameters to each content URL, and any others the App needs
   String name ="";
   String value="";
   String param="";
   contentURL += "?";
   // Loop through parameters and pass on to summary page

   for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
   {
       name = (String) names.nextElement();
       value = emxGetParameter(request, name);

       param = "&" + name + "=" + value;
       contentURL += param;
   }

   contentURL = Framework.encodeURL(response, contentURL);

   // Marker to pass into Help Pages, // icon launches new window with help frameset inside
   String HelpMarker = "emxhelpapplicationpartcreate";

   /*String roleList = "role_DesignEngineer," + "role_ECRChairman," + "role_ECRCoordinator," +
                    "role_ECREvaluator," + "role_ManufacturingEngineer," + "role_OrganizationManager," +
                    "role_PartFamilyCoordinator," + "role_ProductObsolescenceManager," +
                    "role_SeniorDesignEngineer," + "role_SeniorManufacturingEngineer";*/
   String roleList ="role_GlobalUser";

   fs.initFrameset("emxEngineeringCentral.Part.CreateAppPartAttributes",
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

   fs.setStringResourceFile("emxEngineeringCentralStringResource");

   fs.createFooterLink("emxFramework.Command.Previous",
                      "goBack()",
                       roleList,
                       false,
                       true,
                       "common/images/buttonDialogPrevious.gif",
                      0);

   fs.createFooterLink("emxFramework.Command.Next",
                      "goNext()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      0);


   fs.createFooterLink("emxFramework.Command.Cancel",
                      "cancel()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      5);

   fs.writePage(out);

%>
