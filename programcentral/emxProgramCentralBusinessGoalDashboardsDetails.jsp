<%--  emxProgramCentralBusinessGoalDashboardsDetails.jsp

  Displays the current user's Business Goals.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralBusinessGoalDashboardsDetails.jsp.rca 1.16 Wed Oct 22 15:49:29 2008 przemek Experimental przemek $";
--%>
<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import = "com.matrixone.apps.program.Task" %>

<%!
/***********Methods for dashboards*************************************************/

  public String getTotal(Context context, MapList projectList, String type, String year,HttpServletRequest request) throws Exception {

    String plannedTotal = "0.0";
    String result="0.0";
    com.matrixone.apps.program.ProjectSpace project =
      (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
    com.matrixone.apps.program.FinancialItem financialItem =
      (com.matrixone.apps.program.FinancialItem) DomainObject.newInstance(context, FinancialItem.TYPE_FINANCIAL_ITEM, DomainConstants.PROGRAM);
    com.matrixone.apps.program.CostItem costItem =
      (com.matrixone.apps.program.CostItem) DomainObject.newInstance(context, FinancialItem.TYPE_COST_ITEM, DomainConstants.PROGRAM);
    com.matrixone.apps.program.BenefitItem benefitItem =
      (com.matrixone.apps.program.BenefitItem) DomainObject.newInstance(context, FinancialItem.TYPE_BENEFIT_ITEM, DomainConstants.PROGRAM);

    HttpSession session = request.getSession();
    double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
    int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
    java.text.DateFormat format = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());

    StringList busSelects =  new StringList();
    busSelects.add(financialItem.SELECT_ID);

    if("SELECT_PLANNED_COST".equals(type)){
      busSelects.add(financialItem.SELECT_PLANNED_COST);
    }
    if("SELECT_PLANNED_BENEFIT".equals(type)) {
      busSelects.add(financialItem.SELECT_PLANNED_BENEFIT);
    }
    if("SELECT_ACTUAL_COST".equals(type)){
      busSelects.add(financialItem.SELECT_ACTUAL_COST);
    }
    if("SELECT_ACTUAL_BENEFIT".equals(type)) {
      busSelects.add(financialItem.SELECT_ACTUAL_BENEFIT);
    }

    MapList financialItemList = new MapList();
    if (null != projectList){
      Iterator projectItr = projectList.iterator();
      while (projectItr.hasNext()){
        Map projectMap = (Map) projectItr.next();
        project.setId((String) projectMap.get(project.SELECT_ID));
        financialItemList = financialItem.getFinancialItems(context, project, busSelects);
        if (null != financialItemList){
          Iterator financialItemItr = financialItemList.iterator();
          while (financialItemItr.hasNext()){
            Map financialItemMap = (Map) financialItemItr.next();
              if("SELECT_PLANNED_COST".equals(type)){
                if(null == year){
                  plannedTotal = (String)financialItemMap.get(financialItem.SELECT_PLANNED_COST);
                } else {
                  financialItem.setId((String)financialItemMap.get(financialItem.SELECT_ID));
                  busSelects.clear();
                  busSelects.add(costItem.SELECT_ID);
                  busSelects.add(costItem.SELECT_PLANNED_COST);
                  MapList costItemList = costItem.getCostItems(context, financialItem, busSelects, null);
                  if (null != costItemList){
                    Iterator costItemItr = costItemList.iterator();
                    while (costItemItr.hasNext()){
                      Map costItemMap = (Map) costItemItr.next();
                      costItem.setId((String)costItemMap.get(costItem.SELECT_ID));
                      busSelects.clear();
                      busSelects.add(financialItem.SELECT_ID);
                      busSelects.add(CostItemIntervalRelationship.SELECT_INTERVAL_DATE);
                      busSelects.add(CostItemIntervalRelationship.SELECT_PLANNED_COST);
                      MapList costRelationshipList = costItem.getCostItemData(context, busSelects, null);
                      if (null != costRelationshipList){
                        Iterator costRelationshipItr = costRelationshipList.iterator();
                        while (costRelationshipItr.hasNext()){
                          Map costRelationshipMap = (Map) costRelationshipItr.next();
                          String tempDate = (String)costRelationshipMap.get(CostItemIntervalRelationship.SELECT_INTERVAL_DATE);
                          String tempsDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, tempDate, true,iDateFormat, clientTZOffset,request.getLocale());
                          String stringCompareYear = "";
                        	 if(ProgramCentralUtil.isNotNullString(tempsDate))
                         	{
                          Date date = format.parse(tempsDate);
                          int compareYear = (date.getYear()+1900);
                          		stringCompareYear = String.valueOf(compareYear);
                        	 }
                          if(year.equals(stringCompareYear)){
                          double costItemValue = Task.parseToDouble((String)costRelationshipMap.get(CostItemIntervalRelationship.SELECT_PLANNED_COST)) + Task.parseToDouble(plannedTotal);
                          java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#");
                          plannedTotal = twoPlaces.format(costItemValue);
                          }//ends if (year.equals(stringCompareYear))
                        }//ends while (costRelationshipItr.hasNext())
                      }//ends if (null != costRelationshipList)
                    }//ends while (costItemItr.hasNext())
                  }//ends if (null != costItemList)
                }//ends else
              }//ends if ("SELECT_PLANNED_COST".equals(type))
              if("SELECT_PLANNED_BENEFIT".equals(type)) {
                if(null == year){
                  plannedTotal = (String)financialItemMap.get(financialItem.SELECT_PLANNED_BENEFIT);
                } else {
                  financialItem.setId((String)financialItemMap.get(financialItem.SELECT_ID));
                  busSelects.clear();
                  busSelects.add(benefitItem.SELECT_ID);
                  busSelects.add(benefitItem.SELECT_PLANNED_BENEFIT);
                  MapList benefitItemList = benefitItem.getBenefitItems(context, financialItem, busSelects, null);
                  if (null != benefitItemList){
                    Iterator benefitItemItr = benefitItemList.iterator();
                    while (benefitItemItr.hasNext()){
                      Map benefitItemMap = (Map) benefitItemItr.next();
                      benefitItem.setId((String)benefitItemMap.get(benefitItem.SELECT_ID));
                      busSelects.clear();
                      busSelects.add(financialItem.SELECT_ID);
                      busSelects.add(BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE);
                      busSelects.add(BenefitItemIntervalRelationship.SELECT_PLANNED_BENEFIT);
                      MapList costRelationshipList = benefitItem.getBenefitItemData(context, busSelects, null);
                      if (null != costRelationshipList){
                        Iterator costRelationshipItr = costRelationshipList.iterator();
                        while (costRelationshipItr.hasNext()){
                          Map costRelationshipMap = (Map) costRelationshipItr.next();
                          String tempDate = (String)costRelationshipMap.get(BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE);
                          String tempsDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, tempDate, true,iDateFormat, clientTZOffset,request.getLocale());
                          String stringCompareYear = "";
                          if(ProgramCentralUtil.isNotNullString(tempsDate))
                          {
                          Date date = format.parse(tempsDate);
                          int compareYear = (date.getYear()+1900);
                              stringCompareYear = String.valueOf(compareYear);  
                          }
                          
                          if(year.equals(stringCompareYear)){
                          double benefitItemValue = Task.parseToDouble((String)costRelationshipMap.get(BenefitItemIntervalRelationship.SELECT_PLANNED_BENEFIT)) + Task.parseToDouble(plannedTotal);
                          java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#");
                          plannedTotal = twoPlaces.format(benefitItemValue);
                          }//ends if (year.equals(stringCompareYear))
                        }//ends while (costRelationshipItr.hasNext())
                      }//ends if (null != costRelationshipList)
                    }//ends while (benefitItemItr.hasNext())
                  }//ends if (null != benefitItemList)
                }//ends else
              }//ends if
              if("SELECT_ACTUAL_COST".equals(type)){
                if(null == year){
                  plannedTotal = (String)financialItemMap.get(financialItem.SELECT_ACTUAL_COST);
                } else {
                  financialItem.setId((String)financialItemMap.get(financialItem.SELECT_ID));
                  busSelects.clear();
                  busSelects.add(costItem.SELECT_ID);
                  busSelects.add(costItem.SELECT_ACTUAL_COST);
                  MapList costItemList = costItem.getCostItems(context, financialItem, busSelects, null);
                  if (null != costItemList){
                    Iterator costItemItr = costItemList.iterator();
                    while (costItemItr.hasNext()){
                      Map costItemMap = (Map) costItemItr.next();
                      costItem.setId((String)costItemMap.get(costItem.SELECT_ID));
                      busSelects.clear();
                      busSelects.add(financialItem.SELECT_ID);
                      busSelects.add(CostItemIntervalRelationship.SELECT_INTERVAL_DATE);
                      busSelects.add(CostItemIntervalRelationship.SELECT_ACTUAL_COST);
                      MapList costRelationshipList = costItem.getCostItemData(context, busSelects, null);
                      if (null != costRelationshipList){
                        Iterator costRelationshipItr = costRelationshipList.iterator();
                        while (costRelationshipItr.hasNext()){
                          Map costRelationshipMap = (Map) costRelationshipItr.next();
                          String tempDate = (String)costRelationshipMap.get(CostItemIntervalRelationship.SELECT_INTERVAL_DATE);
                          String tempsDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, tempDate, true,iDateFormat, clientTZOffset,request.getLocale());
                          String stringCompareYear = "";
                         if(ProgramCentralUtil.isNotNullString(tempsDate))
                         {
                          Date date = format.parse(tempsDate);
                          int compareYear = (date.getYear()+1900);
                             stringCompareYear = String.valueOf(compareYear);
                         }
                         
                          if(year.equals(stringCompareYear)){
                          double costItemValue = Task.parseToDouble((String)costRelationshipMap.get(CostItemIntervalRelationship.SELECT_ACTUAL_COST)) + Task.parseToDouble(plannedTotal);
                          java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#");
                          plannedTotal = twoPlaces.format(costItemValue);
                          }//ends if (year.equals(stringCompareYear))
                        }//ends while (costRelationshipItr.hasNext())
                      }//ends if (null != costRelationshipList)
                    }//ends while (costItemItr.hasNext())
                  }//ends if (null != costItemList)
                }//ends else
              }//ends if
              if("SELECT_ACTUAL_BENEFIT".equals(type)) {
                if(null == year){
                  plannedTotal = (String)financialItemMap.get(financialItem.SELECT_ACTUAL_BENEFIT);
                } else {
                  financialItem.setId((String)financialItemMap.get(financialItem.SELECT_ID));
                  busSelects.clear();
                  busSelects.add(benefitItem.SELECT_ID);
                  busSelects.add(benefitItem.SELECT_ACTUAL_BENEFIT);
                  MapList benefitItemList = benefitItem.getBenefitItems(context, financialItem, busSelects, null);
                  if (null != benefitItemList){
                    Iterator benefitItemItr = benefitItemList.iterator();
                    while (benefitItemItr.hasNext()){
                      Map benefitItemMap = (Map) benefitItemItr.next();
                      benefitItem.setId((String)benefitItemMap.get(benefitItem.SELECT_ID));
                      busSelects.clear();
                      busSelects.add(financialItem.SELECT_ID);
                      busSelects.add(BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE);
                      busSelects.add(BenefitItemIntervalRelationship.SELECT_ACTUAL_BENEFIT);
                      MapList costRelationshipList = benefitItem.getBenefitItemData(context, busSelects, null);
                      if (null != costRelationshipList){
                        Iterator costRelationshipItr = costRelationshipList.iterator();
                        while (costRelationshipItr.hasNext()){
                          Map costRelationshipMap = (Map) costRelationshipItr.next();
                          String tempDate = (String)costRelationshipMap.get(BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE);
                          String tempsDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, tempDate, true,iDateFormat, clientTZOffset,request.getLocale());
                          String stringCompareYear = "";
                          if(ProgramCentralUtil.isNotNullString(tempsDate))
                          {
                          Date date = format.parse(tempsDate);
                          int compareYear = (date.getYear()+1900);
                              stringCompareYear = String.valueOf(compareYear);  
                          }
                          if(year.equals(stringCompareYear)){
                          double benefitItemValue = Task.parseToDouble((String)costRelationshipMap.get(BenefitItemIntervalRelationship.SELECT_ACTUAL_BENEFIT)) + Task.parseToDouble(plannedTotal);
                          java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#");
                          plannedTotal = twoPlaces.format(benefitItemValue);
                          }//ends if (year.equals(stringCompareYear))
                        }//ends while (costRelationshipItr.hasNext())
                      }//ends if (null != costRelationshipList)
                    }//ends while (benefitItemItr.hasNext())
                  }//ends if (null != benefitItemList)
                }//ends else
              }//ends if
              double value = Task.parseToDouble(result) + Task.parseToDouble(plannedTotal);
              java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#");
              result = twoPlaces.format(value);
              plannedTotal = "0.0";
          }//ends while
        } //ends if
      } //ends while
    } //ends if

    return result;
  } //ends getPlannedPartialCost
