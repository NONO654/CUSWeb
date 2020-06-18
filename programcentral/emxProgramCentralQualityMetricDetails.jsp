<%--
  emxpProgramCentralQualityMetricDetails.jsp

  Views the details for the given quality metric.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralQualityMetricDetails.jsp.rca 1.9 Wed Oct 22 15:49:22 2008 przemek Experimental przemek $";

--%>
<%@include file = "./emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  com.matrixone.apps.program.Quality quality =
      (com.matrixone.apps.program.Quality) DomainObject.newInstance(context,
      DomainConstants.TYPE_QUALITY, "PROGRAM");

  com.matrixone.apps.program.QualityMetricRelationship metric = null;
  
  //Gather all metrics for the CTQ
  String objectId   = emxGetParameter(request,"objectId");
  String qualityId  = emxGetParameter(request,"qualityId");

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // get all attributes for metric relationship
  Map infoMap = metric.getAttributeMap(context, objectId); // not static...this is why metric is a bean

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
%>

    <form name="QualityDetail" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <table border="0" width="100%">
        <tr>
          <td>
            <table border="0" width="100%">

              <tr>
                <td width="30%" align="left" class="label">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Name</emxUtil:i18n>
                </td>
                <td colspan="3" class="field" align="left">
                 <xss:encodeForHTML><%= metricName %></xss:encodeForHTML> 
                </td>
              </tr>
              <tr>
                <td width="30%" align="left" class="label">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Source</emxUtil:i18n>
                </td>
                <td colspan="3" class="field" align="left">
                   <xss:encodeForHTML><%= infoMap.get(metric.ATTRIBUTE_METRIC_SOURCE) %></xss:encodeForHTML>    
                </td>
              </tr>
              <!-- Columns only displayed if Quality data type is Continuous -->
              <%-- XSSOK--%> 
                  <framework:ifExpr expr="<%=isContinuous%>">
                <tr>
                  <td width="30%" align="left" class="label">
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Mean</emxUtil:i18n>
                  </td>
                  <td colspan="3" align="left" class="field">
                     <xss:encodeForHTML><%= infoMap.get(metric.ATTRIBUTE_MEAN) %></xss:encodeForHTML>  
                  </td>
                </tr>
                <tr>
                  <td width="30%" align="left" class="label">
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.UpperSpecLimit</emxUtil:i18n>
                  </td>
                  <td colspan="3" class="field" align="left">
                    <xss:encodeForHTML><%= infoMap.get(metric.ATTRIBUTE_UPPER_SPEC_LIMIT) %></xss:encodeForHTML>
                  </td>
                </tr>
                <tr>
                  <td width="30%" align="left" class="label">
                     <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.LowerSpecLimit</emxUtil:i18n>
                  </td>
                  <td colspan="3" class="field" align="left">
                     <xss:encodeForHTML><%= infoMap.get(metric.ATTRIBUTE_LOWER_SPEC_LIMIT) %></xss:encodeForHTML>
                  </td>
                </tr>
              </framework:ifExpr>
              <!-- Columns only displayed if Quality data type is discrete -->
             <%-- XSSOK--%> 
                <framework:ifExpr expr="<%=isDiscrete%>">
                <tr>
                  <td nowrap="nowrap" class="label" width="30%">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.DPMO</framework:i18n>
                  </td>
                  <td nowrap="nowrap" class="field">
                    <xss:encodeForHTML><%=infoMap.get(metric.ATTRIBUTE_DPMO)%></xss:encodeForHTML>
                  </td>
                </tr>
                <tr>
                  <td nowrap="nowrap" class="label" width="30%">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.DPU</framework:i18n>
                  </td>
                  <td nowrap="nowrap" class="field">
                    <xss:encodeForHTML><%=infoMap.get(metric.ATTRIBUTE_DPU)%></xss:encodeForHTML>
                  </td>
                </tr>
              </framework:ifExpr>
              <tr>
                <td width="30%" align="left" class="label">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Sigma</emxUtil:i18n>
                </td>
                <td colspan="3" class="field" align="left">
                  <xss:encodeForHTML><%= infoMap.get(metric.ATTRIBUTE_SIGMA) %></xss:encodeForHTML>
                </td>
              </tr>
              <tr>
                <td nowrap="nowrap" class="label" width="30%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.Comments</framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                  <xss:encodeForHTML><%=infoMap.get(metric.ATTRIBUTE_COMMENTS)%></xss:encodeForHTML>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </form>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
