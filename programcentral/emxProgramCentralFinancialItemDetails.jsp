<%-- emxProgramCentralFinancialItemDetails.jsp

  Copyright (c) 1992-2018 Dassault Systemes. 
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/15/2002

  static const char RCSID[] = "$Id: emxProgramCentralFinancialItemDetails.jsp.rca 1.18 Wed Oct 22 15:49:34 2008 przemek Experimental przemek $";
--%>

<%@ include file = "emxProgramGlobals2.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ include file="emxProgramCentralFinancialUtil.inc" %>

<%@page import = "com.matrixone.apps.program.Task" %>

<%--Don't have the proper DomainConstants--%>

<jsp:useBean id="financialItem" scope="page" class="com.matrixone.apps.program.FinancialItem"/>
<jsp:useBean id="costItem"      scope="page" class="com.matrixone.apps.program.CostItem"/>
<jsp:useBean id="benefitItem"   scope="page" class="com.matrixone.apps.program.BenefitItem"/>

<%
//  com.matrixone.apps.program.CostItem costItem =
//   (com.matrixone.apps.program.CostItem) DomainObject.newInstance(context, DomainConstants.TYPE_COST_ITEM, "PROGRAM");
//  com.matrixone.apps.program.FinancialItem financialItem =
//   (com.matrixone.apps.program.FinancialItem) DomainObject.newInstance(context, DomainConstants.TYPE_FINANCIAL_ITEM, "PROGRAM");
//  com.matrixone.apps.common.Message message =
//    (com.matrixone.apps.common.Message) DomainObject.newInstance(context, DomainConstants.TYPE_MESSAGE);
%>

<%!

/***********START OF METHOD DECLARATIONS*********************************************/

    //It gives the Net Benefit...
    private String getNetBenefitValue(String strBenefit, String strPlanned)
    {
        String result="0.0";
        try
        {
            double value = Task.parseToDouble(strBenefit) - Task.parseToDouble(strPlanned);
            java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#.00");
            result = twoPlaces.format(value);
        }
        catch(Exception e)
        {
            result="Error";
        }

        return result;
    }





    // It is to get the total for the give range...
    private String getTotalRange(ArrayList str_List, int startValue,int iterateValue)
    {
        String result="0.0";
        int endValue = startValue + (iterateValue-1);

        if(endValue<=str_List.size())
        {
            for(int i=startValue; i<=endValue; i++)
            {
                try
                {
                      double value = Task.parseToDouble(result) + Task.parseToDouble((String)str_List.get(i));
                      java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#.00");
                      result = twoPlaces.format(value);
                }
                catch(Exception e)
                {
                    result="Error";
                    break;
                }
            }
        } else
        {
            result = "Error";
        }
        return result;
    }



    private String getCostItemTotal(MapList costItemMapList, com.matrixone.apps.program.CostItem costItem, String strType)
    {
        String result="0.0";

        if(costItemMapList!=null && !costItemMapList.isEmpty())
        {
            String strName = "";
            if(strType.equals("Planned"))
            {
                strName = costItem.SELECT_PLANNED_COST;
            }
            if(strType.equals("Estimated"))
            {
                strName = costItem.SELECT_ESTIMATED_COST;
            }
            if(strType.equals("Actual"))
            {
                strName = costItem.SELECT_ACTUAL_COST;
            }
                // Finding the total...
            for(int i=0; i<costItemMapList.size(); i++)
            {
                Map costItemMap = (Map) costItemMapList.get(i);
                try
                {
                      double value = Task.parseToDouble(result) + Task.parseToDouble((String)costItemMap.get(strName));
                      java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#.00");
                      result = twoPlaces.format(value);
                }
                catch(Exception e)
                {
                    result="Error";
                    break;
                }
            }
        }
        return result;
    }



    private String getBenefitItemTotal(MapList benefitItemMapList, com.matrixone.apps.program.BenefitItem benefitItem, String strType)
    {
        String result="0.0";

        if(benefitItemMapList!=null && !benefitItemMapList.isEmpty())
        {
            String strName = "";
            if(strType.equals("Planned"))
            {
                strName = benefitItem.SELECT_PLANNED_BENEFIT;
            }
            if(strType.equals("Estimated"))
            {
                strName = benefitItem.SELECT_ESTIMATED_BENEFIT;
            }
            if(strType.equals("Actual"))
            {
                strName = benefitItem.SELECT_ACTUAL_BENEFIT;
            }

            // Finding the total...
            for(int i=0; i<benefitItemMapList.size(); i++)
            {
                Map benefitItemMap = (Map) benefitItemMapList.get(i);
                try
                {
                      double value = Task.parseToDouble(result) + Task.parseToDouble((String)benefitItemMap.get(strName));
                      java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#.00");
                      result = twoPlaces.format(value);
                }
                catch(Exception e)
                {
                    result="Error";
                    break;
                }
            }
        }

        return result;
    }



    //New Method...
    private String getArrayListTotal(ArrayList alList)
    {
        String result = "0.0";

        if(!alList.isEmpty())
        {
            for(int i=0; i<alList.size(); i++)
            {
                try
                {
                      double value = Task.parseToDouble(result) + Task.parseToDouble((String)alList.get(i));
                      java.text.DecimalFormat twoPlaces = new java.text.DecimalFormat("#.00");
                      result = twoPlaces.format(value);
                }
                catch(Exception e)
                {
                    result = "Error";
                    break;
                }
            }
        }
        return result;
    }