/*******End methods for dashboards*************************************************/
%>


<%
  com.matrixone.apps.program.BusinessGoal businessGoal =
    (com.matrixone.apps.program.BusinessGoal) DomainObject.newInstance(context, DomainConstants.TYPE_BUSINESS_GOAL, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);

  String filterValue   = emxGetParameter(request,"mx.page.filter");
  String jsTreeID      = emxGetParameter( request, "jsTreeID" );
  String suiteKey      = emxGetParameter( request, "suiteKey" );
  String initSource    = emxGetParameter( request, "initSource" );
  String objectId      = emxGetParameter( request, "objectId" );
  String tableBeanName = emxGetParameter( request, "beanName" );
  String timeStamp  = emxGetParameter(request, "timeStamp");
  String topId      = emxGetParameter(request, "topId");
  String expanded   = emxGetParameter(request, "expanded");
  String hideGoal    = emxGetParameter(request, "hideGoal");
  String strPrinterFriendly=emxGetParameter(request,"PrinterFriendly");
  String strLanguage = context.getSession().getLanguage();
  MapList goalsList = new MapList();

  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
  int iDateFormat1 = eMatrixDateFormat.getEMatrixDisplayDateFormat();
  java.text.DateFormat format = DateFormat.getDateTimeInstance(iDateFormat1, iDateFormat1, request.getLocale());

  //do initialization
  if(hideGoal == null || hideGoal.equals("null") || hideGoal.equals("")) {
     hideGoal = "true";
  }
  if(expanded==null || expanded.equals("null")|| expanded.equals("")) {
    expanded = "false";
  }
  if(timeStamp==null || timeStamp.equals("null")) {
    goalsList = null;
    timeStamp = null;
  } else {
    goalsList = (MapList) session.getAttribute("goalList" + timeStamp);
  }
  String jsTreeIDValue    = null;
  if (jsTreeID!=null && !jsTreeID.equals("null"))
  {
    jsTreeIDValue = jsTreeID;
  }
  if(topId == null || topId.equals("null") || topId.equals("")) {
   topId = objectId;
  }

  //set the businessgoal id to extract sub goals
  businessGoal.setId(objectId);

  // Add selectables
  StringList busSelects = new StringList(13);
  busSelects.add(businessGoal.SELECT_ID);
  busSelects.add(businessGoal.SELECT_NAME);
  busSelects.add(businessGoal.SELECT_DESCRIPTION);
  busSelects.add(businessGoal.SELECT_CURRENT);
  busSelects.add(businessGoal.SELECT_COMMENTS);
  busSelects.add(businessGoal.SELECT_BUSINESS_BENEFIT);
  busSelects.add(businessGoal.SELECT_EFFECTIVE_DATE);
  busSelects.add(businessGoal.SELECT_OWNER);
  busSelects.add(businessGoal.SELECT_LEVEL);
  busSelects.add(businessGoal.SELECT_ORGANIZATION_NAME);
  busSelects.add(businessGoal.SELECT_ORGANIZATION_ID);
  busSelects.add(businessGoal.SELECT_HAS_SUBGOAL);
  busSelects.add(businessGoal.SELECT_PARENT_GOAL_ID);

  //get the current (root) business goal information
  MapList businessGoalList = new MapList();
  Map parentList = businessGoal.getInfo(context, busSelects);

  //get the sub goals
  if(hideGoal.equals("true")) {
    if(expanded.equals("false")) {
      // get the direct children of the goal to be added to the list
      businessGoalList = businessGoal.getSubGoals(context,1, busSelects, false);
    } else {
      // get all of the children so they are removed from the list
      businessGoalList = businessGoal.getSubGoals(context,0, busSelects, false);
    }
    if(goalsList != null) {
      int counter = 0;              //index counter for parentListItr
      boolean parentFound = false;  //If parent is found then brean from both loops
      if(expanded.equals("false")) {
        //This entire code section is used to enter the subgoals into the correct
        //Spot in the list
        //Loops through parentList
        Iterator parentListItr = goalsList.iterator();
        while(parentListItr.hasNext()) {
          Map parentGoalMap = (Map) parentListItr.next();
          String goalsId = (String) parentGoalMap.get(businessGoal.SELECT_ID);
          //Loops thorugh child list
          Iterator childListItr = businessGoalList.iterator();
          while(childListItr.hasNext()) {
            Map childGoalMap = (Map) childListItr.next();
            String goalId = (String) childGoalMap.get(businessGoal.SELECT_ID);
            businessGoal.setId(goalId);
            MapList parentGoal = businessGoal.getParentInfo(context, 1, busSelects);
            Map parentGoalInfo = (Map) parentGoal.get(0);
            String parentGoalId = (String) parentGoalInfo.get(businessGoal.SELECT_ID);

            if(goalsId.equals(parentGoalId)) {
              parentFound = true;
              break;
            }
          } //end while childListItr.hasNext()
          if (parentFound == true) {
            break; //break from while(parentListItr.hasNext()
          }
          counter++;
        } //end while parentListItr.hasNext()
        goalsList.addAll(counter+1, businessGoalList);
        businessGoalList.clear();
        businessGoalList.addAll(goalsList);
      }
      else {
        //following removes goals from goalList away from goals in goalsList
        Iterator goalsListItr = goalsList.iterator();
        MapList combinedList = new MapList();
        while(goalsListItr.hasNext()) {
          boolean foundGoal = false;
          Map goalsMap = (Map) goalsListItr.next();
          String goalsId = (String) goalsMap.get(businessGoal.SELECT_ID);
          Iterator goalListItr = businessGoalList.iterator();
          while(goalListItr.hasNext()) {
            Map goalMap = (Map) goalListItr.next();
            String goalId = (String) goalMap.get(businessGoal.SELECT_ID);
            if(goalsId.equals(goalId)) {
              foundGoal = true;
              break;
            }
          }
          if(!foundGoal) {
            combinedList.add(goalsMap);
          }
        }
        // list needs to be updated to the new current list
        businessGoalList = combinedList;
      }
    }
    // only add parent if this is the first time to this page
    if(goalsList==null) {
      businessGoalList.clear();
      businessGoalList.add(0, parentList);
    }
  }//end of hideGoal = true
  else {
      businessGoalList = businessGoal.getSubGoals(context,0, busSelects, false);
  } //end if hideGoal = false

  // modify businessGoalList to added EXPANDED value to the maps
  Iterator listIndexItr = businessGoalList.iterator();
  int listItrNum = 0;
  while (listIndexItr.hasNext()) {
    // index for dependencies
    Map listIndexObj = (Map) listIndexItr.next();
    String listId = (String) listIndexObj.get(businessGoal.SELECT_ID);
    // expanding and collapsing part
    String isExpanded = (String) listIndexObj.get("EXPANDED");
    if(!hideGoal.equals("true")) {
      listIndexObj.put("EXPANDED", "true");
      isExpanded = "false";
    } else if(isExpanded == null || isExpanded.equals("null")) {
      listIndexObj.put("EXPANDED", "false");
      isExpanded = "false";
    }
    if(listId.equals(objectId) && goalsList != null) {
      if(isExpanded.equals("false")) {
        listIndexObj.put("EXPANDED", "true");
      } else {
        listIndexObj.put("EXPANDED", "false");
      }
    }
  }

  // set the session attribute to store the current business goal list
  Date time = new Date();
  if(timeStamp == null) {
    // create a new timestamp if one doesn't exist
    timeStamp = Long.toString(time.getTime());
  }
  session.setAttribute("goalList" + timeStamp, businessGoalList);
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
   <form name="businessGoals" method="post">
   <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	  
              <table class="list" border="0" width="100%">
                <tr>
                  <td>&nbsp;</td>
                  <td>&nbsp;</td>
                  <td>&nbsp;</td>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th class="groupheader" colspan="3"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.PlannedPartial</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th class="groupheader" colspan="3"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.PlannedTotal</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th class="groupheader" colspan="3"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.ActualPartial</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th class="groupheader" colspan="3"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.ActualTotal</framework:i18n></th>
                </tr>
                <tr>
                  <th><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.BusinessGoalName</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.ProjectCount</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.FiscalYear</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Cost</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Benefit</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Net</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Cost</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Benefit</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Net</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Cost</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Benefit</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Net</framework:i18n></th>
                  <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Cost</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Benefit</framework:i18n></th>
                  <th style="text-align:left"><framework:i18n localize="i18nId">emxProgramCentral.BusinessGoal.Net</framework:i18n></th>
                </tr>
