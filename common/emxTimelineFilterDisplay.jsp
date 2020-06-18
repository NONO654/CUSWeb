<%-- emxTimelineFilterDisplay.jsp

        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne,
        Inc.
        Copyright notice is precautionary only and does not evidence any actual or
        intended publication of such program.

        static const char RCSID[] = $Id: emxTimelineFilterDisplay.jsp.rca 1.5 Wed Oct 22 15:48:21 2008 przemek Experimental przemek $
 --%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<head>

<title>
</title>

<%@include file = "emxUIConstantsInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="javascript" src="../common/scripts/emxUITimeline.js"></script>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleListInclude.inc"%>
<%@include file = "../emxStyleFormInclude.inc"%>

<%
try {
    String timestamp = emxGetParameter(request, "timestamp");
    //Get the attribute filter list from the request
    String strAttributeFilterList = emxGetParameter(request, UITimeline.SETTING_ATTRIBUTE_FILTER_LIST);
    //Form the stringlist of the filter attributes
    StringList attFilterList = FrameworkUtil.split(strAttributeFilterList, UITimeline.FILTER_ATTRIBUTE_DELIMITER);
    attFilterList = UITimeline.getPropertyValues(context,attFilterList);
%>

<script type="text/javascript">

  function setFilterValues()
  {
   // Begin of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005>
   fieldValue = parent.window.getWindowOpener().getFieldValue("fromDate");

    if(fieldValue == "")
    {
      document.roadmapFilter.fromDate.value = "";
      document.roadmapFilter.fromDate_msvalue.value = "";
    } else {
      document.roadmapFilter.fromDate.value = parent.window.getWindowOpener().getFieldValue("fromDate");
      document.roadmapFilter.fromDate_msvalue.value = parent.window.getWindowOpener().getFieldValue("fromDate_msvalue");
    }

    fieldValue = parent.window.getWindowOpener().getFieldValue("toDate");

    if(fieldValue == "")
    {
      document.roadmapFilter.toDate.value = "";
      document.roadmapFilter.toDate_msvalue.value = "";
    } else {
      document.roadmapFilter.toDate.value = parent.window.getWindowOpener().getFieldValue("toDate");
      document.roadmapFilter.toDate_msvalue.value = parent.window.getWindowOpener().getFieldValue("toDate_msvalue");
    }
<%
  String attName = null;
  for(int i=0; i<attFilterList.size(); i++)
  {
    attName = (String) attFilterList.elementAt(i);
%>

fieldValue = parent.window.getWindowOpener().getFieldValue("att_<%=XSSUtil.encodeForJavaScript(context, attName)%>");
    if(fieldValue == "")
    {
      tmpElement = document.roadmapFilter.elements['att_<%=XSSUtil.encodeForJavaScript(context, attName)%>'];
      if (tmpElement !="" && tmpElement!=null && tmpElement !="undefined" ){
           for(j=0; j<tmpElement.length; j++) {
                    tmpElement[j].checked=false;
              }
       }
    } else {
        var checkHeader=true;
        tmpArr = split(fieldValue, "|");
        tmpElement = document.roadmapFilter.elements['att_<%=XSSUtil.encodeForJavaScript(context, attName)%>'];
        if (tmpElement !="" && tmpElement!=null && tmpElement !="undefined" ){
              for(j=0; j<tmpElement.length; j++)
              {
                if(stringArrayContains(tmpArr, tmpElement[j].value))    {
                  tmpElement[j].checked = true;
                   } else {
                  tmpElement[j].checked = false;
                  checkHeader=false;
                 }
              }
      //whether to check header or not
        if (checkHeader)
             {
               document.roadmapFilter.elements['att_<%=XSSUtil.encodeForJavaScript(context, attName)%>_filter'].checked=true;
            }
       }
    }
<%
  }
%>
 }
//End of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005>

</script>
</head>

<%
MapList roadmapStructure = (MapList) session.getAttribute(timestamp);
MapList milestoneTypeList = new MapList();
Iterator objectItr = roadmapStructure.iterator();
Map objectMap = null;
MapList milestoneMapList = null;
Map milestoneMap = null;
String displayName = null;
DateFormat dateFomat = DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale());
String disFromDate = "";
String disToDate = "";

while(objectItr.hasNext())
{
  objectMap = (Map) objectItr.next();
  milestoneMapList = (MapList) objectMap.get(UITimeline.SELECT_MILESTONES);

  for(int milestoneIndex=0; milestoneIndex<milestoneMapList.size(); milestoneIndex++)
  {
    milestoneMap = (Map) milestoneMapList.get(milestoneIndex);
    displayName = (String) milestoneMap.get(UITimeline.SELECT_DISPLAY_NAME);

    if(!milestoneTypeList.contains(displayName))
    {
      milestoneTypeList.add(milestoneMap);
    }
  }
}