/***********END OF METHOD DECLARATIONS*********************************************/

%>

<%
  String sLanguage = request.getHeader("Accept-Language");
  String financialId = (String)emxGetParameter(request, "objectId");

  financialItem.setId(financialId);

  StringList busSelects = new StringList(19);
  busSelects.add(financialItem.SELECT_NAME);
  busSelects.add(financialItem.SELECT_OWNER);
  busSelects.add(financialItem.SELECT_POLICY);
  busSelects.add(financialItem.SELECT_ORIGINATED);
  busSelects.add(financialItem.SELECT_ORIGINATOR);
  busSelects.add(financialItem.SELECT_CURRENT);
  busSelects.add(financialItem.SELECT_ACTUAL_BENEFIT);
  busSelects.add(financialItem.SELECT_ACTUAL_COST);
  busSelects.add(financialItem.SELECT_ACTUAL_NET_BENEFIT);
  busSelects.add(financialItem.SELECT_ESTIMATED_BENEFIT);
  busSelects.add(financialItem.SELECT_ESTIMATED_COST);
  busSelects.add(financialItem.SELECT_ESTIMATED_NET_BENEFIT);
  busSelects.add(financialItem.SELECT_COST_INTERVAL);
  busSelects.add(financialItem.SELECT_BENEFIT_INTERVAL);
  busSelects.add(financialItem.SELECT_NOTES);
  busSelects.add(financialItem.SELECT_PLANNED_BENEFIT);
  busSelects.add(financialItem.SELECT_PLANNED_COST);
  busSelects.add(financialItem.SELECT_PLANNED_NET_BENEFIT);
  busSelects.add(financialItem.SELECT_TOTAL_BUDGET_COST);

  // Get attributes that does not need to be display
  StringList outSelects = new StringList(4);
  outSelects.add(financialItem.SELECT_COST_INTERVAL_START_DATE);
  outSelects.add(financialItem.SELECT_COST_INTERVAL_END_DATE);
  outSelects.add(financialItem.SELECT_BENEFIT_INTERVAL_START_DATE);
  outSelects.add(financialItem.SELECT_BENEFIT_INTERVAL_END_DATE);

  MapList typeMapList = financialItem.getTypeAttributes(context);
  MapList addMapList = new MapList();

  Iterator typeMapListItr = typeMapList.iterator();
  while(typeMapListItr.hasNext())
  {
    Map item = (Map) typeMapListItr.next();
    String attrName = (String) item.get(financialItem.SELECT_NAME);
    String attrType = (String) item.get(financialItem.SELECT_TYPE);

    //store the new attribute(s) to display later (doesn't store the unnecessary attribute(s))
    if (!busSelects.contains("attribute[" + attrName + "]") && !outSelects.contains("attribute[" + attrName + "]"))
    {
      busSelects.add("attribute[" + attrName + "]");
      HashMap newItem = new HashMap();
      newItem.put("NAME", attrName);
      newItem.put("TYPE", attrType);
      addMapList.add(newItem);
    }
  }

  Map financialItemMap = financialItem.getInfo(context, busSelects);

  String costInterval = (String) financialItemMap.get(financialItem.SELECT_COST_INTERVAL);
  String benefitInterval = (String) financialItemMap.get(financialItem.SELECT_BENEFIT_INTERVAL);

  busSelects.clear();
  busSelects.add(costItem.SELECT_ID);
  busSelects.add(costItem.SELECT_NAME);
  busSelects.add(costItem.SELECT_PLANNED_COST);
  busSelects.add(costItem.SELECT_ESTIMATED_COST);
  busSelects.add(costItem.SELECT_ACTUAL_COST);
  MapList costItemMapList = costItem.getCostItems(context, financialItem, busSelects, null);

  busSelects.clear();
  busSelects.add(benefitItem.SELECT_ID);
  busSelects.add(benefitItem.SELECT_NAME);
  busSelects.add(benefitItem.SELECT_PLANNED_BENEFIT);
  busSelects.add(benefitItem.SELECT_ESTIMATED_BENEFIT);
  busSelects.add(benefitItem.SELECT_ACTUAL_BENEFIT);
  MapList benefitItemMapList = benefitItem.getBenefitItems(context, financialItem, busSelects, null);

  String costItemTotalPlanned = getCostItemTotal(costItemMapList, costItem, "Planned");
  String costItemTotalEstimated = getCostItemTotal(costItemMapList, costItem, "Estimated");
  String costItemTotalActual = getCostItemTotal(costItemMapList, costItem, "Actual");
  String benefitItemTotalPlanned = getBenefitItemTotal(benefitItemMapList, benefitItem, "Planned");
  String benefitItemTotalEstimated = getBenefitItemTotal(benefitItemMapList, benefitItem, "Estimated");
  String benefitItemTotalActual = getBenefitItemTotal(benefitItemMapList, benefitItem, "Actual");

  String str_Cur_Year = String.valueOf(getCurrentYear());
  int intTotalCostCols = 0;                             // Total no. of cost item columns...
  int intTotalBenefitCols = 0;                          // Total no. of benefit item columns...
  int intTotalCostItems = costItemMapList.size();       // Total no. of CostItems...
  int intTotalBenefitItems = benefitItemMapList.size(); // Total no. of BenefitItems...

  // Forming arrays for all and current year's amts...
  ArrayList str_CurYear_CDates = new ArrayList();
  ArrayList str_All_CDates = new ArrayList();
  ArrayList str_CurYear_BDates = new ArrayList();
  ArrayList str_All_BDates = new ArrayList();

  ArrayList str_CurYear_CPlans = new ArrayList();
  ArrayList str_All_CPlans = new ArrayList();
  ArrayList str_CurYear_BPlans = new ArrayList();
  ArrayList str_All_BPlans = new ArrayList();

  ArrayList str_CurYear_CEsts = new ArrayList();
  ArrayList str_All_CEsts = new ArrayList();
  ArrayList str_CurYear_BEsts = new ArrayList();
  ArrayList str_All_BEsts = new ArrayList();

  ArrayList str_CurYear_CActs = new ArrayList();
  ArrayList str_All_CActs = new ArrayList();
  ArrayList str_CurYear_BActs = new ArrayList();
  ArrayList str_All_BActs = new ArrayList();

  MapList costItemDataMapList = new MapList();
  MapList benefitItemDataMapList = new MapList();
  int totalCount=0;
  int yearCount=0;
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

    <table border="0" width="100%">
      <tr>
        <td>
          <table border="0" width="100%">
            <tr>
              <td colspan="4" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.OverAllBudget</emxUtil:i18n>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Name</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=financialItemMap.get(financialItem.SELECT_NAME)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Originated</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                  <%=financialItemMap.get(financialItem.SELECT_ORIGINATED)%>
                </framework:lzDate>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Originator</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=financialItemMap.get(financialItem.SELECT_ORIGINATOR)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Owner</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=financialItemMap.get(financialItem.SELECT_OWNER)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Status</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=i18nNow.getStateI18NString((String)financialItemMap.get(financialItem.SELECT_POLICY), (String)financialItemMap.get(financialItem.SELECT_CURRENT), request.getHeader("Accept-Language"))%>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>
          <table border="0" width="100%">
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.TotalProjectPlan</emxUtil:i18n>
              </td>
              <td class="field" align="left">
                <b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.TotalCost</emxUtil:i18n></b>
              </td>
              <td class="field" align="left">
                <b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Benefits</emxUtil:i18n></b>
              </td>
              <td class="field" align="left">
                <b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.NetBenefits</emxUtil:i18n></b>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Plan</emxUtil:i18n>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String) financialItemMap.get(financialItem.SELECT_PLANNED_COST))%>
              </td>
              <td class="field" align="left">
                <%= ProgramCentralUtil.convertDecimal(context, (String) financialItemMap.get(financialItem.SELECT_PLANNED_BENEFIT))%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String) getNetBenefitValue((String)financialItemMap.get(financialItem.SELECT_PLANNED_BENEFIT) , (String)financialItemMap.get(financialItem.SELECT_PLANNED_COST))) %>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Estimate</emxUtil:i18n>
               </td>
               <td class="field" align="left">
                 <%=ProgramCentralUtil.convertDecimal(context, (String)financialItemMap.get(financialItem.SELECT_ESTIMATED_COST))%>
              </td>
              <td Class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)financialItemMap.get(financialItem.SELECT_ESTIMATED_BENEFIT))%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)getNetBenefitValue((String)financialItemMap.get(financialItem.SELECT_ESTIMATED_BENEFIT) , (String)financialItemMap.get(financialItem.SELECT_ESTIMATED_COST))) %>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Actual</emxUtil:i18n>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)financialItemMap.get(financialItem.SELECT_ACTUAL_COST))%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)financialItemMap.get(financialItem.SELECT_ACTUAL_BENEFIT))%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)getNetBenefitValue((String)financialItemMap.get(financialItem.SELECT_ACTUAL_BENEFIT) , (String)financialItemMap.get(financialItem.SELECT_ACTUAL_COST))) %>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <framework:mapListItr mapList="<%= costItemMapList %>" mapName="costItemMap">