<%
     //initialize
     HashMap levelList = new HashMap();
%>
                 <framework:ifExpr expr="<%= businessGoalList.size() > 0 %>">
                 <framework:mapListItr mapList="<%=businessGoalList%>" mapName="businessGoalMap">
<%
  String businessGoalId = (String) businessGoalMap.get(businessGoal.SELECT_ID);

  //To determine what level the current business goal is
  String parentId = (String) businessGoalMap.get(businessGoal.SELECT_PARENT_GOAL_ID);
  String levelS = null;
  if (parentId != null && !parentId.equals("null") && !parentId.equals("")) {
     levelS = (String) levelList.get(parentId);
  }
  int level = 0;
  if (levelS != null && !levelS.equals("null") && !levelS.equals("")) {
    level = Integer.parseInt(levelS);
    level++;
  }
  levelS = "" + level;
  levelList.put(businessGoalId,levelS);

  //create URLs
  String nextURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId="+businessGoalId;
  nextURL += "&mode=insert&jsTreeID="+jsTreeID+"&AppendParameters=false";

  String orgId = (String) businessGoalMap.get(businessGoal.SELECT_ORGANIZATION_ID);
  String orgURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId="+orgId;

  String refreshURL = "emxProgramCentralBusinessGoalDashboardsDetails.jsp?objectId=" + businessGoalId;
  refreshURL += "&jsTreeID=" + jsTreeID + "&beanName=" + tableBeanName;
  refreshURL += "&expanded=" + businessGoalMap.get("EXPANDED");
  refreshURL += "&hideGoal=" + hideGoal + "&timeStamp=" + timeStamp + "&topId=" + topId + "&isActive=true";
