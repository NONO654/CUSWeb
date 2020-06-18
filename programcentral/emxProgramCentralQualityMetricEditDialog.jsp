<%--

  emxProgramCentralQualityMetricEditDialogMain.jsp

  Modifies a quality metric.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralQualityMetricEditDialog.jsp.rca 1.20 Wed Oct 22 15:49:25 2008 przemek Experimental przemek $

--%>

<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../emxJSValidation.inc"%>

<%
  com.matrixone.apps.program.Quality quality =
      (com.matrixone.apps.program.Quality) DomainObject.newInstance(context,
      DomainConstants.TYPE_QUALITY, "PROGRAM");

  com.matrixone.apps.program.QualityMetricRelationship metric = null;
  // get values from the url
  String qualityId  = emxGetParameter(request, "qualityId");
  String metricId   = emxGetParameter(request, "metricId");

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //If the values are not passed in from the URL, then gather them
  if (qualityId == null || "".equals(qualityId)) {
    StringList relSelects = new StringList(1);
    relSelects.add(metric.SELECT_FROM_ID);
    String[] relationshipIds = {metricId};
    MapList MetricList = metric.getInfo(context, relationshipIds, relSelects);

    //Look through list and find from id
    Iterator MetricListItr = MetricList.iterator();
    while (MetricListItr.hasNext()) {
      Map metricMap = (Map) MetricListItr.next();
      qualityId = (String)metricMap.get(metric.SELECT_FROM_ID);
    } //end while metricListItr has next
  } //end if qualityId == null

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Gather info from quality
  quality.setId(qualityId);
  StringList busSelects = new StringList(2);
  busSelects.add(quality.SELECT_QUALITY_TYPE);
  busSelects.add(quality.SELECT_METRIC_NAME);
  Map qualityMap = quality.getInfo(context, busSelects);
  String qualityType = (String)qualityMap.get(quality.SELECT_QUALITY_TYPE);
  String metricName = (String)qualityMap.get(quality.SELECT_METRIC_NAME);

  // Determine whether parent quality is discrete or continous
  boolean isDiscrete = false;
  boolean isContinuous = false;
  // set the appropriate variables
  isDiscrete = ("Discrete".equals(qualityType));
  isContinuous = !isDiscrete;

  // get all attributes for metric relationship
  Map metricMap = metric.getAttributeMap(context, metricId);

  //
  i18nNow i18nnow = new i18nNow();
  String language            = request.getHeader("Accept-Language");
  String propertyFile = "emxProgramCentralStringResource";
  String goalKey = "emxProgramCentral.Common.Goal";
  String goal                = EnoviaResourceBundle.getProperty(context, "ProgramCentral", goalKey, language);
  String goalKeyValue        = EnoviaResourceBundle.getProperty(context, "ProgramCentral", goalKey, language);

  // Gather options for source select (can only have one metric of each option)
  //get attribute name
  String  MetricSourceAttrStr = PropertyUtil.getSchemaProperty(context, "attribute_MetricSource");
  StringList sourceValueRangeList  = ProgramCentralUtil.getAttrRangeStringList(context, MetricSourceAttrStr);
  StringList sourceRangeList       = i18nNow.getAttrRangeI18NStringList(MetricSourceAttrStr, sourceValueRangeList, language);

  //Remove source options that have already been create
  StringList relSelects = new StringList(11);
  String relWhere = "";
  relSelects.add(metric.SELECT_METRIC_SOURCE);
  MapList MetricList = quality.getQualityMetrics(context, relSelects, relWhere);
  Iterator MetricListItr = MetricList.iterator();
  while (MetricListItr.hasNext()) {
    Map allMetricsMap = (Map) MetricListItr.next();
    if(!((String)allMetricsMap.get(metric.SELECT_METRIC_SOURCE)).equals((String)metricMap.get(metric.ATTRIBUTE_METRIC_SOURCE)))
    {
       int index = sourceValueRangeList.indexOf((String)allMetricsMap.get(metric.SELECT_METRIC_SOURCE));
       if(index > -1)
          sourceRangeList.remove(index);
       sourceValueRangeList.remove((String)allMetricsMap.get(metric.SELECT_METRIC_SOURCE));
    }
  } //end while metricListItr has next

  // Internationalize the selected source so the drop down will default correctly.
  String selectedMetricSource = (String) metricMap.get(metric.ATTRIBUTE_METRIC_SOURCE);
  int selectedIndex = sourceValueRangeList.indexOf(selectedMetricSource);
  selectedMetricSource = (String) sourceRangeList.get(selectedIndex);

  // set the boolean isGoal
  boolean isGoal = (sourceRangeList.contains(goal));