<%
  costItem.setId((String)costItemMap.get(costItem.SELECT_ID));
  busSelects.clear();
  busSelects.add(CostItemIntervalRelationship.SELECT_INTERVAL_DATE);
  busSelects.add(CostItemIntervalRelationship.SELECT_PLANNED_COST);
  busSelects.add(CostItemIntervalRelationship.SELECT_ESTIMATED_COST);
  busSelects.add(CostItemIntervalRelationship.SELECT_ACTUAL_COST);

  MapList tempDataList = costItem.getCostItemData(context, busSelects, null);

  if(costItemDataMapList.isEmpty())
  {
      costItemDataMapList = tempDataList;
      if(intTotalCostCols==0)
      {
          intTotalCostCols = tempDataList.size();
      }
  }
  else
  {
      costItemDataMapList.addAll(tempDataList);
  }

%>
      </framework:mapListItr>
      <framework:sortInit
        defaultSortKey="<%= CostItemIntervalRelationship.SELECT_INTERVAL_DATE %>"
        defaultSortType="date"
        mapList="<%= costItemDataMapList %>"/>

      <framework:mapListItr mapList="<%= benefitItemMapList %>" mapName="benefitItemMap">
<%
  benefitItem.setId((String)benefitItemMap.get(benefitItem.SELECT_ID));
  busSelects.clear();
  busSelects.add(BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE);
  busSelects.add(BenefitItemIntervalRelationship.SELECT_PLANNED_BENEFIT);
  busSelects.add(BenefitItemIntervalRelationship.SELECT_ESTIMATED_BENEFIT);
  busSelects.add(BenefitItemIntervalRelationship.SELECT_ACTUAL_BENEFIT);

  MapList tempDataList = benefitItem.getBenefitItemData(context, busSelects, null);

  if(benefitItemDataMapList.isEmpty())
  {
      benefitItemDataMapList = tempDataList;
      if(intTotalBenefitCols==0)
      {
          intTotalBenefitCols = tempDataList.size();
      }
  }
  else
  {
      benefitItemDataMapList.addAll(tempDataList);
  }
