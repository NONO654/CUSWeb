<%--
  emxProgramCentralImportAction.jsp

  Performs the action to create a group of types from an import file.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralImportAction.jsp.rca 1.19 Wed Oct 22 15:49:46 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>

<%
  ProjectSpace project = (ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,"PROGRAM");
  Risk risk = (Risk) DomainObject.newInstance(context, DomainConstants.TYPE_RISK,"PROGRAM");
  RiskRPNRelationship rpn = (RiskRPNRelationship) DomainRelationship.newInstance(context, DomainConstants.RELATIONSHIP_RISK_RPN,"PROGRAM");
  FinancialItem financialItem = (FinancialItem) DomainObject.newInstance(context, FinancialItem.TYPE_FINANCIAL_ITEM,"PROGRAM");
  BenefitItem benefitItem = (BenefitItem) DomainObject.newInstance(context, Financials.TYPE_BENEFIT_ITEM,"PROGRAM");
  CostItem costItem = (CostItem) DomainObject.newInstance(context, Financials.TYPE_COST_ITEM,"PROGRAM");
  Quality quality = (Quality) DomainObject.newInstance(context, DomainConstants.TYPE_QUALITY,"PROGRAM");
  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);

  String objectId = (String) emxGetParameter(request, "objectId");
  String importType = (String) emxGetParameter(request, "importType");
  
  if (null != objectId && !objectId.equals("")){
    project.setId(objectId);
  }

  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
  
  Calendar todayCalender = Calendar.getInstance(Locale.US);
  todayCalender.set(Calendar.HOUR, 0);
  todayCalender.set(Calendar.MINUTE, 0);
  todayCalender.set(Calendar.SECOND, 0);
  todayCalender.set(Calendar.MILLISECOND, 0);
  todayCalender.set(Calendar.AM_PM, Calendar.AM);

  String todayStr = sdf.format( todayCalender.getTime() );
		 
  person = person.getPerson(context);
  StringList busSelects = new StringList();
  busSelects.add(person.SELECT_FIRST_NAME);
  busSelects.add(person.SELECT_LAST_NAME);
  Map personMap = (Map) person.getInfo(context, busSelects);
  String FirstName = (String) personMap.get(person.SELECT_FIRST_NAME);
  String LastName = (String) personMap.get(person.SELECT_LAST_NAME);
  String displayName = LastName +","+ FirstName;

  // get import values
  MapList resultSet         = (MapList) session.getAttribute("resultSet");
  Iterator resultSetItr     = resultSet.iterator();
  String type_risk          = PropertyUtil.getSchemaProperty(context,"type_Risk");
  StringList riskSubtypeStringList = ProgramCentralUtil.getSubTypesList(context,type_risk);
  String type_rpn           = PropertyUtil.getSchemaProperty(context,"type_RPN");
  String type_financialItem = PropertyUtil.getSchemaProperty(context,"type_FinancialItem");
  String type_costItem      = PropertyUtil.getSchemaProperty(context,"type_CostItem");
  String type_benefitItem   = PropertyUtil.getSchemaProperty(context,"type_BenefitItem");
  String type_quality       = PropertyUtil.getSchemaProperty(context,"type_Quality");
  String type_metric        = PropertyUtil.getSchemaProperty(context,"type_QualityMetric");
  String language           = request.getHeader("Accept-Language");

  String financialName = 
              ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.ProjectBudget", "en-us");
  String controlled = 
              ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Controlled", "en-us");
  session.removeAttribute("resultSet");
  HashMap intervalSpread = new HashMap();
  String plannedSpreadOption = "";
  String estimatedSpreadOption = "";
  String actualSpreadOption = "";
  int riskCounter = 0;

  HashMap rpnCounter = new HashMap();
  if (importType.equals("Risk")){
    rpnCounter = (HashMap) session.getAttribute("rpnCounter");
  }

  project.startTransaction(context, true);

  try {
    while (resultSetItr.hasNext()) {
      Map importItem = (Map) resultSetItr.next();
      String importItemType = (String) importItem.get("Type");
      String importItemName = (String) importItem.get("Name");
      String amount = DomainObject.EMPTY_STRING;
      importItem.remove("Type");
      importItem.remove("Name");
      
      if (riskSubtypeStringList.contains(importItemType)){
      String estimatedStartDate = (String) importItem.get(risk.ATTRIBUTE_ESTIMATED_START_DATE);
      String estimatedEndDate = (String) importItem.get(risk.ATTRIBUTE_ESTIMATED_END_DATE);
      
      Date riskEstStartDate = com.matrixone.apps.domain.util.eMatrixDateFormat.getJavaDate(estimatedStartDate);
      Date riskEstendDate = com.matrixone.apps.domain.util.eMatrixDateFormat.getJavaDate(estimatedEndDate);
      
      estimatedStartDate = sdf.format(riskEstStartDate);
      estimatedEndDate = sdf.format(riskEstendDate);
      
      importItem.put(risk.ATTRIBUTE_ESTIMATED_START_DATE,estimatedStartDate);
      importItem.put(risk.ATTRIBUTE_ESTIMATED_END_DATE,estimatedEndDate);
      
        String description = (String) importItem.get("Description");
        importItem.remove("Description");
        risk.create(context, importItemName,
                    risk.getDefaultPolicy(context,type_risk), project);
        
        if(!importItemType.equalsIgnoreCase(DomainObject.TYPE_RISK) &&
        		riskSubtypeStringList.contains(importItemType)){
		        risk.change(context,
		        		importItemType, 
						risk.getName(context),
						risk.getRevision(),   
						project.getVault(),
						risk.getDefaultPolicy(context,type_risk));
        }
        
        String riskType = (String) importItem.get(risk.ATTRIBUTE_RISK_TYPE);
        importItem.put(risk.ATTRIBUTE_RISK_TYPE,riskType);
        String riskVisibility = (String) importItem.get(risk.ATTRIBUTE_RISK_VISIBILITY);
        importItem.put(risk.ATTRIBUTE_RISK_VISIBILITY,riskVisibility);
        risk.setAttributeValues(context,importItem);
        risk.setDescription(context, description);
		/*code commented to fix IR-660405-3DEXPERIENCER2019x (mse13)*/
        //risk.addRiskItem(context, objectId);
        String rpnCount = (String) rpnCounter.get("Risk"+riskCounter);
        riskCounter++;
        if (rpnCount.equals("0")){
          HashMap initialRPN = new HashMap(4);
          initialRPN.put("Risk Impact","1");
          initialRPN.put("Risk Probability","1");
          // NX5 - 2017 S8 Bug
          risk.setAttributeValues(context, initialRPN);

          //initialRPN.put("Risk RPN Value","25");
          initialRPN.put("Effective Date",todayStr);
          rpn = risk.createRPN(context);
          rpn.setAttributeValues(context, initialRPN);
        }
      } else if (importItemType.equals(type_rpn)){
        rpn = risk.createRPN(context);

          // NX5 - 2017 S8 Bug
          String effectiveDate = (String) importItem.get("Effective Date");       
          Date rpnEffectiveDateDate = com.matrixone.apps.domain.util.eMatrixDateFormat.getJavaDate(effectiveDate);
          effectiveDate = sdf.format(rpnEffectiveDateDate);        
          importItem.put("Effective Date",effectiveDate);
		  //if Risk has rpn then initialise "risk Impact" and "risk Probability" with corresponding "rpn's impact" and "rpn's probability" 
          HashMap initialRPN = new HashMap(2);
          String riskImpact =(String)importItem.get("Risk Impact");
      	  String riskProbability =(String)importItem.get("Risk Probability");
      	  initialRPN.put("Risk Impact",riskImpact);
          initialRPN.put("Risk Probability",riskProbability);
          risk.setAttributeValues(context, initialRPN);
		  rpn.setAttributeValues(context, initialRPN);
          // NX5 - End
        rpn.setAttributeValues(context, importItem);
      } else if (importItemType.equals(type_financialItem)){
        plannedSpreadOption = (String) importItem.get("Planned Spread Option");
        estimatedSpreadOption= (String) importItem.get("Estimated Spread Option");
        actualSpreadOption = (String) importItem.get("Actual Spread Option");
        importItem.remove("Planned Spread Option");
        importItem.remove("Estimated Spread Option");
        importItem.remove("Actual Spread Option");
        importItem.put(financialItem.ATTRIBUTE_COST_INTERVAL, importItem.get(financialItem.ATTRIBUTE_COST_INTERVAL));
        importItem.put(financialItem.ATTRIBUTE_BENEFIT_INTERVAL, importItem.get(financialItem.ATTRIBUTE_BENEFIT_INTERVAL));
        financialItem.create(context,financialName,null,project,"",importItem);
      } else if (importItemType.equals(type_costItem)){
        String policy = costItem.getDefaultPolicy(context, type_costItem);
        String plannedCost = (String) importItem.get("Planned Cost");
        String estimatedCost = (String) importItem.get("Estimated Cost");
        String actualCost = (String) importItem.get("Actual Cost");
        if (plannedCost != null && !plannedCost.equals("")){
          plannedCost = ProgramCentralUtil.convertDecimalForDBStorage(plannedCost);
          importItem.put("Planned Cost",plannedCost);
          amount = plannedCost + "|" + plannedSpreadOption;
          intervalSpread.put("Planned",amount);
        }
        if (estimatedCost != null && !estimatedCost.equals("")){
          estimatedCost = ProgramCentralUtil.convertDecimalForDBStorage(estimatedCost);
          importItem.put("Estimated Cost",estimatedCost);
          amount = estimatedCost + "|" + estimatedSpreadOption;
          intervalSpread.put("Estimated",amount);
        }
        if (actualCost != null && !actualCost.equals("")){
          actualCost = ProgramCentralUtil.convertDecimalForDBStorage(actualCost);
          importItem.put("Actual Cost",actualCost);
          amount = actualCost + "|" + actualSpreadOption;
          intervalSpread.put("Actual",amount);
        }
        costItem.create(context, importItemName, policy, financialItem, "",
                           importItem, intervalSpread);
      } else if (importItemType.equals(type_benefitItem)){
        String plannedBenefit = (String) importItem.get("Planned Benefit");
        String estimatedBenefit = (String) importItem.get("Estimated Benefit");
        String actualBenefit = (String) importItem.get("Actual Benefit");
        if (plannedBenefit != null && !plannedBenefit.equals("")){
          plannedBenefit = ProgramCentralUtil.convertDecimalForDBStorage(plannedBenefit);
          importItem.put("Planned Benefit",plannedBenefit);
          amount = plannedBenefit + "|" + plannedSpreadOption;
          intervalSpread.put("Planned",amount);
        }
        if (estimatedBenefit != null && !estimatedBenefit.equals("")){
          estimatedBenefit = ProgramCentralUtil.convertDecimalForDBStorage(estimatedBenefit);
          importItem.put("Estimated Benefit",estimatedBenefit);
          amount = estimatedBenefit + "|" + estimatedSpreadOption;
          intervalSpread.put("Estimated",amount);
        }
        if (actualBenefit != null && !actualBenefit.equals("")){
          actualBenefit = ProgramCentralUtil.convertDecimalForDBStorage(actualBenefit);
          importItem.put("Actual Benefit",actualBenefit);
          amount = actualBenefit + "|" + actualSpreadOption;
          intervalSpread.put("Actual",amount);
        }
        String policy = costItem.getDefaultPolicy(context, type_benefitItem);
        benefitItem.create(context, importItemName, policy, financialItem, "",
                           importItem, intervalSpread);
      } else if (importItemType.equals(type_quality)){
        String qualityType = (String) importItem.get("Quality Type");
        importItem.put("Quality Type",qualityType);
        quality.create(context, null, importItemName, null, importItem, null, 
                           project);
      } else if (importItemType.equals("DiscreteMetric") || 
                 importItemType.equals("ContinuousMetric")){
        // Convert Metric Source back into English
        String metricSource = (String) importItem.get("Metric Source");
        importItem.put("Metric Source",metricSource);
        quality.addQualityMetric(context, importItem);
        if(metricSource.equals(controlled)) {
          quality.promote(context);
        }
      }
    }
    // commit the data
    ContextUtil.commitTransaction(context);
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
   <% if(importType.equals(ProgramCentralConstants.TYPE_QUALITY)){ %>
    	var detailsDisplay = openerFindFrame(getTopWindow(),"PMCQuality");
		detailsDisplay.location.href = detailsDisplay.location.href;
    <%    } else {%>
	    var topFrame = openerFindFrame(getTopWindow(), "PMCProjectRisk");
	    if (topFrame != null) {
 			topFrame.location.href = topFrame.location.href;
        }else{
        	 var tabFrame = findFrame(getTopWindow().getWindowOpener().parent, "listDisplay");
        	    if(tabFrame != 'undefined' && tabFrame != null) {
        	        tabFrame.parent.document.location.href = tabFrame.parent.document.location.href;
        	    }else {
        	        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
        	    }
        }
    <%}%>
    parent.window.closeWindow();
    
  </script>
</html>

<%
  } catch (Exception e) {
    ContextUtil.abortTransaction(context);
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    <%-- XSSOK--%>  var errorString = "<%=((e.getMessage()).replace('\n',' ')).replace('\r',' ')%>";
    alert(errorString);
    parent.window.location.href="emxProgramCentralImportTypeFS.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>";
    // Stop hiding here -->//]]>
  </script>
</html>

<%
  }
%>