milestoneTypeList.sort(UITimeline.SELECT_DISPLAY_NAME,
                                 "ascending",
                                 "string");
Locale local = request.getLocale();
String country = local.getCountry();
%>
<body>
<form name="roadmapFilter" method="post">
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr class="odd">

      <td><img src="images/utilSpacer.gif" height="1" width="5" border="0" /></td>
      <td valign="top">
        <table border="0" cellspacing="2" cellpadding="2">
          <tr>
            <td colspan="2" align="center" class="even" height="23" valign="bottom">
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr class="rule" height="1">
                  <td height="1"><img src="images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td colspan="3" height="23">
            <!--Begin of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005-->
               <b><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.Filter</emxUtil:i18n></b>
            <!--End of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005--->
            </td>
          </tr>
          <tr>
            <th colspan="2" align="center" height="18" width="0"><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.MilestoneDates</emxUtil:i18n></th>
          </tr>
          <tr class="even">
            <td  align="right" width="3%"><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.From</emxUtil:i18n></td>
            <td>
              <input type="text" name="fromDate" value="" size="8" readonly="readonly" />&nbsp;<a href="javascript:showCalendar('roadmapFilter', 'fromDate', '')"><img src="../common/images/iconSmallCalendar.gif" alt="Date Picker" border="0" /></a>&nbsp;
              <input type="hidden" name="fromDate_msvalue" value="" />
            </td>
          </tr>
          <tr class="even">
            <td align="right" width="3%"><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.To</emxUtil:i18n></td>
            <td>
              <input type="text" name="toDate" value="" size="8" readonly="readonly" />&nbsp;<a href="javascript:showCalendar('roadmapFilter', 'toDate', '')"><img src="../common/images/iconSmallCalendar.gif" alt="Date Picker" border="0" /></a>&nbsp;
              <input type="hidden" name="toDate_msvalue" value="" />
            </td>
          </tr>
        </table>
      </td>
<%
  AttributeType attType = null;
  StringList choiceList = null;
  StringList choiceDisplayList = null;
  String strAttrDisplayNameKey = "";
  String strAttrDisplayName = "";

  for(int i=0; i<attFilterList.size(); i++)
  {
    attName = (String) attFilterList.elementAt(i);
    strAttrDisplayNameKey = "emxFramework.Attribute."+ attName.replace(' ','_');
    strAttrDisplayName = i18nNow.getI18nString(strAttrDisplayNameKey,"emxFrameworkStringResource",request.getHeader("Accept-Language") );
    attType = new AttributeType(attName);
    attType.open(context);
    choiceList = attType.getChoices(context);
    attType.close(context);
    if(choiceList != null){
        choiceDisplayList = i18nNow.getAttrRangeI18NStringList(attName,
                                                                                          choiceList,
                                                                                          request.
                                                                                           getHeader("Accept-Language"));
%>
      <td valign="top">
        <table border="0" cellspacing="2" cellpadding="2">
          <tr>
            <td colspan="2" align="center" class="even" height="23" valign="bottom">
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr class="rule" height="1">
                  <td height="1"><img src="images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="odd">
            <td colspan="2" class="even" height="23">
            <!--Begin of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005-->
              <input type="checkbox" name="att_<%=XSSUtil.encodeForHTMLAttribute(context, attName)%>_filter" value="checkbox" onclick="doFilterCheckboxClick(this, 'att_<%=XSSUtil.encodeForJavaScript(context, attName)%>','roadmapFilter')" /> <b><emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Label.Filter</emxUtil:i18n></b>
            <!--End of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005-->
            </td>
          </tr>
          <tr>
            <th colspan="2" align="center" height="18" width="0"><xss:encodeForHTML><%=strAttrDisplayName%></xss:encodeForHTML></th>
          </tr>
<%
        String val = "";
        String displayVal = "";

        for(int choiceIndex=0; choiceIndex<choiceList.size(); choiceIndex++){
             val = (String) choiceList.elementAt(choiceIndex);
             displayVal = (String) choiceDisplayList.elementAt(choiceIndex);


%>
          <tr class="even">
            <td class="even" align="center" width="3%">
              <!--Begin of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005-->
              <input type="checkbox" name="att_<%=XSSUtil.encodeForHTMLAttribute(context, attName)%>" value="<%=val%>" onclick="doFilterItemCheckboxClick(this,'roadmapFilter')" /><!-- XSSOK -->
              <!--End of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005-->
            </td>
            <td class="even""><!-- //XSSOK -->
              &nbsp;<%=displayVal%>
            </td>
          </tr>
<%
        }
%>
        </table>
      </td>
<%
   }
 }
}//try
catch (Exception ex) {
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}//catch
%>
    </tr>
  </table>

</form>

<script type="text/javascript">

  setFilterValues();

  turnOffProgress();

</script>
</BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>
