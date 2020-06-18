<%-- emxProgramCentralQualityMetricProcess.jsp

  Performs an action on a quality concering metrics (add, edit, remove)

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralQualityMetricProcess.jsp.rca 1.15 Wed Oct 22 15:49:27 2008 przemek Experimental przemek $";

--%>
<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%
  com.matrixone.apps.program.Quality quality =
      (com.matrixone.apps.program.Quality) DomainObject.newInstance(context,
      DomainConstants.TYPE_QUALITY, "PROGRAM");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Get parameters from URL and FormBean
  String qualityId         = emxGetParameter(request, "qualityId");
  String metricId          = emxGetParameter(request, "metricId");
  String isDiscrete        = emxGetParameter(request, "isDiscrete");
  String isContinuous      = emxGetParameter(request, "isContinuous");
  String action            = emxGetParameter(request, "action");
  String formKey           = emxGetParameter(request, "formKey");
  String jsTreeId          = emxGetParameter(request, "jsTreeId");

  String jsTreeIdValue     = null;
  if (jsTreeId!=null && !jsTreeId.equals("null")){
    jsTreeIdValue = jsTreeId;
  }
  if (jsTreeId == null) {
   jsTreeId = "";
  }

  // get current person - this will become the originator
  com.matrixone.apps.common.Person person = new com.matrixone.apps.common.Person();
  String originatorName = context.getUser();

  com.matrixone.apps.program.QualityMetricRelationship qualityMetric = null;
  com.matrixone.apps.domain.DomainRelationship domainRelationship = null;


  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // start action processes
  try {
    // start a write transaction and lock business object
    ContextUtil.startTransaction(context, true);

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Create and edit Process
    if ("create".equals(action) || "edit".equals(action)) {
      quality.setId(qualityId);
      domainRelationship = new com.matrixone.apps.domain.DomainRelationship(metricId);
      String metricSource = (String)emxGetParameter(request, "QualityMetricSource");
      // Make an attribute map for the new metric
      HashMap metricMap = new HashMap(8);
      // Do not edit with hardcoded value in edit page
      String isGoal = emxGetParameter(request, "isGoal");
      if(isGoal == null || !"true".equals(isGoal))
      {
        metricMap.put(qualityMetric.ATTRIBUTE_METRIC_SOURCE, metricSource);
      }
      metricMap.put(qualityMetric.ATTRIBUTE_SIGMA, (String)emxGetParameter(request, "QualityMetricSigma"));
      metricMap.put(qualityMetric.ATTRIBUTE_COMMENTS, (String)emxGetParameter(request, "QualityMetricComments"));
      // Attributes common to only discrete
      if ("true".equals(isDiscrete)) {
        metricMap.put(qualityMetric.ATTRIBUTE_DPMO, (String)emxGetParameter(request, "QualityMetricDPMO"));
        metricMap.put(qualityMetric.ATTRIBUTE_DPU, (String)emxGetParameter(request, "QualityMetricDPU"));
      }
      // Attributes common to only continuous
      if ("true".equals(isContinuous)) {
        metricMap.put(qualityMetric.ATTRIBUTE_MEAN, (String)emxGetParameter(request, "QualityMetricMean"));
        metricMap.put(qualityMetric.ATTRIBUTE_STANDARD_DEVIATION, (String)emxGetParameter(request, "QualityMetricStandardDeviation"));
        metricMap.put(qualityMetric.ATTRIBUTE_UPPER_SPEC_LIMIT, (String)emxGetParameter(request, "QualityMetricUpperSpecLimit"));
        metricMap.put(qualityMetric.ATTRIBUTE_LOWER_SPEC_LIMIT, (String)emxGetParameter(request, "QualityMetricLowerSpecLimit"));
      }
      
      //Get internationilezed string for controlled
      String propertyFile = "emxProgramCentralStringResource";
      String propertyKey  = "emxProgramCentral.Common.Controlled";
      i18nNow i18nnow = new i18nNow();
      String language = request.getHeader("Accept-Language");
      String controlled = EnoviaResourceBundle.getProperty(context, "ProgramCentral", propertyKey, "en-us");
      
      // If action is add
      if ("create".equals(action)) {
        // two attributes that need to be set only for create
         metricMap.put(qualityMetric.ATTRIBUTE_ORIGINATOR, originatorName);
        
        quality.addQualityMetric(context, metricMap); 
        
        // if new Quality Metric is "Controlled" promote Quality to "Controlled"
        if(metricSource.equals(controlled)) {
          quality.promote(context);
        }
      }  // end create
      else {       // else action is edit
        domainRelationship.setAttributeValues(context, metricMap);
        
        // if Quality Metric is edited to "Controlled" promote Quality to "Controlled"
        if(metricSource.equals(controlled)) {
          quality.promote(context);
        }
      } // end edit
    } // end create/edit

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Delete Process
    else if ("delete".equals(action)) {
      qualityId = emxGetParameter(request, "objectId");
      quality.setId(qualityId);
      String[] metricIdArr = emxGetParameterValues(request,"emxTableRowId");
      if(metricIdArr != null && metricIdArr.length > 0){
          for(int i=0;i<metricIdArr.length;i++){
              metricId = metricIdArr[i].substring(0,metricIdArr[i].indexOf("|"));
              quality.deleteQualityMetric(context, metricId);
          }
      }
    } // end Delete

   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // commit the data
    ContextUtil.commitTransaction(context);
  } catch (Exception e) {
    ContextUtil.abortTransaction(context);
    throw e;
  }
%>
<html>
  <body class="white">
  <form name="finishAction" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>  
    <input type="hidden" name="formKey" value="<xss:encodeForHTMLAttribute><%=formKey%></xss:encodeForHTMLAttribute>" />
    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" type="text/javaScript">//<![CDATA[
     // <!-- hide JavaScript from non-JavaScript browsers
        var action = "<%= XSSUtil.encodeForJavaScript(context,action) %>";
           if (action == "edit") 
           {
        	   parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
        	   parent.window.closeWindow();
           }
           else if(action == "create" )
           {
            parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
           parent.window.closeWindow();
           location = window.reload();
           }
           else 
           {
           parent.document.location.href=parent.document.location.href;
        }
      // Stop hiding here -->//]]>

    </script>
  </form>
</html>
