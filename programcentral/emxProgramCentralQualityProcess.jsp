<%-- emxProgramCentralQualityProcess.jsp

  Performs an action on a quality (add, edit, remove)

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxProgramCentralQualityProcess.jsp.rca 1.19 Tue Oct 28 18:55:13 2008 przemek Experimental przemek $

--%>

<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%
  com.matrixone.apps.program.Quality quality =
      (com.matrixone.apps.program.Quality) DomainObject.newInstance(context,
      DomainConstants.TYPE_QUALITY, "PROGRAM");
  com.matrixone.apps.program.ProjectSpace project =
      (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
      DomainConstants.TYPE_PROJECT_SPACE, "PROGRAM");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Get parameters from URL
  String action         = (String) emxGetParameter(request, "action");
  String parentObjectId = null;
  if ("delete".equals(action)) 
  {
    parentObjectId = emxGetParameter(request,"parentOID"); 
  }
  else
  {
    parentObjectId = (String) emxGetParameter(request, "parentObjectId"); // for creating a new Quality
  }
  String formKey        = (String) emxGetParameter(request, "formKey");
  String[] qualities    = null;
  String objectId       = (String) emxGetParameter(request, "objectId"); // for editing an existing Quality
                                                                         // or deleting an existing Quality
  String portalMode1 = emxGetParameter(request, "portalMode");
  String portalMode = XSSUtil.encodeForJavaScript(context,portalMode1);  
                                                                         
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Start Action Processes
  try {
    // start a write transaction and lock business object
    quality.startTransaction(context, true);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Create
    if ("create".equals(action)) {
      // retrieve quality parameters off the session (from page 1 of 2)
      // page 2 of 2 values are retrieved using emxGetParameter(request, ...)
      HashMap createParams = (HashMap) session.getValue("CreateCTQParameters");
      session.removeValue("CreateCTQParameters");
      //Get dynamic attributes
      MapList attrMapList = (MapList) session.getAttribute("attributeMapCreate");
      session.removeAttribute("attributeMapCreate");

      // get all common attributes
      String qualityType           = (String) createParams.get("CTQDataType");
      String name                  = (String) createParams.get("CTQName");
      String problemStatement      = (String) createParams.get("CTQProblemStatement");
      String operationalDefinition = (String) createParams.get("CTQOperationalDefinition");
      String defectDefinition      = (String) createParams.get("CTQDefectDefinition");
      String goal                  = (String) createParams.get("CTQGoal");
      String qualityComment        = (String) createParams.get("CTQComments");
      String opportunity           = (String) createParams.get("CTQOpportunity");
      String outOfBounds           = (String) createParams.get("CTQOutOfBounds");
      String constraints           = (String) createParams.get("CTQConstraints");
      String metricSource          = (String) emxGetParameter(request, "CTQSource");
      String sigma                 = (String) emxGetParameter(request, "CTQSigma");
      String originator            = (String) emxGetParameter(request, "originatorName");
      String comments              = (String) emxGetParameter(request, "CTQComments");

      // Auto Name Selected?  If yes, set name to null
      String propertyFile = "emxProgramCentralStringResource";
      String propertyKey  = "emxProgramCentral.Common.AutoName";
      i18nNow i18nnow = new i18nNow();
      String language = request.getHeader("Accept-Language");
      String autoName = EnoviaResourceBundle.getProperty(context, "ProgramCentral", propertyKey, language);
      if(name.equals(autoName)) {
        name = null;
      }

      //Add all quality attributes to attributeMap
      HashMap attributeMap = new HashMap(16);
      attributeMap.put(quality.ATTRIBUTE_PROBLEM_STATEMENT, problemStatement);
      attributeMap.put(quality.ATTRIBUTE_OPERATIONAL_DEFINITION, operationalDefinition);
      attributeMap.put(quality.ATTRIBUTE_DEFECT_DEFINITION, defectDefinition);
      attributeMap.put(quality.ATTRIBUTE_GOAL, goal);
      attributeMap.put(quality.ATTRIBUTE_OPPORTUNITY, opportunity);
      attributeMap.put(quality.ATTRIBUTE_OUT_OF_BOUNDS, outOfBounds);
      attributeMap.put(quality.ATTRIBUTE_CONSTRAINTS, constraints);
      attributeMap.put(quality.ATTRIBUTE_COMMENTS, qualityComment);
      attributeMap.put(quality.ATTRIBUTE_ORIGINATOR, originator);
      attributeMap.put(quality.ATTRIBUTE_QUALITY_TYPE, qualityType);
      //put dynamic attributes on HashMap
      if (attrMapList != null) {
        Iterator attrMapListItr = attrMapList.iterator();
        while(attrMapListItr.hasNext()) {
          Map item = (Map) attrMapListItr.next();
          String attrName = (String) item.get("NAME");
          String attrType = (String) item.get("TYPE");
          String attrValue = (String) createParams.get(attrName);
          //websphere's calendar issue with spaces
          if(attrType.equals("timestamp")){
            attrName = attrName.replace('~',' ');
          }
          attributeMap.put(attrName, attrValue);
        }  //end while itr has next
      } //end if attrMapList != null

      //Add all metric attributes to metricMap
      HashMap metricMap = new HashMap();
      metricMap.put(quality.ATTRIBUTE_METRIC_SOURCE, metricSource);
      metricMap.put(quality.ATTRIBUTE_SIGMA, sigma);
      metricMap.put(quality.ATTRIBUTE_ORIGINATOR, originator);
      metricMap.put(quality.ATTRIBUTE_COMMENTS, comments);
      // get all Quality-type-specific attributes and add them to metricMap
      if(qualityType.equals("Continuous")) {
        String mean = (String) emxGetParameter(request, "CTQMean");
        String standardDeviation = (String) emxGetParameter(request, "CTQStandardDeviation");
        String upperSpecLimit    = (String) emxGetParameter(request, "CTQUpperSpecLimit");
        String lowerSpecLimit    = (String) emxGetParameter(request, "CTQLowerSpecLimit");
        metricMap.put(quality.ATTRIBUTE_MEAN, mean);
        metricMap.put(quality.ATTRIBUTE_STANDARD_DEVIATION, standardDeviation);
        metricMap.put(quality.ATTRIBUTE_UPPER_SPEC_LIMIT, upperSpecLimit);
        metricMap.put(quality.ATTRIBUTE_LOWER_SPEC_LIMIT, lowerSpecLimit);
      }
      // qualityType.equals("Discrete")
      else {
        String dpmo = (String) emxGetParameter(request, "CTQDPMO");
        String dpu  = (String) emxGetParameter(request, "CTQDPU");
        metricMap.put(quality.ATTRIBUTE_DPMO, dpmo);
        metricMap.put(quality.ATTRIBUTE_DPU, dpu);
      }

      // set project bean to this id
      project.setId(parentObjectId);
      quality.create(context, null, name, null, attributeMap, metricMap, project);
    } // end Create

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Edit
    else if ("edit".equals(action)) {
      // retrieve quality parameters off the edit page
      String problemStatement      = (String) emxGetParameter(request, "QualityProblemStatement");
      String operationalDefinition = (String) emxGetParameter(request, "QualityOperationalDefinition");
      String defectDefinition      = (String) emxGetParameter(request, "QualityDefectDefinition");
      String goal                  = (String) emxGetParameter(request, "QualityGoal");
      String comments              = (String) emxGetParameter(request, "QualityComments");
      String opportunity           = (String) emxGetParameter(request, "QualityOpportunity");
      String outOfBounds           = (String) emxGetParameter(request, "QualityOutOfBounds");
      String constraints           = (String) emxGetParameter(request, "QualityConstraints");
      //Get dynamic attributes
      MapList attrMapList = (MapList) session.getAttribute("attributeMap");
      session.removeAttribute("attributeMap");

      // put all attributes on HashMap
      HashMap attributeMap = new HashMap(12);
      attributeMap.put(quality.ATTRIBUTE_PROBLEM_STATEMENT, problemStatement);
      attributeMap.put(quality.ATTRIBUTE_OPERATIONAL_DEFINITION, operationalDefinition);
      attributeMap.put(quality.ATTRIBUTE_DEFECT_DEFINITION, defectDefinition);
      attributeMap.put(quality.ATTRIBUTE_GOAL, goal);
      attributeMap.put(quality.ATTRIBUTE_COMMENTS, comments);
      attributeMap.put(quality.ATTRIBUTE_OPPORTUNITY, opportunity);
      attributeMap.put(quality.ATTRIBUTE_OUT_OF_BOUNDS, outOfBounds);
      attributeMap.put(quality.ATTRIBUTE_CONSTRAINTS, constraints);
      //put dynamic attributes on HashMap
      if (attrMapList != null) {
        Iterator attrMapListItr = attrMapList.iterator();
        while(attrMapListItr.hasNext()) {
          Map item = (Map) attrMapListItr.next();
          String attrName = (String) item.get("NAME");
          String attrType = (String) item.get("TYPE");
          String attrValue = (String) emxGetParameter(request, attrName);
          //websphere's calendar issue with spaces
          if(attrType.equals("timestamp")){
            attrName = attrName.replace('~',' ');
          }
          attributeMap.put(attrName, attrValue);
        }  //end while itr has next
      }  //end if attrMapList is not null

      // set Quality bean to point to the Quality that is being edited
      quality.setId(objectId);
      //update attributes
      quality.setAttributeValues(context, attributeMap);
    } // end Edit

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Delete/Remove
    else if ("delete".equals(action)) {
      qualities = emxGetParameterValues(request,"emxTableRowId");
      qualities = ProgramCentralUtil.parseTableRowId(context,qualities);
      if(portalMode == null)
      {
        portalMode = "";
      }      
      if ( qualities != null )
      {
        // get the number of risks to delete
        int numQualities = qualities.length;
        for (int i=0; numQualities>i; i++)
        {
          String strQualObjId = "";
          if(qualities[i].indexOf("|") != -1 ){
            strQualObjId = qualities[i].substring(qualities[i].indexOf("|")+1);
          }
          else {
            strQualObjId = qualities[i];
          }
          quality.setId(strQualObjId);
          try{
        	  ProgramCentralUtil.pushUserContext(context);        	  
          quality.deleteObject(context, true);
          }	finally{
        	  ProgramCentralUtil.popUserContext(context);
          }
        }
        }
      }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    <script language="javascript" type="text/javaScript">//<![CDATA[
      <!-- hide JavaScript from non-JavaScript browsers
        var action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";

        if (action == "create" || action == "edit") {
            //Added by viru R2012
            getTopWindow().parent.getWindowOpener().location.href = getTopWindow().parent.getWindowOpener().location.href;
           //End by viru R2012
           parent.window.closeWindow();
        } 
        else if (action == "delete") {
        	var tree = null;
        	if (getTopWindow().objDetailsTree) {
        		tree = getTopWindow().objDetailsTree;
        	}
          
        	 <%-- XSSOK--%>   
           if("<%=portalMode%>" == "true" || "<%=portalMode%>" == "false")
          {
            parent.document.location.href=parent.document.location.href;
          } 
          else
          {           
          	if (tree != null) {
<%
            //Loop through all ids passed in for delete and remove them from the navigation tree
            if (qualities != null) {
              Iterator qualityItr = Arrays.asList(qualities).iterator();
              while (qualityItr.hasNext())
              {
                 String tempQualityId = (String) qualityItr.next();
%>
                 	tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,tempQualityId)%>",false);
<%
              } //end while itr has next
            } //end if qualities does not equal null
%>
           		//tree.refresh();
           		//Added for rfreshing the table after deleting Quality object
             	parent.getTopWindow().refreshTablePage();
            }
            if (parent.getTopWindow().refreshTablePage) {	
            	parent.getTopWindow().refreshTablePage();
            }
            else {
            	parent.location.href = parent.location.href;
            }
          }
        } else {
           if (parent.getTopWindow().refreshTablePage) {	
            	parent.getTopWindow().refreshTablePage();
            }
            else {
            	parent.location.href = parent.location.href;
            }
        }
      // Stop hiding here -->//]]>

    </script>
  </form>
</html>
