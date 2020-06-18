<%-- emxProgramCentralFinancialCreateProcess.jsp
  Creates
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/16/2002

  static const char RCSID[] = "$Id: emxProgramCentralFinancialItemEditDetailsProcess.jsp.rca 1.13 Wed Oct 22 15:49:37 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>

<jsp:useBean id="financialItem" scope="page" class="com.matrixone.apps.program.FinancialItem"/>
<jsp:useBean id="costItem"      scope="page" class="com.matrixone.apps.program.CostItem"/>
<jsp:useBean id="benefitItem"    scope="page" class="com.matrixone.apps.program.BenefitItem"/>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
//  com.matrixone.apps.program.FinancialItem financialItem =
//   (com.matrixone.apps.program.FinancialItem) DomainObject.newInstance(context, DomainConstants.TYPE_FINANCIAL_ITEM, "PROGRAM");
//  com.matrixone.apps.program.CostItem costItem =
//   (com.matrixone.apps.program.CostItem) DomainObject.newInstance(context, DomainConstants.TYPE_COST_ITEM, "PROGRAM");
//  com.matrixone.apps.program.BenefitItem benefitItem =
//   (com.matrixone.apps.program.BenefitItem) DomainObject.newInstance(context, DomainConstants.TYPE_BENEFIT_ITEM, "PROGRAM");


  // Collecting all parameters...
  String financialId           = emxGetParameter(request, "financialId");
  String Name                  = emxGetParameter(request, "Name");
  String ExtendCostInterval    = emxGetParameter(request, "ExtendCostInterval");
  String ExtendBenefitInterval = emxGetParameter(request, "ExtendBenefitInterval");
  String Notes                 = emxGetParameter(request, "Notes");
  MapList attrMapList = (MapList) session.getAttribute("attributeMap");
  session.removeAttribute("attributeMap");

  // Initializing all needed string variables...
  String updateCostItemStartDate = "";
  String updateBenefitItemStartDate = "";
  String updateCostItemEndDate = "";
  String updateBenefitItemEndDate = "";
  String oldCostItemStartDate = "";
  String oldCostItemEndDate = "";
  String oldBenefitItemStartDate = "";
  String oldBenefitItemEndDate = "";

  // Getting cost and benefit item end date fro the finance item object...
  financialItem.setId(financialId);

  StringList busSelects = new StringList(18);
  busSelects.add(financialItem.SELECT_COST_INTERVAL);
  busSelects.add(financialItem.SELECT_COST_INTERVAL_START_DATE);
  busSelects.add(financialItem.SELECT_COST_INTERVAL_END_DATE);
  busSelects.add(financialItem.SELECT_BENEFIT_INTERVAL);
  busSelects.add(financialItem.SELECT_BENEFIT_INTERVAL_START_DATE);
  busSelects.add(financialItem.SELECT_BENEFIT_INTERVAL_END_DATE);

  Map financialItemMap = financialItem.getInfo(context, busSelects);

  java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
  Calendar cal = Calendar.getInstance();
  // Calculating COST_INTERVAL_END_DATE...   
   double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
   int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
   java.text.DateFormat format = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
      
  if(ExtendCostInterval!=null && !ExtendCostInterval.equals("") && 
  (Integer.parseInt(ExtendCostInterval)>0)) {
    // calculate costitem end date
    oldCostItemStartDate = (String)financialItemMap.get(financialItem.SELECT_COST_INTERVAL_START_DATE);
    oldCostItemEndDate = (String)financialItemMap.get(financialItem.SELECT_COST_INTERVAL_END_DATE);
    String tempDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, oldCostItemEndDate, true,iDateFormat, clientTZOffset,request.getLocale());
    Date dDueDate = format.parse(tempDate);
    cal.setTime(dDueDate);    
    cal.add(Calendar.MONTH, Integer.parseInt(ExtendCostInterval));  
    updateCostItemEndDate = formatter.format(cal.getTime());

    // calculate costitem start date for update
     String tempoldCostItemStartDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, oldCostItemStartDate, true,iDateFormat, clientTZOffset,request.getLocale());
     Date doldCostItemStartDate = format.parse(tempoldCostItemStartDate);
     
     String tempoldCostItemEndDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, oldCostItemEndDate, true,iDateFormat, clientTZOffset,request.getLocale());
     Date doldCostItemEndDate = format.parse(tempoldCostItemEndDate);
     updateCostItemStartDate = formatter.format(getStartIntervalDate(doldCostItemStartDate, doldCostItemEndDate, (String)financialItemMap.get(financialItem.SELECT_COST_INTERVAL)).getTime());
  }

  // Calculating BENEFIT_INTERVAL_END_DATE...
  if(ExtendBenefitInterval!=null && !ExtendBenefitInterval.equals("") && (Integer.parseInt(ExtendBenefitInterval)>0)) {
    // calculate benefititem end date
    oldBenefitItemStartDate = (String)financialItemMap.get(financialItem.SELECT_BENEFIT_INTERVAL_START_DATE);
    oldBenefitItemEndDate = (String)financialItemMap.get(financialItem.SELECT_BENEFIT_INTERVAL_END_DATE);
    
    String tempoldBenefitItemEndDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, oldBenefitItemEndDate, true,iDateFormat, clientTZOffset,request.getLocale());
    Date doldBenefitItemEndDate = format.parse(tempoldBenefitItemEndDate);

    String tempoldBenefitItemStartDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, oldBenefitItemStartDate, true,iDateFormat, clientTZOffset,request.getLocale());
    Date doldBenefitItemStartDate = format.parse(tempoldBenefitItemStartDate);

    cal.setTime(doldBenefitItemEndDate);
   
    cal.add(Calendar.MONTH, Integer.parseInt(ExtendBenefitInterval));
    updateBenefitItemEndDate = formatter.format(cal.getTime());

    // calculate benefititem start date for update
    updateBenefitItemStartDate = formatter.format(getStartIntervalDate(doldBenefitItemStartDate, doldBenefitItemEndDate, (String)financialItemMap.get(financialItem.SELECT_BENEFIT_INTERVAL)).getTime());
  }

  try {
    // start a write transaction and lock business object
    financialItem.startTransaction(context, true);
    HashMap attributes = new HashMap();
    if(Name!=null) {
      financialItem.setName(context, Name);
    }
    if(Notes!=null) {
      attributes.put(financialItem.ATTRIBUTE_NOTES, Notes);
    }
    if(ExtendCostInterval!=null && !ExtendCostInterval.equals("") && (Integer.parseInt(ExtendCostInterval)>0)) {
      attributes.put(financialItem.ATTRIBUTE_COST_INTERVAL_END_DATE, updateCostItemEndDate);
    }
    if(ExtendBenefitInterval!=null && !ExtendBenefitInterval.equals("") && (Integer.parseInt(ExtendBenefitInterval)>0)) {
      attributes.put(financialItem.ATTRIBUTE_BENEFIT_INTERVAL_END_DATE, updateBenefitItemEndDate);
    }
    financialItem.setAttributeValues(context, attributes);

    HashMap processMap = new HashMap();
    Iterator attrMapListItr = attrMapList.iterator();
    while(attrMapListItr.hasNext()) 
    {
      Map item = (Map) attrMapListItr.next();
      String attrName = (String) item.get("NAME");
      String attrType = (String) item.get("TYPE");
      String attrValue = (String) emxGetParameter(request, attrName);
      //websphere's calendar issue with spaces
      if(attrType.equals("timestamp")) {
        attrName = attrName.replace('~',' ');
      }
      processMap.put(attrName, attrValue);
    }
    financialItem.setAttributeValues(context, processMap);

    // commit the data
    ContextUtil.commitTransaction(context);
  } catch (Exception e) {
    ContextUtil.abortTransaction(context);
    throw e;
  }

  if(ExtendCostInterval!=null && !ExtendCostInterval.equals("") && (Integer.parseInt(ExtendCostInterval)>0)) {
    //Collect all CostItem and BenefitItem...
    busSelects.clear();
    busSelects.add(costItem.SELECT_ID);
    MapList costItemMapList = costItem.getCostItems(context, financialItem, busSelects, null);

    // Getting Date Array for costitem and benefititem for update...
    
    String tempupdateCostItemStartDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, updateCostItemStartDate, true,iDateFormat, clientTZOffset,request.getLocale());
    Date dupdateCostItemStartDate = format.parse(tempupdateCostItemStartDate);
         
    String tempupdateCostItemEndDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, updateCostItemEndDate, true,iDateFormat, clientTZOffset,request.getLocale());
    Date dupdateCostItemEndDate = format.parse(tempupdateCostItemEndDate);

    
    ArrayList CostItemUpdateDates = DateUtil.computeIntervalDates(dupdateCostItemStartDate, dupdateCostItemEndDate, (String)financialItemMap.get(financialItem.SELECT_COST_INTERVAL));

    try {
      for(int i=0; i<costItemMapList.size(); i++) {
        Map costItemMap = (Map) costItemMapList.get(i);
        costItem.setId((String)costItemMap.get(costItem.SELECT_ID));
        HashMap hashmap = new HashMap();
        for(int i1 = 0; i1 < CostItemUpdateDates.size(); i1++) {
          Date date2 = (Date)CostItemUpdateDates.get(i1);
          String s3 = formatter.format(date2);
          hashmap.clear();
          hashmap.put(com.matrixone.apps.program.CostItemIntervalRelationship.ATTRIBUTE_INTERVAL_DATE, s3);
          costItem.addCostItemData(context, hashmap);
        }
      }
    } catch (Exception e) {
      throw e;
    }
  }

  if(ExtendBenefitInterval!=null && !ExtendBenefitInterval.equals("") && (Integer.parseInt(ExtendBenefitInterval)>0)) {
    busSelects.clear();
    busSelects.add(benefitItem.SELECT_ID);
    MapList benefitItemMapList = benefitItem.getBenefitItems(context, financialItem, busSelects, null);

    // Getting Date Array for costitem and benefititem for update...
    ArrayList BenefitItemUpdateDates = DateUtil.computeIntervalDates(new Date(updateBenefitItemStartDate), new Date(updateBenefitItemEndDate), (String)financialItemMap.get(financialItem.SELECT_BENEFIT_INTERVAL));

    try {
      for(int i2=0; i2<benefitItemMapList.size(); i2++) {
        Map benefitItemMap = (Map) benefitItemMapList.get(i2);
        benefitItem.setId((String)benefitItemMap.get(benefitItem.SELECT_ID));
        HashMap hashmap = new HashMap();
        for(int i3 = 0; i3 < BenefitItemUpdateDates.size(); i3++) {
          Date date2 = (Date)BenefitItemUpdateDates.get(i3);
          String s3 = formatter.format(date2);
          hashmap.clear();
          hashmap.put(com.matrixone.apps.program.BenefitItemIntervalRelationship.ATTRIBUTE_INTERVAL_DATE, s3);
          benefitItem.addBenefitItemData(context, hashmap);
        }
    }
    } catch (Exception e) {
      throw e;
    }
  }

%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
  
    var localTree = parent.window.getWindowOpener().parent.getTopWindow().objDetailsTree;
    localTree.getSelectedNode().changeObjectName("<%=XSSUtil.encodeForJavaScript(context,Name)%>",false);
    parent.window.getWindowOpener().parent.document.location.reload();
        
    if(localTree){
      localTree.refresh();
    }
    
    parent.window.closeWindow();
    // Stop hiding here -->//]]>
  </script>
</html>


<%!
   public Calendar getStartIntervalDate(Date startDate, Date finishDate, String interval)
   {

     Date runningDate = startDate;
     Calendar runningCalendar = Calendar.getInstance();
     runningCalendar.setTime(runningDate);
     while(finishDate.after(runningCalendar.getTime()))
       if(interval.equalsIgnoreCase("Weekly"))
        {
          runningCalendar.add(5, 7);
        } else
        if(interval.equalsIgnoreCase("Monthly"))
         {
           runningCalendar.add(2, 1);
         } else
        if(interval.equalsIgnoreCase("Quarterly"))
         {
           runningCalendar.add(2, 3);
         }

     return runningCalendar;
   }
%>


