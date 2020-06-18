<%--  emxEngrCreateApplicationSpecifyAssociateMEPFS.jsp  -
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

// Specify URL to come in middle of frameset
String contentURL = "emxEngrCreateApplicationSpecifyAssociateMEP.jsp";

// add these parameters to each content URL, and any others the App needs
contentURL +="?";
String name ="";
String value="";
String param="";

// Loop through parameters and pass on to summary page
for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
  {
      name = (String) names.nextElement();
      value = emxGetParameter(request, name);
      param = "&" + name + "=" + value;
      contentURL += param;
  }
contentURL +="&showWarning=false";

// getting user entered values for attributes from page in to hashmap and store it in session

Map attrMap = (Map) session.getAttribute("attributeMap");
HashMap attributesMap = new HashMap();

java.util.Set keys = attrMap.keySet();

Iterator itr = keys.iterator();
while (itr.hasNext()){
   Map valueMap = (Map)attrMap.get((String)itr.next());
   String attrName = (String)valueMap.get("name");
   String attrValue = emxGetParameter(request,attrName);
   attributesMap.put(attrName,attrValue);
}

session.setAttribute("attributesMap",attributesMap);


contentURL = Framework.encodeURL(response, contentURL);

// Marker to pass into Help Pages, // icon launches new window with help frameset inside
String HelpMarker = "emxhelpapplicationpartcreate";

fs.initFrameset("emxEngineeringCentral.Part.SpecifyAssociatedMEP",
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

fs.setStringResourceFile("emxEngineeringCentralStringResource");

fs.createFooterLink("emxFramework.Command.Previous",
                      "goBack()",
                       "role_GlobalUser",
                       false,
                       true,
                       "common/images/buttonDialogPrevious.gif",
                      0);

fs.createFooterLink("emxFramework.Command.Done",
                      "goNext()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


fs.createFooterLink("emxFramework.Command.Cancel",
                      "cancel()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      5);

fs.writePage(out);

%>