%>
      </framework:mapListItr>
      <framework:sortInit defaultSortKey="<%= BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE %>"
                          defaultSortType="date"
                          mapList="<%= benefitItemDataMapList %>"/>
      <framework:mapListItr mapList="<%= costItemDataMapList %>" mapName="costDataMap">
<%
  String strDate = (String)costDataMap.get(CostItemIntervalRelationship.SELECT_INTERVAL_DATE);
  String strPlan = (String)costDataMap.get(CostItemIntervalRelationship.SELECT_PLANNED_COST);
  String strEst = (String)costDataMap.get(CostItemIntervalRelationship.SELECT_ESTIMATED_COST);
  String strAct = (String)costDataMap.get(CostItemIntervalRelationship.SELECT_ACTUAL_COST);

  str_All_CDates.add(totalCount,strDate);
  str_All_CPlans.add(totalCount,strPlan);
  str_All_CEsts.add(totalCount,strEst);
  str_All_CActs.add(totalCount,strAct);

  if(strDate.indexOf(str_Cur_Year)!=-1)
  {
      str_CurYear_CDates.add(yearCount,strDate);
      str_CurYear_CPlans.add(yearCount,strPlan);
      str_CurYear_CEsts.add(yearCount,strEst);
      str_CurYear_CActs.add(yearCount,strAct);
      yearCount++;
  }
  totalCount++;

