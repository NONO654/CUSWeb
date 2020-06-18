<%-- emxTimelineDisplay.jsp

        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne,
        Inc.
        Copyright notice is precautionary only and does not evidence any actual or
        intended publication of such program.

        static const char RCSID[] = $Id: emxTimelineDisplay.jsp.rca 1.11 Wed Oct 22 15:48:02 2008 przemek Experimental przemek $
 --%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants"%>

<html>
<head>
<%
  String timestamp = emxGetParameter(request, "timestamp");
  String language = request.getHeader("Accept-Language");
  String interval = emxGetParameter(request, "interval");
  String suiteKey = emxGetParameter(request, "suiteKey");

  String header = emxGetParameter(request, "header");
  String propertyFileName = EnoviaResourceBundle.getProperty(context, "eServiceSuite"+suiteKey+".StringResourceFileId");
  header = i18nNow.getI18nString(header, propertyFileName, language);
%>

<title><xss:encodeForHTML><%=header%></xss:encodeForHTML></title>
  <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>

  <script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUITooltips.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUIPage.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUITimeline.js"></script>
  <script type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
  <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
  <script type="text/javascript">
        addStyleSheet("emxUITimeline");
  </Script>

<script type="text/javascript">
<%
  String strShowMilestoneTypes = emxGetParameter(request, "showMilestoneTypes");
  String strFromDate = emxGetParameter(request, "fromDate");
  String strToDate = emxGetParameter(request, "toDate");
  String strFromDateMs = emxGetParameter(request, "fromDate_msvalue");
  String strToDateMs = emxGetParameter(request, "toDate_msvalue");
  StringList showMilestoneTypeList = FrameworkUtil.split(strShowMilestoneTypes, "|");
  String filterCommand = emxGetParameter(request, "filterCommand");
  Date fromDate = null;
  Date toDate = null;

  if(strShowMilestoneTypes == null){
      strShowMilestoneTypes = "";
  }

  try {
      if(strFromDateMs != null && strFromDateMs.length() != 0)
          fromDate = new Date(Long.parseLong(strFromDateMs));
      else
        strFromDateMs = "";

      if(strToDateMs != null && strToDateMs.length() != 0)
        toDate = new Date(Long.parseLong(strToDateMs));
      else
        strToDateMs = "";
    } catch (Exception ex) {
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
    }
  if(strFromDate == null)
    strFromDate = "";

  if(strToDate == null)
    strToDate = "";

  if(interval == null)
    interval = "quarters";

  if(interval.equals("quarters")) {
%>
  var objRoadmap = new emxUIRoadmap(emxUIRoadmap.INTERVAL_QUARTERS);
<%
  } else if(interval.equals("months")) {
%>
  var objRoadmap = new emxUIRoadmap(emxUIRoadmap.INTERVAL_MONTHS);
<%
  } else if(interval.equals("weeks")) {
%>
  var objRoadmap = new emxUIRoadmap(emxUIRoadmap.INTERVAL_WEEKS);
<%
  } else if(interval.equals("years")) {
%>
  var objRoadmap = new emxUIRoadmap(emxUIRoadmap.INTERVAL_YEARS);
<%
}
%>

  var objProduct = null;
  var milestone = null;
