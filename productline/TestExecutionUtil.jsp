<%--  TestExecutionUtil.jsp


  Copyright (c) 2005-2018 Dassault Systemes.  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/TestExecutionUtil.jsp 1.5.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$"

 --%>
<%--
@quickreview T25 DJH 13:07:31 : HL "Test Execution under Test Case without an EC". Modified create() and collectAndConnectAllParentTestCases(). Added support for relationship TEST EXECUTION TEST CASE.
@quickreview T25 DJH 13:08:20 : IR IR-248494V6R2014x : "Test Execution creation window is KO" : Modified code to open slidein window instead of pop up for Test Execution Creation.
@quickreview T25 DJH 13:09:25 : IR IR-257456V6R2014x : "Test Execution creation slide-in window is not getting closed after Test Execution creation.
@quickreview T25 DJH 13:11:18 : IR IR-268641V6R2014x : "After creation of Test execution focus switches from test execution list page to test execution properties page.
@quickreview T25 T25 14:04:23 : HL Parameter under Test Case. Create clone of parameter which are under Test Case.
@quickreview LX6 JX5 14:06:06 : IR-302553-3DEXPERIENCER2015x R216-STP: Creation of Test Execution display script error and tree view does not show newly create Test Execution.
@quickreview JX5 QYG 15:02:12 : HL Widgetization - mode createTestExecution & refresh
@quickreview JX5 QYG 15:06:26 : HL Widgetization - autoname checked by default
@quickreview KIE1 ZUD 16:06:28 :IR-451103-3DEXPERIENCER2016x : R418-STP: On 2016x code for Parameters under Test Executions highlight should either be completely there or completely removed for proper working of functionality.
@quickreview KIE1 ZUD 16:01:22 : HL Parameter Under Test Execution
@quickreview HAT1 ZUD 16:05:03 : Populating title as per autoName of Name in Web form. & Refreshing slide in frame.
@quickreview HAT1 ZUD 16:05:17  IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
@quickreview HAT1 ZUD 16:05:25 :IR-439337-3DEXPERIENCER2017x: R419-STP: Test Execution is getting created under Test Case which are Obsolete or Released.
@quickreview KIE1     16:11:15 : R417-FUN045210:FQA: Test Case side tree structure is not getting refreshed after creation of Parameter under test case.
@quickreview KIE1 ZUD 16:12:14 : IR-480539-3DEXPERIENCER2018x: R419-UX: Improper header for Create Requirement Specification, Requirement, Chapter, comment slideIn
@quickreview KIE1 ZUD 17:02:21 : IR-486616-3DEXPERIENCER2018x-FUN055836: R419-STP: Wrong Valuation Type value getting copied for paramters in Test Execution from Test Cases.

 --%>
<%@page import="com.dassault_systemes.knowledge_itfs.IKweList"%>
<%@page import="com.dassault_systemes.parameter_interfaces.IPlmParameter.PLMParm_ValuationType"%>
<%@page import="com.dassault_systemes.parameter_interfaces.IPlmParameterUtilities"%>
<%@page import="com.dassault_systemes.knowledge_itfs.IKweType"%>
<%@page import="com.dassault_systemes.knowledge_itfs.IKweUnit"%>
<%@page import="com.dassault_systemes.parameter_interfaces.IPlmParameter.PLMParm_ValuationType"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../common/enoviaCSRFTokenValidation.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%@page import="com.matrixone.apps.productline.TestExecution"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.dassault_systemes.parameter_interfaces.IPlmParameter"%>
<%@page import="com.dassault_systemes.parameter_interfaces.IPlmParameter.PLMParm_ValuationType"%>
<%@page import="com.dassault_systemes.parameter_interfaces.IPlmParameterDisplay"%>
<%@page import="com.dassault_systemes.parameter_interfaces.ParameterInterfacesServices" %>


