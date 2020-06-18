<%--  emxRouteInclude.inc  --  Route Include File 

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteInclude.inc.rca 1.50 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $
--%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.lang.reflect.*,
                   java.text.*" errorPage="emxComponentsError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.CertificationHolder,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.FileFormatHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.MarkupHolder,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.MultipleOwner,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.OrganizationList,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.PurchaseClassHolder,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.SketchHolder,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.UserTask,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault
                    " %>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@include file = "../emxTagLibInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%@include file = "../emxI18NMethods.inc"%>


<%!
  static String appDirectory = null;
%>

<%!
        private static synchronized void init(HttpSession session) 
                throws matrix.util.MatrixException, com.matrixone.apps.domain.util.FrameworkException, Exception
        {
                if (appDirectory != null ) return;
                matrix.db.Context ctx = Framework.getFrameContext(session);
                try {
    appDirectory = (String)FrameworkProperties.getProperty(ctx,"eServiceSuiteComponents.Directory");
                } finally {
                                ctx.shutdown();
                }
         }
%>

<%
        init(session);
  final String sLanguage = request.getHeader("Accept-Language");
	String DateFrm ="";
%>


<%!
  //
  public static String getAppProperty(Context context, ServletContext application, String key) throws Exception
  {
    String appProps = null;
    try {
                        appProps = FrameworkProperties.getProperty(context,key);
    }
                catch(Exception e)
                { }
    return appProps;
  }
%>

<%!
  //
  // return the requested attribute value from BusinessObject
  //
  static public String getAttribute(matrix.db.Context context, HttpSession session,
                                    BusinessObject busObj,
                                    String attrName) throws MatrixException
  {
    if (busObj == null){
      return "";
      }

    //matrix.db.Context context = getPageContext();
    StringList selectStmts = new StringList();
    selectStmts.addElement("attribute[" + attrName + "]");

    BusinessObjectWithSelect _objectSelect = null;
    try {
      _objectSelect = busObj.select(context, selectStmts);
    }
    catch (MatrixException e)
    {
      busObj.open(context);
      _objectSelect = busObj.select(context, selectStmts);
      busObj.close(context);
    }
    finally {
      return _objectSelect.getSelectData("attribute[" + attrName + "]");
    }
  }
%>

<%!
  //
  // returns whether the BO is last revision or not.
  //
  static public boolean isLastRevision(Context context,String busObjID) throws MatrixException
  {
      MQLCommand command = new MQLCommand();
      command.open(context);
      String strMQL = "print bus " +  busObjID + " select last.id dump";
      command.executeCommand(context,strMQL);

      String strRes = command.getResult().trim();
      command.close(context);
      if (strRes.length() == 0) {
        throw new MatrixException("No results returned");
      } else if(strRes.equals(busObjID)) {
        return true;
      } else {
        return false;
      }
  }
%>


<%!
// set Scheduled Complete Date attribute for all RouteNodes constructed from this maplist;
//The Completion Due Date is got by adding Offset days attribute to current System date-time

static public void setDueDatesFromOffset(Context context, ServletContext application, HttpSession session, MapList offsetList,HttpServletRequest request){

  String attrDueDateOffset      = PropertyUtil.getSchemaProperty(context, "attribute_DueDateOffset");
  String selDueDateOffset       = "attribute["+attrDueDateOffset+"]";

  Map rNodeMap                     = null;
  Relationship relObjRouteNode     = null;
  Attribute scheduledDateAttribute = null;
  AttributeList timeAttrList       = new AttributeList();
  GregorianCalendar cal            = new GregorianCalendar();
  GregorianCalendar offSetCal      = new GregorianCalendar();
  SimpleDateFormat formatterTest   = new SimpleDateFormat (eMatrixDateFormat.getInputDateFormat(),Locale.US);
  double clientTZOffset            = (new Double((String)session.getValue("timeZone"))).doubleValue();

  Iterator nextOrderOffsetItr      = offsetList.iterator();

  // get the equivalent server time with required timezone
//  cal.setTime(new Date(cal.getTime().getTime() + (new Double(clientTZOffset*(1000*60*60))).intValue())); commented on 8th March
 cal.setTime(new Date(cal.getTime().getTime())); //modified on 8th March
  String routeTaskScheduledDateStr  = "";
  String rNodeId                    = "";
  String duedateOffset              = "";

  while(nextOrderOffsetItr.hasNext()) {
    // use separate calendar objects and reset offSetCal to master calendar to ensure
    // all delta tasks are offset from same Route Start Time.
    offSetCal      = (GregorianCalendar)cal.clone();
    rNodeMap       = (Map) nextOrderOffsetItr.next();
    rNodeId        = (String)rNodeMap.get(DomainObject.SELECT_RELATIONSHIP_ID);
    duedateOffset  = (String)rNodeMap.get(selDueDateOffset);
    // construct corresponding RouteNode relationships and now set correct due-date
    // by adding delta offset to Current time (Route Start) time
    relObjRouteNode             = new Relationship(rNodeId);
    offSetCal.add(Calendar.DATE, Integer.parseInt(duedateOffset));
    routeTaskScheduledDateStr   = formatterTest.format(offSetCal.getTime());
    scheduledDateAttribute      = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE) ,routeTaskScheduledDateStr);
    timeAttrList.add(scheduledDateAttribute);
    // need to push context to set Scheduled Completion date attribute
    try{
      ContextUtil.pushContext(context);
      relObjRouteNode.setAttributes(context,timeAttrList);
      ContextUtil.popContext(context);
    }catch(Exception ex)
    {
     session.putValue("error.message",ex.toString());
    }
  }
}