%>
      </framework:mapListItr>

<%
  // reset counters
  totalCount = 0;
  yearCount = 0;
 %>

      <framework:mapListItr mapList="<%= benefitItemDataMapList %>" mapName="benefitDataMap">
<%
  String strDate = (String)benefitDataMap.get(BenefitItemIntervalRelationship.SELECT_INTERVAL_DATE);
  String strPlan = (String)benefitDataMap.get(BenefitItemIntervalRelationship.SELECT_PLANNED_BENEFIT);
  String strEst = (String)benefitDataMap.get(BenefitItemIntervalRelationship.SELECT_ESTIMATED_BENEFIT);
  String strAct = (String)benefitDataMap.get(BenefitItemIntervalRelationship.SELECT_ACTUAL_BENEFIT);

  str_All_BDates.add(totalCount,strDate);
  str_All_BPlans.add(totalCount,strPlan);
  str_All_BEsts.add(totalCount,strEst);
  str_All_BActs.add(totalCount,strAct);

  if(strDate.indexOf(str_Cur_Year)!=-1)
  {
      str_CurYear_BDates.add(yearCount,strDate);
      str_CurYear_BPlans.add(yearCount,strPlan);
      str_CurYear_BEsts.add(yearCount,strEst);
      str_CurYear_BActs.add(yearCount,strAct);
      yearCount++;
  }
  totalCount++;

%>
      </framework:mapListItr>

<%
  String str_CurYearCostPlannedTotal = getArrayListTotal(str_CurYear_CPlans);
  String str_CurYearCostEstimatedTotal = getArrayListTotal(str_CurYear_CEsts);
  String str_CurYearCostActualTotal = getArrayListTotal(str_CurYear_CActs);
  String str_CurYearBenefitPlannedTotal = getArrayListTotal(str_CurYear_BPlans);
  String str_CurYearBenefitEstimatedTotal = getArrayListTotal(str_CurYear_BEsts);
  String str_CurYearBenefitActualTotal = getArrayListTotal(str_CurYear_BActs);
