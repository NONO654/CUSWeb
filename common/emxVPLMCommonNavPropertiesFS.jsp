<%--  emxVPLMCommonNavPropertiesFS.jsp --%>
<%@include file="../emxUIFramesetUtil.inc"%>

<%
    framesetObject fs = new framesetObject();

	String initSource = emxGetParameter(request,"initSource");
    if (initSource == null){
        initSource = "";
    }

    String jsTreeID = emxGetParameter(request,"jsTreeID");
    String suiteKey = emxGetParameter(request,"suiteKey");
  
    // ----------------- Do Not Edit Above ------------------------------
 
    String objectId = emxGetParameter(request,"objectId");

    // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer(100);
    contentURL.append("emxVPLMCommonNavProperties.jsp");
    //contentURL.append("emxDynamicAttributesSummary.jsp");
  
    // add these parameters to each content URL, and any others the App needs
    contentURL.append("?suiteKey=");
    contentURL.append(suiteKey);
    contentURL.append("&initSource=");
    contentURL.append(initSource);
    contentURL.append("&jsTreeID=");
    contentURL.append(jsTreeID);
    contentURL.append("&objectId=");
    contentURL.append(objectId);


    // Page Heading - Internationalized
    //String PageHeading = "emxFramework.Common.PropertiesPageHeading";
    String PageHeading = "Properties";
    // Marker to pass into Help Pages
    // icon launches new window with help frameset inside
    String HelpMarker = "emxhelptriggerparameterproperties";
  
    fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,false,false);
    //fs.setStringResourceFile("emxProductEditorStringResource");
    fs.setStringResourceFile("emxFrameworkStringResource");
    fs.setObjectId(objectId);

    // ----------------- Do Not Edit Below ------------------------------

    fs.writePage(out);

%>