<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%
    //initializing the mode
    String strMode = null;
    boolean bIsError = false;
    try {
        //Instantiating the TestExecution bean
        TestExecution TEBean = (TestExecution)DomainObject.newInstance(context,ProductLineConstants.TYPE_TEST_EXECUTION,"ProductLine");

        //Instantiating the ProductLineCommon bean
        ProductLineCommon commonBean = new ProductLineCommon();
        //Instantiating the FormBean
        FormBean formBean = new FormBean();
        //Processing the form using FormBean.processForm
        formBean.processForm(session,request);
        //Getting the mode from the Command
        strMode = emxGetParameter(request,"mode");
        //gets tree Id from Dialog page
        String strTreeId = emxGetParameter(request,"jsTreeID");
        if (strTreeId == null) {
            strTreeId = "";
        }
        String strTEObjId = "";
       String Checkedparameter =  emxGetParameter(request, "Checkedparameter");
        //when Done button is clicked on Create Dialog page
        if ( strMode.equalsIgnoreCase("create") ) {
            //Calling the create Method of TestExecution.java
            strTEObjId = TEBean.create(context,formBean);
             /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
              String strObjId = emxGetParameter(request, "busId");
              String strRelName = TEBean.getRelName(context,strObjId);
              String strSelectRelId = "";
              // start: added condition for HL Test Execution under Test Case without an EC
              if(strRelName.equals(ProductLineConstants.RELATIONSHIP_TEST_EXECUTION_TEST_CASE))
              {
            	 //this relationship will hold between (From)TE - (To)TC, when Test Case is created directly under Requirement
                 strSelectRelId = "from["+strRelName+"].id";
              }
              else
              {
            	  strSelectRelId = "to["+strRelName+"].id";
              }
              // end: added condition for HL STest Execution under Test Case without an EC
              DomainObject domObjTE = DomainObject.newInstance(context,strTEObjId);
            		  
              //t25
              if(Checkedparameter!=null && Checkedparameter.equals("true")){
              			String toTypeName = PropertyUtil.getSchemaProperty(context, "type_PlmParameter");
			  String relationships = PropertyUtil.getSchemaProperty(context, "relationship_ParameterAggregation");
            
           DomainObject dom = new DomainObject(strObjId);
            int sRecurse = 0;
            
            StringList objSelects = new StringList(1);
            objSelects.addElement(DomainConstants.SELECT_LEVEL);
            objSelects.addElement("id[connection]");
            objSelects.addElement(DomainConstants.SELECT_ID);
            objSelects.addElement(DomainConstants.SELECT_RELATIONSHIP_NAME);
            
            StringList relSelects = new StringList(DomainConstants.SELECT_RELATIONSHIP_ID);
            
            MapList relBusObjPageList = new MapList();
            
            relBusObjPageList = dom.getRelatedObjects(context,
            		relationships,
            		toTypeName,
            		objSelects,
            		null,
                    false,
                    true,
                    (short)0,
                    null,
                    null);
            
        
        for (int i = 0; i < relBusObjPageList.size(); i++)
        {
        	Map ParamObj = (Map)relBusObjPageList.get(i);
        	String selObjId = (String)ParamObj.get("id");
       	DomainObject strParameter = new DomainObject(selObjId);
  String name = strParameter.getInfo(context, DomainConstants.SELECT_NAME);
  String strTEName = domObjTE.getInfo(context, DomainConstants.SELECT_NAME);
  name= strTEName + "_" + name;
  String revision = strParameter.getInfo(context, DomainConstants.SELECT_REVISION);
  String vault = strParameter.getInfo(context, DomainConstants.SELECT_VAULT);
    
  DomainObject newObj2 = new DomainObject(strParameter.cloneObject(context, name, revision, vault, true));

              // Connect Parameter connected to Test Case under Test Execution:
            DomainRelationship.connect(context, domObjTE, "ParameterAggregation", newObj2);
   
   
        }

        }
            
              //t25
              String strRelId = domObjTE.getInfo(context,strSelectRelId);
             /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/

%>
<script language="javascript" type="text/javaScript">
<%
                //if TE is created from Context
                //next gen UI Changes for IR-080167V6R2012  treeid is not present in new UI
              //  if( !("".equals(strTreeId) || "null".equalsIgnoreCase(strTreeId)) ) {
%>
				getTopWindow().closeSlideInDialog();
				refreshStructureTree();
				window.getTopWindow().refreshTablePage();
             //End: T25 DJH :IR IR-248494V6R2014x
		         //End: T25 DJH :IR IR-268641V6R2014x
            </script>
<%
        }
              else if(strMode.equalsIgnoreCase("createTestExecution")){
            	String strObjectId = emxGetParameter(request, "objectId");
            	
                // ++ HAT1 ZUD: IR-439337-3DEXPERIENCER2017x: fix
            	DomainObject bo = DomainObject.newInstance(context, strObjectId);
        		State curState = bo.getCurrentState(context);
        		String strState = curState.getName();

        		if(strState.equals("Obsolete"))
        		{
        		  throw new Exception("modifyObsoleteState");
        		}	
                // -- HAT1 ZUD: IR-439337-3DEXPERIENCER2017x: fix
        		else
        		{
      		  	String openerFrame = emxGetParameter(request, "openerFrame");
			
				String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxProduct.form.create.autonamechecked");
	          	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
	          		autonameChecked = "true";
	          	}
	          
      		  	//Need to check the relationship and direction
      		  	String relName = TEBean.getRelName(context, strObjectId);
      		  	String direction = "";
      		  	if(relName.equals(ProductLineConstants.RELATIONSHIP_TEST_EXECUTION_TEST_CASE)){
      		  		direction = "to";
      		  	}else{
      		  		direction = "from";
      		  	}
      		  	
      		  	relName = FrameworkUtil.getAliasForAdmin(context, "relationship", relName, true);  
      		  	    		  
%>
<script language="javascript" type="text/javaScript">
				//refresh UI
      	    	var url= "../common/emxCreate.jsp?submitAction=xmlMessage&postProcessURL=../productline/TestExecutionUtil.jsp?mode=refresh";
      	    	url += "&direction="+"<%=direction%>";
      	    	url += "&relationship="+"<%=relName%>";                                     
      	    	url += "&type=type_TestExecution&policy=policy_TestExecution&typeChooser=true&nameField=program&form=PLCCreateTestExecution&header=emxProduct.ActionLink.Create&showApply=true&suiteKey=ProductLine&windowMode=slidein&targetLocation=slidein"; // HAT1 ZUD: Populating title as per autoName of Name in Web form. --> nameField=autoName
      	    	url += "&objectId="+"<%=strObjectId%>";
      	    	url += "&openerFrame="+"<%=openerFrame%>";

      	    	getTopWindow().showSlideInDialog(url, true, window.name,"",550);
      	    	</script>
<%
              }
        	  }
              else if(strMode.equalsIgnoreCase("refresh")){
        		  
        		  String openerFrame = emxGetParameter(request, "openerFrame");
        		  
        		  String objectId = emxGetParameter(request, "objectId");
        		  String newObjectId = emxGetParameter(request,"newObjectId");
        		  String copyParameter = emxGetParameter(request,"CopyParameter");
        		  String fullparam = emxGetParameter(request, "CopySubStructure");
        		  String prefix = emxGetParameter(request, "Title Prefix");
        		  String xmlmsg = emxGetParameter(request, "CopyScope");
        		  
        		  //make sure we have the correct context
        		  matrix.db.Context myContext = (matrix.db.Context)request.getAttribute("context");
        		  
  	          	  Map<String, String> argsMap = new HashMap<String,String>();
  	          	  argsMap.put("testCaseId",objectId);
  	          	  argsMap.put("testExeId", newObjectId);
  	              argsMap.put("copyParam", copyParameter);
  	              argsMap.put("prefixName", prefix); 
  	              argsMap.put("subStructure",fullparam);
  	              argsMap.put("xmlmsg",xmlmsg);
  	              
  	          	  TestExecution.createTestExeStructure(myContext, argsMap);
  	         
        		  %>
        		  <script language="JavaScript">
        		          	  	   var openerFrame = "<%=XSSUtil.encodeForJavaScript(context,openerFrame)%>";
        		          	  	   var frame=findFrame(getTopWindow(),openerFrame);
        		          	  	   frame.editableTable.loadData();
        		          	  	   frame.emxEditableTable.refreshStructureWithOutSort();
        		          	  	   </script>
        		  <%
        	  }
        else if(strMode.equalsIgnoreCase("delete")) {//if Delete Selected Command link on List page is pressed
            try {
            //getting table row ids from the list page
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            String strObjectIds[] = null;
            //getting object ids for the corresponding row ids
            strObjectIds = ProductLineUtil.getObjectIds(strTableRowIds);

            boolean bIsDeleted = false;
            //deleting objects from database by calling common bean
            bIsDeleted = commonBean.deleteObjects(context,strObjectIds,true);

            /* for deleting an object which is in a parent context,
             * delete the object from list page as well as from tree category
             */
           // if (!DomainConstants.EMPTY_STRING.equals(strTreeId)) {
%>
<script language="javascript" type="text/javaScript">
               refreshStructureTree();
                var tabFrame = findFrame(parent, "listDisplay");
    		   if(tabFrame != 'undefined' && tabFrame != null) {
        			tabFrame.parent.document.location.href = tabFrame.parent.document.location.href;
      			} else {
        			getTopWindow().refreshTablePage();
      			} 
                </script>
<%
            //}
        } catch(Exception e) {
            e.printStackTrace();
            bIsError = true;
            throw new com.matrixone.apps.domain.util.FrameworkException(e.getMessage());
        }
        }//End fo mode delete
        
        // New Function to remove the sub TE from the parent TE
        else if(strMode.equalsIgnoreCase("disconnect"))
        {
        	
        	try {       
        	ENOCsrfGuard.validateRequest(context, session, request,response);
            boolean canRemove = false;
            //get the table row ids of the test exe objects selected
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            //get the relationship ids of the table row ids passed
            Map relIdMap=ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
            String[] arrRelIds = (String[]) relIdMap.get("RelId");
            String[] strObjectIds = (String[]) relIdMap.get("ObjId");
        
            //Call the removeObjects method of ProductLineCommon to remove the selected object
            boolean bFlag = commonBean.removeObjects(context,arrRelIds);
            %>
            <script language="javascript" type="text/javaScript">
                           refreshStructureTree();
                            var tabFrame = findFrame(parent, "listDisplay");
                		   if(tabFrame != 'undefined' && tabFrame != null) {
                    			tabFrame.parent.document.location.href = tabFrame.parent.document.location.href;
                  			} else {
                    			getTopWindow().refreshTablePage();
                  			} 
                            </script>
            <%
                       
               } catch(Exception e) {
                        e.printStackTrace();
                        bIsError = true;
                        throw new com.matrixone.apps.domain.util.FrameworkException(e.getMessage());
                    }
        }
        
		else if(strMode.equalsIgnoreCase("refreshTree"))
		{
		//start for IR-028586V6R2011- top window closed on refresh. 
%>
<script language="javascript" type="text/javaScript">
             //<![CDATA[
             getTopWindow().closeWindow();
          </script>
<%
         //End for IR-028586V6R2011- top window closed on refresh. 
Enumeration enumParamNames1 = emxGetParameterNames(request);
java.util.HashMap objMap = new java.util.HashMap();

while(enumParamNames1.hasMoreElements())
{
  String paramName1 = (String) enumParamNames1.nextElement();
  String paramValue1 = emxGetParameter(request,paramName1); 
  objMap.put(paramName1, paramValue1);
}

Enumeration enumParamNames2 = emxGetParameterNames(request);
Hashtable objTable = new Hashtable();
String objId = null;
String jsTreeID = null;

while(enumParamNames2.hasMoreElements())
{
  String paramName = (String) enumParamNames2.nextElement();
  String paramValue = emxGetParameter(request,paramName);   
  if(paramName.contains("objectId") && ! paramName.equals("objectId"))
	{
		objId = paramValue;
		DomainObject obj = new DomainObject(objId);
		String sub1 = paramName.substring(8);
		String key = "Name" + sub1;
		String sName =(String)objMap.get(key);

%>
<script>
var contextTree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
var objNode;
        if(contextTree)
        {
                contextTree.doNavigate = true;
				objNode = contextTree.findNodeByObjectID("<%=XSSUtil.encodeForJavaScript(context,paramValue)%>");
		}
if(objNode)
		{
	      contextTree.doNavigate = true;
		  objNode.changeObjectName("<%=XSSUtil.encodeForJavaScript(context,sName)%>",true);
		}

</script>
<%
	}

  if(paramName.equals("jsTreeID"))
	{
		jsTreeID = paramValue;
	}	                
}
		}
    } catch(Exception ex) {
        //bIsError = true;
        //session.putValue("error.message", ex.toString());
        
        // ++ HAT1 ZUD: IR-439337-3DEXPERIENCER2017x: fix
        bIsError = true;
        String strAlertString = "emxProductLine.Alert." + ex.getMessage();
        String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), strAlertString); 
        if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
        {
            session.putValue("error.message", ex.getMessage());
        }
        else
        {
            session.putValue("error.message", i18nErrorMessage);
        }
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
	if("slidein".equals((String)emxGetParameter(request,"targetLocation")) && strMode.equalsIgnoreCase("createTestExecution"))
	{
%> 
		<script language="JavaScript">
		getTopWindow().closeSlideInDialog();
		</script>
<%	
	// -- HAT1 ZUD: IR-439337-3DEXPERIENCER2017x: fix
	} 
  if (bIsError==true && (strMode.equalsIgnoreCase("create") || strMode.equalsIgnoreCase("createTestExecution"))) {
%>
<script language="javascript" type="text/javaScript">
    var pc =findFrame(parent,"pagecontent");
    pc.clicked = false;
    parent.turnOffProgress();   
      history.back();
    </script>
<%
  }
%>