%>

<html>
  <body class="white">
    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <form name="QualityMetricEdit" action="" method="post" onsubmit="submitFormEdit();return false">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <input type="hidden" name="isDiscrete" value="<xss:encodeForHTMLAttribute><%=isDiscrete %></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isContinuous" value="<xss:encodeForHTMLAttribute><%=isContinuous %></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="metricId" value="<%=XSSUtil.encodeForHTMLAttribute(context,metricId)%>" />
      <input type="hidden" name="qualityId" value="<%=XSSUtil.encodeForHTMLAttribute(context,qualityId)%>" />

      <table border="0" width="100%">
        <tr>
          <td nowrap="nowrap" class="label" width="30%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Name</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <xss:encodeForHTML><%=metricName%></xss:encodeForHTML>: <xss:encodeForHTML><%=metricMap.get(metric.ATTRIBUTE_TITLE)%></xss:encodeForHTML>
          </td>
        </tr>
        <tr>
          <framework:ifExpr expr="<%=!isGoal%>">
          <td nowrap="nowrap" class="labelRequired" width="30%">
          </framework:ifExpr>
          <framework:ifExpr expr="<%=isGoal%>">
          <td nowrap="nowrap" class="label" width="30%">
          </framework:ifExpr>
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Source</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <framework:ifExpr expr="<%=isGoal%>">
              <%=goal%><input type="hidden" name="QualityMetricSource" value="<%=goalKeyValue%>" />
              <input type="hidden" name="isGoal" value="true" />
            </framework:ifExpr>
            <framework:ifExpr expr="<%=!isGoal%>">
              <select name="QualityMetricSource">
            <%-- XSSOK--%>
                    <framework:optionList optionList="<%=sourceRangeList%>" valueList="<%=sourceValueRangeList%>"  selected='<%=selectedMetricSource%>' />
              </select>
            </framework:ifExpr>
          </td>
        </tr>
        <!-- Columns only displayed if Quality data type is Continuous -->
        <%-- XSSOK--%> 
              <framework:ifExpr expr="<%=isContinuous%>">
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="30%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.Mean</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricMean" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.Mean</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_MEAN)%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="30%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.StandardDeviation</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricStandardDeviation" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.StandardDeviation</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_STANDARD_DEVIATION)%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="30%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.UpperSpecLimit</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricUpperSpecLimit" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.UpperSpecLimit</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_UPPER_SPEC_LIMIT)%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="30%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.LowerSpecLimit</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricLowerSpecLimit" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.LowerSpecLimit</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_LOWER_SPEC_LIMIT)%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
        </framework:ifExpr>
        <!-- Columns only displayed if Quality data type is discrete -->
   <%-- XSSOK--%>
               <framework:ifExpr expr="<%=isDiscrete%>">
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="30%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.DPMO</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricDPMO" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.DPMO</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_DPMO)%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="30%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.DPU</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricDPU" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.DPU</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_DPU)%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
        </framework:ifExpr>
        <tr>
          <td nowrap="nowrap" class="labelRequired" width="30%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Sigma</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricSigma" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.Sigma</framework:i18n>" size="15" value="<xss:encodeForHTMLAttribute><%=metricMap.get(metric.ATTRIBUTE_SIGMA)%></xss:encodeForHTMLAttribute>" />
          </td>
        </tr>
        <tr>
          <td nowrap="nowrap" class="labelRequired" width="30%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Comments</framework:i18n>
          </td>
          <td class="field" nowrap="nowrap">
            <textarea name="QualityMetricComments" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.Comments</framework:i18n>" rows="4" cols="30"><xss:encodeForHTML> <%=metricMap.get(metric.ATTRIBUTE_COMMENTS)%></xss:encodeForHTML></textarea>
          </td>
        </tr>
      </table>

      <input type="hidden" name="validation_QualityMetricSource" value="string required" />
      <input type="hidden" name="validation_QualityMetricDPMO" value="real required" />
      <input type="hidden" name="validation_QualityMetricDPU" value="integer required" />
      <input type="hidden" name="validation_QualityMetricSigma" value="real required" />
      <input type="hidden" name="validation_QualityMetricMean" value="real required" />
      <input type="hidden" name="validation_QualityMetricStandardDeviation" value="real required" />
      <input type="hidden" name="validation_QualityMetricUpperSpecLimit" value="real required" />
      <input type="hidden" name="validation_QualityMetricLowerSpecLimit" value="real required" />
      <input type="hidden" name="validation_QualityMetricComments" value="string required" />
      <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />

    </form>

  <script language="javascript" type="text/javascript">
  <!-- hide JavaScript from non-JavaScript browsers
  //<![CDATA[

    if(parent.frames[0].document.progress) {
      parent.frames[0].document.progress.src = "../common/images/utilSpacer.gif";
    }

    function submitFormEdit() {

      f = document.QualityMetricEdit;
      fields = f.elements;

      for(var i=0; i < fields.length; ++i)
      {
        if(beginsWith("QualityMetric",fields[i].name))
        {
          validationInfoString = "validation_" + fields[i].name;
          command = "validationInfo = f." + validationInfoString + ".value";
          eval(command);
          required = (validationInfo.indexOf("required") != -1);
          if(required)
          {
            if(fields[i].value == "")
            {
              alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.FillOutRequiredFields</emxUtil:i18nScript>");
              fields[i].focus();
              return;
            }
          }
          else
          {
            if(fields[i].value == ""){
              continue;
            }
          }
          if(validationInfo.indexOf("string") != -1)
          {
            continue;
          }
          else if(validationInfo.indexOf("integer") != -1)
          {
            if(!isInteger(fields[i])){
              return;
            }
          }
          else if(validationInfo.indexOf("real") != -1)
          {
            if(!isReal(fields[i])){
              return;
            }
          }
        }
      }

      f.action = "emxProgramCentralQualityMetricProcess.jsp?action=edit";
      startProgressBar(true);
      f.submit();
    }

    function beginsWith(startString, wholeString)
    {
      return (wholeString.indexOf(startString) == 0);
    }

    function isInteger(formField)
    {
      if (formField != null){
        if (!isNumeric(formField.value)) {
          alert(formField.id + " <emxUtil:i18nScript localize='i18nId'>emxProgramCentral.Common.ValueMustBeAnInteger</emxUtil:i18nScript>");
          formField.focus();
          return false;
        } else if(formField.value % 1 != 0 || formField.value < 0){
          alert(formField.id + " <emxUtil:i18nScript localize='i18nId'>emxProgramCentral.Common.ValueMustBeAnPositiveInteger</emxUtil:i18nScript>");
          formField.focus();
          return false;
        } else if(formField.value > 2147483647){
          alert(formField.id + " <emxUtil:i18nScript localize='i18nId'>emxProgramCentral.Common.ValueMustBeSmallerThan</emxUtil:i18nScript>");
          formField.focus();
          return false;
        }
        return true;
      }
      return false;
    }

    function isReal(formField)
    {
      if (formField != null){
        if (!isNumeric(formField.value)) {
          alert(formField.id + " <emxUtil:i18nScript localize='i18nId'>emxProgramCentral.Common.ValueMustBeReal</emxUtil:i18nScript>");
          formField.focus();
          return false;
        } else if(formField.value > 2147483647){
          alert(formField.id + " <emxUtil:i18nScript localize='i18nId'>emxProgramCentral.Common.ValueMustBeSmallerThan</emxUtil:i18nScript>");
          formField.focus();
          return false;
        }
        return true;
      }
      return false;
    }

  //Stop hiding here -->//]]>
  </script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