%>
              <tr class='<framework:swap id="1"/>'>
                 <td width="30%" nowrap="nowrap">
                   <framework:ifExpr expr="<%=level >= 0%>">
                      <!-- display correct amount of indention spaces -->
                      <img src="../common/images/utilSpacer.gif" height="5" width="<%= (level)*10 %>" border="0" />
                      <!-- If the goal has a subgoal, show minus or plus icon -->

                      <framework:ifExpr expr='<%=(((String)businessGoalMap.get(businessGoal.SELECT_HAS_SUBGOAL)).equalsIgnoreCase("true"))%>'>
                        <framework:ifExpr expr='<%=(((String) businessGoalMap.get("EXPANDED")).equals("true"))%>'>
                          <a href="<%=refreshURL%>">
                            <img src="../common/images/utilTreeMinus.gif" border="0" alt="" /></a>
                        </framework:ifExpr>
                        <!-- else if the goal is not expanded, show the plus icon -->
                        <framework:ifExpr expr='<%=(((String) businessGoalMap.get("EXPANDED")).equals("false"))%>'>
                          <a href="<%=refreshURL%>">
                           
                            <img src="../common/images/utilTreePlus.gif" border="0" alt="<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.BusinessGoalDashboardsDetails.altBlank", strLanguage) %>"></a>
                        </framework:ifExpr>
                      </framework:ifExpr>
                      <!-- Else if the goal does not have any subgoals, display connection icon -->
                      <framework:ifExpr expr='<%=!(((String)businessGoalMap.get(businessGoal.SELECT_HAS_SUBGOAL)).equalsIgnoreCase("true")) && level!=0%>'>
                        <img src="../common/images/utilTreeLineLast.gif" border="0" alt="" />
                      </framework:ifExpr>
                      <framework:ifExpr expr='<%=strPrinterFriendly == null%>'>
	                     <a href="<%=nextURL%>" target="content"> 
                         
                         <img src="../common/images/iconSmallCorpObjective.gif" border="0" alt="<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
           			  "emxProgramCentral.BusinessGoalDashboardsDetails.altBG", strLanguage) %>">
                      </a>
                   </framework:ifExpr>
                      <framework:ifExpr expr='<%=(strPrinterFriendly != null && strPrinterFriendly.equalsIgnoreCase("true"))%>'>
                             <img src="../common/images/iconSmallCorpObjective.gif" border="0" alt="BG:" />
                      </framework:ifExpr>
                   </framework:ifExpr>
                  <framework:ifExpr expr='<%=strPrinterFriendly == null%>'>
                     <a href="<%=nextURL%>" target="content"> 
                     <b><%= businessGoalMap.get(businessGoal.SELECT_NAME) %></b>
                     </a>  
                  </framework:ifExpr>
                  <framework:ifExpr expr='<%=(strPrinterFriendly != null && strPrinterFriendly.equalsIgnoreCase("true"))%>'>
                    <b><%= businessGoalMap.get(businessGoal.SELECT_NAME) %></b>
                  </framework:ifExpr>
                 </td>