%>


<%!
  //
  // returns a type name, or a value from the TC propery file
  //
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
  static public String i18NUserType(HttpServletRequest request, String sType) throws MatrixException, Exception
  {

    String sTypeval = "";
    //to remove blank spaces in between the sType  passed
    StringTokenizer stTemp = new StringTokenizer(sType," ",false);
    while (stTemp.hasMoreTokens()) {
      sTypeval  += stTemp.nextToken();
    }
    String slanguages = request.getHeader("Accept-Language");
    String value = i18nNow.getTypeI18NString(sTypeval, slanguages);
    // if the value was not found in the framework type list,
    // look in the TC property file
    if((!slanguages.startsWith("en")) && value.equals(sTypeval)) {
      value = i18nNow.getI18nString("emxComponents.Common."+value, "emxComponentsStringResource", request.getHeader("Accept-Language"));
    }
    return value;
  }
%>



<%!
//added on 23rd dec
public MapList getRolesorGroups(StringList roleList, String type, MapList taskMapList) throws MatrixException
{
  MapList tempRoleMapList = new MapList();
  DomainObject personObject= null;
  int routeNodeIds           = 0;
  int tempRouteNodeIds       = 0;
  boolean allowExtend         = true;
  routeNodeIds                = taskMapList.size();
  for( int count = 0; count < roleList.size(); count++ )  {
    String roleName = (String)roleList.elementAt(count);

    if(!"".equals(roleName)) {
      HashMap tempMap = new HashMap();
      tempMap.put("name", roleName);
      tempMap.put("LastFirstName", roleName);
      tempMap.put("type", type);
      tempMap.put("projectLead", "");
      tempMap.put("createRoute", "");
      tempMap.put("OrganizationName","");
      tempMap.put("access","Read");
      tempMap.put(DomainConstants.SELECT_ID , type);
      tempRoleMapList.add((Map)tempMap);

      boolean updatedMapList = false;
      Iterator mapItr = taskMapList.iterator();
      while(mapItr.hasNext()){
        HashMap taskMap = (HashMap)mapItr.next();
        if("none".equals((String)taskMap.get("PersonId"))){
          taskMap.put("PersonId",type);
          taskMap.put("PersonName",roleName);
          taskMap.put(DomainConstants.SELECT_NAME,roleName);
          updatedMapList = true;
          break;
        }
      }

     if(!updatedMapList && allowExtend){
        //For the 4the Step
        HashMap tempHashMap = new HashMap();
        tempHashMap.put("name", roleName);
        tempHashMap.put("PersonId", type);
        tempHashMap.put("PersonName", roleName);
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_SEQUENCE,"");
        tempHashMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_ACTION ,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_INSTRUCTIONS ,"");
        tempHashMap.put(personObject.ATTRIBUTE_TITLE ,"");
        tempHashMap.put(personObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,"");
        tempHashMap.put(personObject.RELATIONSHIP_ROUTE_NODE,String.valueOf(routeNodeIds));
        taskMapList.add((Map)tempHashMap);
		++routeNodeIds;
      }
    }
  }

  return tempRoleMapList;
}
%>
<%!
public String getTaskSetting(Context context,String templateId) throws Exception
{
        String   sTaskEditSetting ="";
        if(templateId != null && !"".equals(templateId) && !templateId.equals("null"))
        {
                DomainObject routeTempObj = DomainObject.newInstance(context ,templateId);
                sTaskEditSetting = routeTempObj.getAttributeValue(context,DomainObject.ATTRIBUTE_TASKEDIT_SETTING);
         }
         if(sTaskEditSetting == null)
         {
                sTaskEditSetting = "";
         }
         return sTaskEditSetting;
 }
 /**
 Method to clear the Form Bean Data
 This method will be called
        1. On loading of the simple route page
        2. On cancellation of Simple Route page
        3.  On Completion of Simple Route Process.
 */
 public void clearFormBean(FormBean formBean)
 {
	formBean.clear();
 }

%>