%>

      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>
          <table border="0" width="100%">
            <tr>
              <td align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.CurrentYear</emxUtil:i18n>
              </td>
              <td align="left" class="field">
                <b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.TotalCost</emxUtil:i18n></b>
              </td>
              <td align="left" class="field">
                <b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Benefits</emxUtil:i18n></b>
              </td>
              <td align="left" class="field">
                <b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.NetBenefits</emxUtil:i18n></b>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Plan</emxUtil:i18n>
              </td>
              <td class="field" align="left">
               <%=ProgramCentralUtil.convertDecimal(context, (String)str_CurYearCostPlannedTotal)%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)str_CurYearBenefitPlannedTotal)%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)getNetBenefitValue(str_CurYearBenefitPlannedTotal , str_CurYearCostPlannedTotal)) %>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Estimate</emxUtil:i18n>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)str_CurYearCostEstimatedTotal)%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)str_CurYearBenefitEstimatedTotal)%>
              </td>
              <td class="field" align="left">
               <%=ProgramCentralUtil.convertDecimal(context, (String)getNetBenefitValue(str_CurYearBenefitEstimatedTotal , str_CurYearCostEstimatedTotal)) %>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Actual</emxUtil:i18n>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)str_CurYearCostActualTotal)%>
              </td>
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)str_CurYearBenefitActualTotal)%>
              </td>
              <td class="field" align="left">
               <%=ProgramCentralUtil.convertDecimal(context, (String)getNetBenefitValue(str_CurYearBenefitActualTotal , str_CurYearCostActualTotal)) %>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>
          <table border="0" width="100%">
            <tr>
              <td colspan="4" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.CostBudgetItemRollup</emxUtil:i18n>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Plan</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)costItemTotalPlanned)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Estimate</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)costItemTotalEstimated)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Actual</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)costItemTotalActual)%>
              </td>
            </tr>
          </table>
        </td>
      </tr>
<%

  int noTables = (int)(intTotalCostCols/12 + 1);

  if(((noTables-1) * 12) == intTotalCostCols)
  {
      noTables--;
  }

  for(int tableNo=1; tableNo<=noTables; tableNo++)
  {

      boolean hasMonthly   = costInterval.equals("Monthly");
      boolean hasWeekly    = costInterval.equals("Weekly");
      boolean hasQuarterly = costInterval.equals("Quarterly");
%>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>
          <table border="0">
            <tr>
              <td align="left" class="label">
                <framework:ifExpr expr="<%=  hasMonthly %>">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.MonthlyBreakDown</emxUtil:i18n>
                </framework:ifExpr>
                <framework:ifExpr expr="<%=  hasWeekly %>">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.WeeklyBreakDown</emxUtil:i18n>
                </framework:ifExpr>
                <framework:ifExpr expr="<%=  hasQuarterly %>">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.QuarterlyBreakDown</emxUtil:i18n>
                </framework:ifExpr>
              </td>
<%
      for(int i=0; i<12; i++)
      {
          int cur_ColNo = i + ((tableNo-1) * 12);
          int cur_ArrayColNo = cur_ColNo * intTotalCostItems;
%>
            <framework:ifExpr expr="<%= cur_ColNo < intTotalCostCols %>">
              <td class="field" align="left" nowrap="nowrap">
                <framework:ifExpr expr="<%=  hasWeekly %>">
                  <b><framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                   <%=getHeader((String)str_All_CDates.get(cur_ArrayColNo),costInterval, sLanguage)%>
                  </framework:lzDate></b>
                </framework:ifExpr>

                <framework:ifExpr expr="<%=  !hasWeekly %>">
                  <b><%=getHeader((String)str_All_CDates.get(cur_ArrayColNo),costInterval, sLanguage)%></b>
                </framework:ifExpr>
              </td>
            </framework:ifExpr>
<%

        if(!(cur_ColNo < intTotalCostCols))
        {
          break;
        }
      }

%>

            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Plan</emxUtil:i18n>
              </td>
<%
      for(int i=0; i<12; i++)
      {
          int cur_ColNo = i + ((tableNo-1) * 12);
          int cur_ArrayColNo = cur_ColNo * intTotalCostItems;
%>
            <framework:ifExpr expr="<%= cur_ColNo < intTotalCostCols %>">
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)getTotalRange(str_All_CPlans,cur_ArrayColNo,intTotalCostItems))%>
              </td>
            </framework:ifExpr>