<%
                 businessGoal.setId(businessGoalId);
                 busSelects.clear();
                 busSelects.add(project.SELECT_ID);
                 MapList projectList = businessGoal.getProjects(context, busSelects, null);

                 //Gets the children of the business goal and their projects
                 MapList subGoalList = new MapList();
                 subGoalList = businessGoal.getSubGoals(context,0, busSelects, false);
                 if (null != subGoalList){
                   Iterator subGoalItr = subGoalList.iterator();
                   while (subGoalItr.hasNext()){
                     Map subGoalMap = (Map) subGoalItr.next();
                     businessGoal.setId((String) subGoalMap.get(businessGoal.SELECT_ID));
                     projectList.addAll(businessGoal.getProjects(context, busSelects, null));
                   }//ends while
                 }//ends if

                 //sets the Id back after all sub goal projects are added to the list
                 businessGoal.setId(businessGoalId);

                 int numberOfProjects = projectList.size();
%>
                 <td>
                   <%= numberOfProjects %>
                 </td>
<%

                       String tempsDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, (String)businessGoalMap.get(businessGoal.SELECT_EFFECTIVE_DATE), true,iDateFormat1, clientTZOffset,request.getLocale());
				       String fiscalYear = ""; 
						if(ProgramCentralUtil.isNotNullString(tempsDate))
						{
                       Date year = format.parse(tempsDate);
							fiscalYear = String.valueOf(year.getYear() + 1900);
						}
