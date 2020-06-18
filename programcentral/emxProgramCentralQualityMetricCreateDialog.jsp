<%-- emxProgramCentralQualityMetricCreateDialogMain.jsp

  Page to create a Quality Metric

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralQualityMetricCreateDialog.jsp.rca 1.22 Wed Oct 22 15:49:26 2008 przemek Experimental przemek $

--%>

<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../emxJSValidation.inc"%>

<%
  com.matrixone.apps.program.Quality quality =
      (com.matrixone.apps.program.Quality) DomainObject.newInstance(context,
      DomainConstants.TYPE_QUALITY, "PROGRAM");

  com.matrixone.apps.program.QualityMetricRelationship qualityMetric = null;

  String qualityId = emxGetParameter(request, "objectId");
  quality.setId(qualityId);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Determine whether parent quality is discrete or continous
  boolean isDiscrete = false;
  boolean isContinuous = false;
  String qualityType = quality.getInfo(context, quality.SELECT_QUALITY_TYPE);
  if ("Discrete".equals(qualityType)) {
    isDiscrete = true;
  }
  else {
    isContinuous = true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Gather options for source select (can only have one metric of each option
  //get attribute name
  String language            = request.getHeader("Accept-Language");
  String  MetricSourceAttrStr = PropertyUtil.getSchemaProperty(context, "attribute_MetricSource");
  StringList sourceValueRangeList  = ProgramCentralUtil.getAttrRangeStringList(context, MetricSourceAttrStr);
  Collections.reverse(sourceValueRangeList);
  StringList sourceRangeList       = i18nNow.getAttrRangeI18NStringList(MetricSourceAttrStr, sourceValueRangeList, language);

  //Remove source options that have already been create
  StringList relSelects = new  StringList(11);
  String relWhere = "";
  relSelects.add(qualityMetric.SELECT_METRIC_SOURCE);
  MapList MetricList = quality.getQualityMetrics(context, relSelects, relWhere);
  Iterator MetricListItr = MetricList.iterator();

%>

<html>
  <body class="white">
    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <form name="QualityMetricCreate" method="post" onsubmit="submitFormCreate();return false">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="isDiscrete" value="<xss:encodeForHTMLAttribute><%= isDiscrete %></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isContinuous" value="<xss:encodeForHTMLAttribute><%= isContinuous %></xss:encodeForHTMLAttribute>" />

      <table border="0" width="100%">
        <tr>
          <td nowrap="nowrap" class="label" width="30%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Name</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <framework:i18n localize="i18nId">emxProgramCentral.Route.AutoName</framework:i18n>
          </td>
        </tr>
        <tr>
          <td nowrap="nowrap" class="labelRequired" width="30%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Source</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <framework:ifExpr expr="<%=sourceRangeList.size() != 0%>">
              <select name="QualityMetricSource">
           <%-- XSSOK--%>  
                  <framework:optionList optionList="<%=sourceRangeList%>"  valueList="<%=sourceValueRangeList%>"  selected='<%=(String)sourceRangeList.firstElement()%>' />
               </select>
            </framework:ifExpr>
          </td>
        </tr>
        <!-- Columns only displayed if Quality data type is Continous -->
        <framework:ifExpr expr="<%=isContinuous == true%>">
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="15%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.Mean</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricMean" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.Mean</framework:i18n>" size="15" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="15%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.StandardDeviation</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricStandardDeviation" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.StandardDeviation</framework:i18n>" size="15" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="15%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.UpperSpecLimit</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricUpperSpecLimit" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.UpperSpecLimit</framework:i18n>" size="15" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="15%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.LowerSpecLimit</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricLowerSpecLimit" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.LowerSpecLimit</framework:i18n>" size="15" />
            </td>
          </tr>
        </framework:ifExpr>
        <!-- Columns only displayed if Quality data type is discrete -->
        <framework:ifExpr expr="<%=isDiscrete == true%>">
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="15%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.DPMO</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricDPMO" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.DPMO</framework:i18n>" size="15" />
            </td>
          </tr>
          <tr>
            <td nowrap="nowrap" class="labelRequired" width="15%">
              <framework:i18n localize="i18nId">emxProgramCentral.Common.DPU</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricDPU" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.DPU</framework:i18n>" size="15" />
            </td>
          </tr>
        </framework:ifExpr>
        <tr>
          <td nowrap="nowrap" class="labelRequired" width="15%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Sigma</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
              <input type="text" name="QualityMetricSigma" id="<framework:i18n localize="i18nId">emxProgramCentral.Common.Sigma</framework:i18n>" size="15" />
          </td>
        </tr>
        <tr>
          <td nowrap="nowrap" class="label" width="30%">
            <framework:i18n localize="i18nId">emxProgramCentral.Common.Comments</framework:i18n>
          </td>
          <td nowrap="nowrap" class="field">
             <textarea name="QualityMetricComments" rows="4" cols="30"></textarea>
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
      <input type="hidden" name="validation_QualityMetricComments" value="string optional" />
      <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />

    </form>

  <script language="javascript" type="text/javaScript">
  <!-- hide JavaScript from non-JavaScript browsers
  //<![CDATA[

    if(parent.frames[0].document.progress) {
      parent.frames[0].document.progress.src = "../common/images/utilSpacer.gif";
    }

    function submitFormCreate() {
      f = document.QualityMetricCreate;
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
            if( trim(fields[i].value)== "")
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

      f.action="emxProgramCentralQualityMetricProcess.jsp?action=create&qualityId=<%= XSSUtil.encodeForURL(context,qualityId) %>";
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
          alert(formField.id + " <emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeAnInteger</emxUtil:i18nScript>");
          formField.focus();
          return false;
        } else if(formField.value % 1 != 0 || formField.value < 0){
          alert(formField.id + " <emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeAnPositiveInteger</emxUtil:i18nScript>");
          formField.focus();
          return false;
        } else if(formField.value > 2147483647){
          alert(formField.id + " <emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeSmallerThan</emxUtil:i18nScript>");
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
          alert(formField.id + " <emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeReal</emxUtil:i18nScript>");
          formField.focus();
          return false;
        } else if(formField.value > 2147483647){
          alert(formField.id + " <emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeSmallerThan</emxUtil:i18nScript>");
          formField.focus();
          return false;
        }
        return true;
      }
      return false;
    }

//added for the bug 338401
  function trim (textBox) {
      while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
        textBox = textBox.substring(0,textBox.length - 1);
      while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
        textBox = textBox.substring(1,textBox.length);
        return textBox;
    }
//till here

    //Stop hiding here -->//]]>
  </script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