<%

        if(!(cur_ColNo < intTotalCostCols))
        {
          break;
        }
      }

%>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Estimate</emxUtil:i18n>
              </td>
<%
      for(int i=0; i<12; i++)
      {
          int cur_ColNo = i + ((tableNo-1) * 12);
          int cur_ArrayColNo = cur_ColNo * intTotalCostItems;
%>
            <framework:ifExpr expr="<%= cur_ColNo < intTotalCostCols %>">
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)getTotalRange(str_All_CEsts,cur_ArrayColNo,intTotalCostItems))%>
              </td>
            </framework:ifExpr>
<%

        if(!(cur_ColNo < intTotalCostCols))
        {
          break;
        }
      }

%>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Actual</emxUtil:i18n>
              </td>
<%
      for(int i=0; i<12; i++)
      {
          int cur_ColNo = i + ((tableNo-1) * 12);
          int cur_ArrayColNo = cur_ColNo * intTotalCostItems;
%>
            <framework:ifExpr expr="<%= cur_ColNo < intTotalCostCols %>">
              <td class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)getTotalRange(str_All_CActs,cur_ArrayColNo,intTotalCostItems))%>
              </td>
            </framework:ifExpr>
<%

        if(!(cur_ColNo < intTotalCostCols))
        {
          break;
        }
      }

%>

              </tr>
            </table>
          </td>
        </tr>
<%
  }
%>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>
          <table border="0" width="100%">
            <tr>
              <td colspan="4" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.BenefitBudgetItemRollup</emxUtil:i18n>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Plan</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)benefitItemTotalPlanned)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Estimate</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)benefitItemTotalEstimated)%>
              </td>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Actual</emxUtil:i18n>
              </td>
              <td colspan="3" class="field" align="left">
                <%=ProgramCentralUtil.convertDecimal(context, (String)benefitItemTotalActual)%>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>