%>
                 <td>
                   <%= fiscalYear %>
                 </td>
<%
                       //Decimal format - No decimals
                       java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#");
                       twoPlaces.setNegativePrefix("(");
                       twoPlaces.setNegativeSuffix(")");
                       //Planned (Total)
                       String plannedTotalCost = getTotal(context,projectList, "SELECT_PLANNED_COST", null,request);
                       String plannedTotalBenefit = getTotal(context,projectList, "SELECT_PLANNED_BENEFIT", null,request);
                       String plannedTotalNet = "0.0";
                       double plannedNet = Task.parseToDouble(plannedTotalBenefit) - Task.parseToDouble(plannedTotalCost);
                       plannedTotalNet = twoPlaces.format(plannedNet);

                       //Actual (Total)
                       String actualTotalCost = getTotal(context,projectList, "SELECT_ACTUAL_COST", null,request);
                       String actualTotalBenefit = getTotal(context,projectList, "SELECT_ACTUAL_BENEFIT", null,request);
                       String actualTotalNet = "0.0";
                       double actualNet = Task.parseToDouble(actualTotalBenefit) - Task.parseToDouble(actualTotalCost);
                       actualTotalNet = twoPlaces.format(actualNet);

                       //Planned (Partial)
                       String plannedPartialCost = getTotal(context,projectList, "SELECT_PLANNED_COST", fiscalYear,request);
                       String plannedPartialBenefit = getTotal(context,projectList, "SELECT_PLANNED_BENEFIT", fiscalYear,request);
                       String plannedPartialTotalNet = "0.0";
                       double plannedPartialNet = Task.parseToDouble(plannedPartialBenefit) - Task.parseToDouble(plannedPartialCost);
                       plannedPartialTotalNet = twoPlaces.format(plannedPartialNet);

                       //Actual (Partial)
                       String actualPartialCost = getTotal(context,projectList, "SELECT_ACTUAL_COST", fiscalYear,request);
                       String actualPartialBenefit = getTotal(context,projectList, "SELECT_ACTUAL_BENEFIT", fiscalYear,request);
                       String actualPartialTotalNet = "0.0";
                       double actualPartialNet = Task.parseToDouble(actualPartialBenefit) - Task.parseToDouble(actualPartialCost);
                       actualPartialTotalNet = twoPlaces.format(actualPartialNet);