<%
  // start build roadmap.
  MapList roadmapStructure = (MapList) session.getAttribute(timestamp);

   HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);

  Map filterAttributeMap =
    UITimeline.getFilterAttributeMapList(requestMap);
  roadmapStructure =
    UITimeline.filter(roadmapStructure, showMilestoneTypeList, fromDate, toDate, filterAttributeMap);

  if(roadmapStructure.size() != 0)
  {

    Iterator objectItr = roadmapStructure.iterator();
    Map objectMap = null;
    String objectId = null;
    String displayName = null;
    String objectStatus = null;
    MapList detailsMapList = null;
    String imageUrl = null;
    String details = null;
    String currentMilestone = null;
    MapList milestoneMapList = null;
    Map milestoneMap = null;
    int milestonePos = 0;
    BusinessObject busObj = null;
    String moreMilestoneLeft = null;
    String moreMilestoneRight = null;

    while(objectItr.hasNext())
    {
     objectMap = (Map) objectItr.next();
     milestoneMapList = (MapList) objectMap.get(UITimeline.SELECT_MILESTONES);

     if(milestoneMapList != null && milestoneMapList.size() != 0)
     {
      objectId = (String) objectMap.get(DomainObject.SELECT_ID);
      displayName = (String) objectMap.get(UITimeline.SELECT_DISPLAY_NAME);
      currentMilestone = (String) objectMap.get(UITimeline.SELECT_CURRENT_MILESTONE);
      imageUrl = null;
      moreMilestoneLeft = (String) objectMap.get(UITimeline.SELECT_MORE_MILESTONES_LEFT);
      moreMilestoneRight = (String) objectMap.get(UITimeline.SELECT_MORE_MILESTONES_RIGHT);
      milestoneMapList = (MapList) objectMap.get(UITimeline.SELECT_MILESTONES);
      milestonePos = 0;

      if(displayName == null)
      {
        displayName = "";
      }

      //Begin of modify by Infosys for Bug# 303214 on 26 Apr 05
      String imageObjId = null;

      DomainObject domParent = DomainObject.newInstance(context, objectId);

      String strPrimaryImageRel = PropertyUtil.getSchemaProperty(context,
                                                                 DomainSymbolicConstants.SYMBOLIC_relationship_PrimaryImage);
      String strPrimaryImageId = domParent.getInfo(context,
                                                   "from[" + strPrimaryImageRel + "].to.id");
      // Modified by Infosys for Bug # 316685 Date- March 20, 2006
      String strSymbolicFormat = EnoviaResourceBundle.getProperty(context, "emx"+suiteKey+".Image.Timeline.Format");
      String strFormat = PropertyUtil.getSchemaProperty(context, strSymbolicFormat);

      if(strPrimaryImageId != null)
      {
          DomainObject domImage = DomainObject.newInstance(context, strPrimaryImageId);
          String strFile = domImage.getInfo(context, "format["+strFormat+"].file.name");

          ArrayList fileList = new ArrayList();
          BusinessObjectProxy bop = new BusinessObjectProxy(strPrimaryImageId, strFormat, strFile, false, false);
          fileList.add(bop);
          HashMap imageData = UINavigatorUtil.getImageData(context, pageContext);
          String[] urls = com.matrixone.fcs.common.ImageRequestData.getImageURLS(context, fileList, imageData);
          String fileURL = urls[0];
          imageUrl = fileURL;

      }
      else
      {
          imageUrl = (String)objectMap.get(UITimeline.SELECT_IMAGE_URL);
      }

       if(imageUrl != null && !imageUrl.equals("") && !imageUrl.equalsIgnoreCase("null")){
          imageUrl = UINavigatorUtil.parseHREF(context,
                                    imageUrl,
                                    suiteKey);
        }
        //End of modify by Infosys for Bug# 303214 on 26 Apr 05
%>
  //create a Roadmap Object on Timeline
//XSSOK
  objProduct = new emxUIRoadmapProduct("<xss:encodeForJavaScript><%=(String)objectMap.get(DomainConstants.SELECT_NAME)%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=displayName%></xss:encodeForJavaScript>","<%=imageUrl%>",
                            "javascript:showDetailsPopup('../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>')");
<%
        if(moreMilestoneLeft != null && moreMilestoneLeft.equals("true"))
        {
%>
  objProduct.setMoreMilestonesLeft(true);
<%
        }
        if(moreMilestoneRight != null && moreMilestoneRight.equals("true"))
        {
%>
  objProduct.setMoreMilestonesRight(true);
<%
        }
        detailsMapList = (MapList) objectMap.get(UITimeline.SELECT_DETAILS);
        if(detailsMapList != null)
        {
          details = UITimeline.formatDetails(context,
        		                  null,
                                  detailsMapList,
                                  language,
                                  suiteKey);
   //Added by Infosys for Bug#303754 on 5/3/2005
    details=UITimeline.getStringForHTML(details);
%>
  objProduct.setTooltip("<%=details%>");//XSSOK
<%
        }

        for(int milestoneIndex=0; milestoneIndex<milestoneMapList.size(); milestoneIndex++)
        {
          milestoneMap = (Map) milestoneMapList.get(milestoneIndex);
          displayName = (String) milestoneMap.get(UITimeline.SELECT_DISPLAY_NAME);
          objectId = (String) milestoneMap.get(DomainObject.SELECT_ID);

          if(displayName.equals(currentMilestone))
          {
            milestonePos = milestoneIndex;
          }

          //Begin of modify by Infosys for Bug# 303214 on 26 Apr 05
          String milestoneImageURL =  (String)milestoneMap.get(UITimeline.SELECT_IMAGE_URL);
          
        if(milestoneImageURL != null && !milestoneImageURL.equals("") && !milestoneImageURL.equalsIgnoreCase("null")){
            milestoneImageURL = UINavigatorUtil.parseHREF(context,
                                                        milestoneImageURL,
                                                        suiteKey);
        }
        //End of modify by Infosys for Bug# 303214 on 26 Apr 05

%>
	//XSSOK
  milestone =   new emxUIRoadmapMilestone("<%=milestoneImageURL%>",
                              "<xss:encodeForJavaScript><%=displayName%></xss:encodeForJavaScript>",
                              "<xss:encodeForJavaScript><%=(String) milestoneMap.get(UITimeline.SELECT_MILESTONE_DATE)%></xss:encodeForJavaScript>",
                              "javascript:showDetailsPopup('../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>')");
<%
          detailsMapList = (MapList) milestoneMap.get(UITimeline.SELECT_DETAILS);
          if(detailsMapList != null)
          {
            details = UITimeline.formatDetails(context,
            		                displayName,
                                    detailsMapList,
                                    language,
                                    suiteKey);
  //Added by Infosys for Bug#303754 on 5/3/2005
   details=UITimeline.getStringForHTML(details);
%>
  milestone.setTooltip("<%=details%>");//XSSOK
<%
          }
%>
  objProduct.addMilestone(milestone);
<%
        }
%>
  //set the product information to anchor to the second milestone (first milestone
  //is in position 0, second milestone is in position 1).
  //XSSOK
  objProduct.setMilestoneAnchor(<%=milestonePos%>);

  objRoadmap.addItem(objProduct);
<%
      }
    }
%>
  //set the page layout
  var objLayout = new emxUIRoadmapLayout(objRoadmap);
  page.setLayout(objLayout);
<%
  }