<%
  noTables = (int)(intTotalBenefitCols/12 + 1);
  if(((noTables-1) * 12) == intTotalBenefitCols)
  {
      noTables--;
  }

  for(int tableNo=1; tableNo<=noTables; tableNo++)
  {
      boolean hasMonthly   = benefitInterval.equals("Monthly");
      boolean hasWeekly    = benefitInterval.equals("Weekly");
      boolean hasQuarterly = benefitInterval.equals("Quarterly");

%>
          <table border="0">
            <tr>
              <td width="30%" align="left" class="label">
                <framework:ifExpr expr="<%=  hasMonthly %>">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.MonthlyBreakDown</emxUtil:i18n>
                </framework:ifExpr>
                <framework:ifExpr expr="<%=  hasWeekly %>">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.WeeklyBreakDown</emxUtil:i18n>
                </framework:ifExpr>
                <framework:ifExpr expr="<%=  hasQuarterly %>">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.QuarterlyBreakDown</emxUtil:i18n>
                </framework:ifExpr>
              </td>
<%
     for(int i=0; i<12; i++)
     {
         int cur_ColNo = i + ((tableNo-1) * 12);
         int cur_ArrayColNo = cur_ColNo * intTotalBenefitItems;
%>
            <framework:ifExpr expr="<%=  cur_ColNo < intTotalBenefitCols %>">
              <td class="field" align="left" nowrap="nowrap">
                <framework:ifExpr expr="<%=  hasWeekly %>">
                  <b>
                    <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                      <%=getHeader((String)str_All_BDates.get(cur_ArrayColNo),benefitInterval, sLanguage)%>
                    </framework:lzDate>
                  </b>
                </framework:ifExpr>

                <framework:ifExpr expr="<%=  !hasWeekly %>">
                  <b><%=getHeader((String)str_All_BDates.get(cur_ArrayColNo),benefitInterval, sLanguage)%></b>
                </framework:ifExpr>
              </td>
            </framework:ifExpr>
<%

       if(!(cur_ColNo < intTotalBenefitCols))
       {
         break;
       }
     }

%>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Plan</emxUtil:i18n>
              </td>
<%
     for(int i=0; i<12; i++)
     {
       int cur_ColNo = i + ((tableNo-1) * 12);
       int cur_ArrayColNo = cur_ColNo * intTotalBenefitItems;
%>
              <framework:ifExpr expr="<%=  cur_ColNo < intTotalBenefitCols %>">
                <td class="field" align="left">
                  <%=ProgramCentralUtil.convertDecimal(context, (String)getTotalRange(str_All_BPlans,cur_ArrayColNo,intTotalBenefitItems))%>
                </td>
              </framework:ifExpr>
<%
       if(!(cur_ColNo < intTotalBenefitCols))
       {
         break;
       }
     }
%>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Estimate</emxUtil:i18n>
              </td>
<%
     for(int i=0; i<12; i++)
     {
       int cur_ColNo = i + ((tableNo-1) * 12);
       int cur_ArrayColNo = cur_ColNo * intTotalBenefitItems;
%>
              <framework:ifExpr expr="<%=  cur_ColNo < intTotalBenefitCols %>">
                <td class="field" align="left">
                  <%=ProgramCentralUtil.convertDecimal(context, (String)getTotalRange(str_All_BEsts,cur_ArrayColNo,intTotalBenefitItems))%>
                </td>
              </framework:ifExpr>
<%
       if(!(cur_ColNo < intTotalBenefitCols))
       {
         break;
       }
     }
%>
            </tr>
            <tr>
              <td width="30%" align="left" class="label">
                <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Actual</emxUtil:i18n>
              </td>
<%
     for(int i=0; i<12; i++)
     {
       int cur_ColNo = i + ((tableNo-1) * 12);
       int cur_ArrayColNo = cur_ColNo * intTotalBenefitItems;
%>
              <framework:ifExpr expr="<%=  cur_ColNo < intTotalBenefitCols %>">
                <td class="field" align="left">
                  <%=ProgramCentralUtil.convertDecimal(context, (String)getTotalRange(str_All_BActs,cur_ArrayColNo,intTotalBenefitItems))%>
                </td>
              </framework:ifExpr>
<%
       if(!(cur_ColNo < intTotalBenefitCols))
       {
         break;
       }
     }
%>
            </tr>
          </table>
<% } %>

          <table border="0" width="100%">
            <tr>
              <framework:mapListItr mapList="<%= addMapList %>" mapName="itemMap">
                <tr>
                  <td width="30%" align="left" class="label">
                    <%= i18nNow.getAttributeI18NString((String)itemMap.get("NAME"),sLanguage) %>
                  </td>
                  <td colspan="3" class="field" align="left">
                    <framework:ifExpr expr='<%=itemMap.get("TYPE").equals("timestamp")%>'>
                      <framework:lzDate localize="i18nId" tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate="true">
                      <%= financialItemMap.get("attribute[" + itemMap.get("NAME") + "]") %></framework:lzDate>
                    </framework:ifExpr>
                    <framework:ifExpr expr='<%=!(itemMap.get("TYPE").equals("timestamp"))%>'>
                      <%= financialItemMap.get("attribute[" + itemMap.get("NAME") + "]")%>
                    </framework:ifExpr>
                  </td>
                </tr>
              </framework:mapListItr>
            </tr>
          </table>
        </td>
      </tr>
    </table>

  </body>

<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%></html>