%>
                 <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                 <td>
                   <%= plannedPartialCost %>
                 </td>
                 <td>
                   <%= plannedPartialBenefit %>
                 </td>
                 <td>
                   <framework:ifExpr expr='<%= plannedPartialNet < 0 %>'>
                     <font color="Red">
                       <%= plannedPartialTotalNet %>
                     </font>
                   </framework:ifExpr>
                   <framework:ifExpr expr='<%= plannedPartialNet >= 0 %>'>
                       <%= plannedPartialTotalNet %>
                   </framework:ifExpr>
                 </td>
                 <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                 <td>
                   <%= plannedTotalCost %>
                 </td>
                 <td>
                   <%= plannedTotalBenefit %>
                 </td>
                 <td>
                   <framework:ifExpr expr='<%= plannedNet < 0 %>'>
                     <font color="Red">
                       <%= plannedTotalNet %>
                     </font>
                   </framework:ifExpr>
                   <framework:ifExpr expr='<%= plannedNet >= 0 %>'>
                       <%= plannedTotalNet %>
                   </framework:ifExpr>
                 </td>
                 <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                 <td>
                   <%= actualPartialCost %>
                 </td>
                 <td>
                   <%= actualPartialBenefit %>
                 </td>
                 <td>
                   <framework:ifExpr expr='<%= actualPartialNet < 0 %>'>
                     <font color="Red">
                       <%= actualPartialTotalNet %>
                     </font>
                   </framework:ifExpr>
                   <framework:ifExpr expr='<%= actualPartialNet >= 0 %>'>
                       <%= actualPartialTotalNet %>
                   </framework:ifExpr>
                 </td>
                 <td class="separator" width="1" style="background-color:white">&nbsp;</td>
                 <td>
                   <%= actualTotalCost %>
                 </td>
                 <td>
                   <%= actualTotalBenefit %>
                 </td>
                 <td>
                   <framework:ifExpr expr='<%= actualNet < 0 %>'>
                     <font color="Red">
                       <%= actualTotalNet %>
                     </font>
                   </framework:ifExpr>
                   <framework:ifExpr expr='<%= actualNet >= 0 %>'>
                       <%= actualTotalNet %>
                   </framework:ifExpr>
                 </td>
              </tr>
            </framework:mapListItr>
          </framework:ifExpr>

          <framework:ifExpr expr="<%= businessGoalList.size() <=0 %>">
             <tr>
               <td>&nbsp;</td>
             </tr>
             <tr>
               <td>&nbsp;</td>
             </tr>
             <tr>
               <td class="noresult" colspan="13" align="center">
                 <emxUtil:i18n localize="i18nId">
                   emxProgramCentral.Common.BusinessGoalNotFound
                 </emxUtil:i18n>
               </td>
              </tr>
          </framework:ifExpr>
        </table>
     </form>
    </body>
  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers

   // Stop hiding here -->//]]>
  </script>
</html>