%>
  //Standard Toolbar Code
  objToolbar = new emxUIToolbar(emxUIToolbar.MODE_NORMAL);

  objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionRefresh.png", "<emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Button.Reset</emxUtil:i18n>", "javascript:resetRoadmap()"));
<%
Map filterCommandMap = null;
if(filterCommand != null & filterCommand.length() !=0)
{
  filterCommandMap = (Map) UIMenu.getCommand(context, filterCommand);
  String filterUrl = "";
  if(filterCommandMap!=null){
  filterUrl = UITimeline.getFilterUrl(context,filterCommandMap);
  }
%>
  objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, "iconActionFilter.png", "<emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Button.Filter</emxUtil:i18n>", "javascript:showFilter(\"<%=filterUrl%>\",\"<xss:encodeForJavaScript><%=timestamp%></xss:encodeForJavaScript>\",\"<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>\")"));
<%
}
  //Begin of Add by Infosys for Bug 311760 on 12/1/2005
  //Modified Help url for IR-045929V6R2011 STARTS
  String strHelpURL = "../doc/"+suiteKey.toLowerCase()+"/"+langStr+"/ENOHelp.htm?context="+suiteKey.toLowerCase()+"&topic=emxhelptimeline";
  //Modified Help url for IR-045929V6R2011 ENDS
  String sHelpMarker = "emxhelptimeline";
  String appdir = UINavigatorUtil.getRegisteredDirectory(context,suiteKey);
%>

  objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", "<emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Button.Help</emxUtil:i18n>", "javascript:openHelp('<%=sHelpMarker%>', '<%=appdir%>', '<%=langStr%>', '<%=langOnlineStr%>', '<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>')"));  //End of Add by Infosys for Bug 311760 on 12/1/2005
  page.addEventHandler("load", function () { toolbars.init("divToolbar");});
</script>

</head>
<body class='no-footer'>
<div id="pageHeadDiv">
  <form name="roadmap" method="post">
   <table>
     <tr>
   <td class="page-title">
      <h2><xss:encodeForHTML><%=header%></xss:encodeForHTML></h2>
    </td>
        <td class="functions">
            <table>
                <tr>
                    <td>
                    </td>
                </tr>
            </table>
        </td>
        </tr>
      </table>

      <div class="toolbar-container">
        <div class="toolbar-frame" id="divToolbar"><div id="divRoadmapControls" class="toolbar-panel">
          <table border="0" cellpadding="0" cellspacing="0">
            <tr>
              <td class="toolbar-panel-label"><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.View</emxUtil:i18n></td>
                <td class="toolbar-panel-input">
                  <select name="interval" onchange="document.forms[0].submit()">
                    <option value="weeks" <%if(interval.equals("weeks")) out.print("selected");%>><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.Weeks</emxUtil:i18n></option>
                    <option value="months" <%if(interval.equals("months")) out.print("selected");%>><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.Months</emxUtil:i18n></option>
                    <option value="quarters" <%if(interval.equals("quarters")) out.print("selected");%>><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.Quarters</emxUtil:i18n></option>
                    <option value="years" <%if(interval.equals("years")) out.print("selected");%>><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.Years</emxUtil:i18n></option>
                  </select>
                </td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>
<div id="divPageBody">
<%
if(roadmapStructure.size() == 0)
{
%>
<table border="0" cellpadding="0" cellspacing="0" align="center">
<tr><td><emxUtil:i18n localize="i18nId">emxFramework.Error.NoObjects</emxUtil:i18n></td></tr>
</table>
<%
}
%>

    <input type="hidden" name=interval value="<xss:encodeForHTMLAttribute><%=interval%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=timestamp value="<xss:encodeForHTMLAttribute><%=timestamp%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=suiteKey value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=showMilestoneTypes value="<xss:encodeForHTMLAttribute><%=strShowMilestoneTypes%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=fromDate value="<xss:encodeForHTMLAttribute><%=strFromDate%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=toDate value="<xss:encodeForHTMLAttribute><%=strToDate%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=fromDate_msvalue value="<xss:encodeForHTMLAttribute><%=strFromDateMs%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name=toDate_msvalue value="<xss:encodeForHTMLAttribute><%=strToDateMs%></xss:encodeForHTMLAttribute>" />

<%
if(filterCommandMap != null)
{
  Map settings = (Map) filterCommandMap.get("settings");
  String strFilterAttList = (String) settings.get(UITimeline.SETTING_ATTRIBUTE_FILTER_LIST);
  StringList filterAttList = FrameworkUtil.split(strFilterAttList, UITimeline.FILTER_ATTRIBUTE_DELIMITER);
  filterAttList = UITimeline.getPropertyValues(context,filterAttList);
  String attName = null;
  String attValue = null;
  for(int i=0; i<filterAttList.size(); i++)
  {
    attName = (String) filterAttList.elementAt(i);
    attValue = emxGetParameter(request, "att_"+attName);
    if(attValue == null)
      attValue = "";
%>
    <input type="hidden" name="att_<%=XSSUtil.encodeForHTMLAttribute(context, attName)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, attValue)%>" />
<%
  }
}
%>
  </form>
</div>
  <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
