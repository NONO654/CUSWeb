<%--  MassAssignRDOUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<!-- Include directives -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.*" %>
<%@page import="java.util.*"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%!
  private static final String REQ_MAP = "reqMap";
  private static final String REQ_TABLE_MAP = "reqTableMap";
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";
%>

<%
try
{
    String param=(String)session.getValue("params");
    HashMap requestsMap = (HashMap)session.getAttribute("requestMap");

     String strTableRowIds[] = emxGetParameterValues(request,"emxTableRowId");
  if((strTableRowIds==null)||(strTableRowIds.length==0)){
	 if(param.indexOf("calledFrom") == -1)
	   {
  %>
  <script language="javascript" >
  parent.listFoot.clickEventCounter=0;
  </script>

  <%

  String strLang = request.getHeader("Accept-Language");
  String strRetMsg = EnoviaResourceBundle.getProperty(context,"Components",ALERT_MSG,strLang);

  throw new FrameworkException(strRetMsg);
	   }
  }else{
       boolean  arrObjectIds=false;
       String timeStamp = emxGetParameter(request, "timeStamp");
	  String calledFrom = emxGetParameter(request,"calledFrom");

	  String str_TableRowIDs = "";
	  if(calledFrom!=null && !calledFrom.equals("") && calledFrom.equals("newSearch")){
	      
	      String strRDOObjectId = emxGetParameter(request,"emxTableRowId");
	      
	      String strProdLineObjIds = (String)requestsMap.get("emxTableRowIds");
	      //String strProdLineRelObjIds = (String)requestsMap.get("emxTableRelIds");
	      
	      //The code will extract the RDO id
	      StringTokenizer strTokenizerRDOObjeIds = new StringTokenizer(strRDOObjectId , "|");
	      strRDOObjectId = strTokenizerRDOObjeIds.nextToken();
	      //Ends
	      
	      StringTokenizer strTokenizerObjeIds = new StringTokenizer(strProdLineObjIds , "|");
	      //StringTokenizer strTokenizerObjeRelIds = new StringTokenizer(strProdLineRelObjIds , "|");
	      
	      //Number of selected Id's
	      int ObjectCount = strTokenizerObjeIds.countTokens();
	      
	      //Below strings will store PL ids and corresponding Rel Ids.
	      String ObjectIds[] = new String[ObjectCount];
	      //String ObjectRelIds[] = new String[ObjectCount];
	      
	      //The code will get all the Rel Ids and PL Ids on which mass Assign RDO is to be operated.
	      for(int i=0;i<ObjectCount;i++){
	          ObjectIds[i] = strTokenizerObjeIds.nextToken();  
	          //ObjectRelIds[i] = strTokenizerObjeRelIds.nextToken(); 

	      }
	      //Ends
	      
	      //Modified for IR    IR-015973V6R2010x
	      String strReturnType = ProductLineConstants.TYPE_PROJECT_SPACE+","+ProductLineConstants.TYPE_ORGANIZATION;
	      

          
	      //Get connected DR's of existing objects and compare if they already exist.
	      int ObjeCount = 0;
	      for(int j=0;j<ObjectCount;j++){
	          DomainObject ProductLine = DomainObject.newInstance(context);
	          ProductLine.setId(ObjectIds[j]);
	          
			  //Rel selects
	          //
	          StringList selectStmts  = new StringList(2);
	          selectStmts.addElement(DomainConstants.SELECT_ID);
	          selectStmts.addElement(DomainConstants.SELECT_NAME);	          
	          // Rel selects
	          //
	          StringList selectRelStmts = new StringList(1);
	          selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
	          MapList mapList = ProductLine.getRelatedObjects(context,
	        		   ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY,
	        	      												  strReturnType, 
	        	      												  selectStmts, 
	        	      												  selectRelStmts, 
	                                                                  true, 
	                                                                  false, 
	                                                                  (short)1, 
	                                                                  null, 
	                                                                  null);
	          
	          //Attributes of the child parts EBOM relationship.
	          
	          String strObjectId = "";
	          String strObjectRelId = "";	         
	          
	          

	          if(mapList.size()==0){
	              
	              DomainObject RDOProductLines = DomainObject.newInstance(context);
                  RDOProductLines.setId(ObjectIds[j]);
               
                  
                  DomainObject toConnects = new DomainObject(strRDOObjectId);
                  
//                Connecting new DR's
                  RDOProductLines.connectFrom(context,ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY,toConnects);
                  //RDOProductLines.commitTransaction(context);
                
	           //Modified for IR    IR-015973V6R2010x    
	          }else if(mapList.size()>=1){
	          
			          for (Iterator itrTasks = mapList.iterator(); itrTasks.hasNext();) {
			              Map mapInfo = (Map)itrTasks.next();
			              strObjectId = (String)mapInfo.get(DomainConstants.SELECT_ID);
			              strObjectRelId = (String)mapInfo.get(DomainConstants.SELECT_RELATIONSHIP_ID);
			              
			              if(!strObjectId.equals(strRDOObjectId))//|| strObjectId.equals(""))
			              {

			                  DomainObject RDOProductLine = DomainObject.newInstance(context);
			                  RDOProductLine.setId(ObjectIds[ObjeCount]);
			                  
			                  Relationship rel = new Relationship(strObjectRelId);
			                  	                  
			                  DomainObject toConnect = new DomainObject(strRDOObjectId);
			                  
			                  String relType = ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY;
			                  
			                  //Disconnecting previous DR's
			                  RDOProductLine.disconnect(context,rel);
			                  //RDOProductLine.commitTransaction(context);
			               
			                  
			                  //Connecting new DR's
			                  RDOProductLine.connectFrom(context,relType,toConnect);
			                  RDOProductLine.commitTransaction(context);
			                  
			              }
			              
			              
			          }

	      }
	  			//this case if PV->Mass Assign RDO In the case of Product, we will leave the relationship based code as-is and will do the attribute thing as an additional thing.
	  			//RDO convergence - R215
	  			DomainObject domObjOrgnization = new DomainObject(strRDOObjectId);
	  			//TODO- Assumption Oranization Name is same as Role name 
	  			String strNewOrganizationName = domObjOrgnization.getInfo(context, DomainObject.SELECT_NAME);
	  			String defaultProj=PersonUtil.getDefaultProject(context, context.getUser());
	  			ProductLine.setPrimaryOwnership(context, defaultProj, strNewOrganizationName);
//		        Increment the ObjeCount
	            ObjeCount++;
	      }
	      
	      %>
			
			<script language="javascript" type="text/javaScript">
				<%
				String strLanguage = request.getHeader("Accept-Language");
				String strRetMessage = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.massRDOUpdation.Alert",strLanguage);
			    %>
				alert("<xss:encodeForJavaScript><%=strRetMessage%></xss:encodeForJavaScript>");				
				window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
				window.getTopWindow().closeWindow();						
			</script> 
			
          <%			
	  
	  }
	  else if(calledFrom!=null && !calledFrom.equals("") && calledFrom.equalsIgnoreCase("ProductLine") )
		{
			for(int k=0; k<strTableRowIds.length;k++)
			{
				str_TableRowIDs=str_TableRowIDs + strTableRowIds[k]+"|";
			}

			%>
			<script language="javascript">
			var url = "../components/emxCommonSearch.jsp?searchmode=addexisting&searchmenu=SearchAddExistingChooserMenu&searchcommand=PLCSearchCompanyCommandForMassAssign,PLCSearchProjectsCommand&multipleTableRowId=true&isTo=false&srcDestRelName=relationship_DesignResponsibility&PRCParam1=DesignResponsibility&suiteKey=ProductLine&objectId=<%=XSSUtil.encodeForURL(context,strTableRowIds[0])%>&emxTableRowId=<%=XSSUtil.encodeForURL(context,str_TableRowIDs)%>&SubmitURL=../productline/MassAssignRDOUtil.jsp?calledFrom=Search";
			showChooser(url,700,700);
			</script>
			<%
		}
		else if(calledFrom!=null && !calledFrom.equals("") && calledFrom.equalsIgnoreCase("Search"))
		{
		  %><SCRIPT LANGUAGE="JavaScript">
				parent.getWindowOpener().closeWindow();
		  </SCRIPT>
		  <%

			HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
			HashMap requestValuesMap = (HashMap)requestMap.get("RequestValuesMap");
			String strObjectId = (String)requestMap.get(Search.REQ_PARAM_OBJECT_ID);
			String strMidBusTypeSymb = (String)requestMap.get(Search.REQ_PARAM_MID_BUS_TYPE);
			String strMidBusType = null;
			if (strMidBusTypeSymb != null) 
			{
				strMidBusType = PropertyUtil.getSchemaProperty(context,strMidBusTypeSymb);
			}
			String strSrcDestRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_SRC_DEST_REL_NAME);
			String strSrcDestRelName = null;
			if (strSrcDestRelNameSymb != null) 
			{
				strSrcDestRelName = PropertyUtil.getSchemaProperty(context,strSrcDestRelNameSymb);
			}

			String strSrcMidRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_SRC_MID_REL_NAME);
			String strSrcMidRelName = null;
			if (strSrcMidRelNameSymb != null) {

			strSrcMidRelName = PropertyUtil.getSchemaProperty(context,strSrcMidRelNameSymb);
			}

			String strMidDestRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_MID_DEST_REL_NAME);
			String strMidDestRelName = null;
			if (strMidDestRelNameSymb != null) {
			strMidDestRelName = PropertyUtil.getSchemaProperty(context,strMidDestRelNameSymb);
			}

			String strIsTo = (String)requestMap.get(Search.REQ_PARAM_IS_TO);
			String strAddProgram = (String)requestMap.get(Search.REQ_PARAM_ADD_PROGRAM);
			String strAddFunction = (String)requestMap.get(Search.REQ_PARAM_ADD_FUNCTION);
			String strDoConnect = (String)requestMap.get(Search.REQ_PARAM_DO_CONNECT);

			String strLoadPage = (String)requestMap.get(Search.REQ_PARAM_LOAD_PAGE);
			String strLoadPageMode = (String) requestMap.get ("loadPageMode");
			Search search = new Search();
			try 
			{
				ProductLineCommon productBean = new ProductLineCommon();
				if( (strDoConnect != null) && (strDoConnect.equalsIgnoreCase("true")))
				{
					Map programMap = new HashMap();
					Map reqMap = new HashMap();
					Enumeration enumParamNames = emxGetParameterNames(request);

					while(enumParamNames.hasMoreElements())
					{
						String paramName = (String) enumParamNames.nextElement();
						String paramValues[] = emxGetParameterValues(request,paramName);

						if (paramValues != null ) 
						{
						reqMap.put(paramName, paramValues);
						}
					}
					programMap.put(REQ_MAP, reqMap);
					programMap.put(REQ_TABLE_MAP, requestValuesMap);
					String[] methodargs =JPO.packArgs(programMap);
					JPO.invoke(context, strAddProgram, null, strAddFunction, methodargs, String.class);
				}
				else if( (strMidBusType == null) || (strMidBusType.equals("")) )
				{
					for (int i=0; i<strTableRowIds.length; i++)  
					{
						if ( strIsTo.equalsIgnoreCase("false") )  
						{
							for (int j=0; j<strTableRowIds.length; j++)
							{
								StringBuffer Demo = new StringBuffer(param);
								StringTokenizer Tok = new StringTokenizer(Demo.toString(),"&,=");
								String rowid="";
								Vector vtr = new Vector();				
								while (Tok.hasMoreElements())
								{
									String nextTok = Tok.nextToken();
									if(nextTok.equalsIgnoreCase("emxTableRowId"))
									{
										 vtr.add(Tok.nextToken());
									}
								}
								int siz = vtr.size();
								for(int n =0; n<siz ;n++)
								{
									String str1 =(String) vtr.get(n);
									StringTokenizer Tok1 = new StringTokenizer(str1,"|");
									Vector vtr1 = new Vector();
									while (Tok1.hasMoreElements())
									{
									  String objId = Tok1.nextToken();
									  vtr1.add(objId);
									}
									for(int l=0;l<vtr1.size();l++)
									{
										String FeatureId=(String)(vtr1.get(l));
										arrObjectIds =productBean.disconnectConnectRDO(context,FeatureId,strTableRowIds[j],strSrcDestRelName); 
									}
								}
							}//end of my for
						}
						else  
						{
							search.connectObjects( context ,  strTableRowIds[i] , strObjectId ,strSrcDestRelName);
						}
					}
				}
				else
				{
				for (int i=0; i<strTableRowIds.length; i++)
				{
				String midBusOId = search.createObject(context, strMidBusType);
				if ( strIsTo.equalsIgnoreCase("true") )
				{
				search.connectObjects( context , strObjectId , midBusOId , strSrcMidRelName);
				search.connectObjects( context , midBusOId , strTableRowIds[i] , strMidDestRelName);
				}
				else
				{
				search.connectObjects( context , strTableRowIds[i] , midBusOId , strSrcMidRelName);
				search.connectObjects( context , midBusOId ,  strObjectId , strMidDestRelName);
				}
				}
				}
				ContextUtil.commitTransaction(context);
			}
			catch (Exception excp) {
			excp.printStackTrace();
			%>
			<script>

			var tableFooterFrame = findFrame(parent,"listFoot");
			tableFooterFrame.setTableSubmitAction(true);
			</script>
			<%
			throw excp;
			}

			%>


			<script>
			var contentFrame = openerFindFrame (getTopWindow(), "detailsDisplay");
			if(getTopWindow().getWindowOpener().getTopWindow().addMultipleStructureNodes != null) {
			<%
			StringBuffer sBuffer = new StringBuffer();

			for(int j = 0 ;j < strTableRowIds.length ; j++) {
			if (j != 0)
			{
			sBuffer.append(',');
			}
			sBuffer.append(strTableRowIds[j]);

			%>
			getTopWindow().getWindowOpener().getTopWindow().addMultipleStructureNodes( "<%=XSSUtil.encodeForURL(context,sBuffer.toString())%>",'<%=XSSUtil.encodeForURL(context,strObjectId)%>','','',false);
			<%
			}
			%>
			}


			if (parent.window.getWindowOpener().parent != null) {

			if(parent.window.getWindowOpener().parent.reloadTableEditPage != null && parent.window.getWindowOpener().parent.reloadTableEditPage != 'undefined') {
			parent.window.getWindowOpener().parent.reloadTableEditPage();
			} else {
			parent.window.getWindowOpener().parent.location = parent.window.getWindowOpener().parent.location;
			}
			}  else  if (contentFrame) {
			contentFrame.location.reload();
			}

			<%  if (strLoadPage != null && strLoadPage.trim().length() > 0)
			{ %>
			window.location.href='<%=XSSUtil.encodeForURL(context,strLoadPage)+"?mode="+XSSUtil.encodeForURL(context,strLoadPageMode)+"&parentObjId="+XSSUtil.encodeForURL(context,strObjectId)%>';
			<%  } else { %>
			getTopWindow().closeWindow();

			<%  } %>

			</script>
			<%
		}
		else
		{
       HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
  

//  Retrieve the map which contains all the values of multi-values parameters like "emxTableRowId"
    HashMap requestValuesMap = (HashMap)requestMap.get("RequestValuesMap");
    String strObjectId = (String)requestMap.get(Search.REQ_PARAM_OBJECT_ID);
    

    String strMidBusTypeSymb = (String)requestMap.get(Search.REQ_PARAM_MID_BUS_TYPE);
    String strMidBusType = null;
    if (strMidBusTypeSymb != null) {
      strMidBusType = PropertyUtil.getSchemaProperty(context,strMidBusTypeSymb);
    }

    String strSrcDestRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_SRC_DEST_REL_NAME);
    String strSrcDestRelName = null;
    if (strSrcDestRelNameSymb != null) {
      strSrcDestRelName = PropertyUtil.getSchemaProperty(context,strSrcDestRelNameSymb);
    }

    String strSrcMidRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_SRC_MID_REL_NAME);
    String strSrcMidRelName = null;
    if (strSrcMidRelNameSymb != null) {
      strSrcMidRelName = PropertyUtil.getSchemaProperty(context,strSrcMidRelNameSymb);
    }

    String strMidDestRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_MID_DEST_REL_NAME);
    String strMidDestRelName = null;
    if (strMidDestRelNameSymb != null) {
      strMidDestRelName = PropertyUtil.getSchemaProperty(context,strMidDestRelNameSymb);
    }

    String strIsTo = (String)requestMap.get(Search.REQ_PARAM_IS_TO);
    String strAddProgram = (String)requestMap.get(Search.REQ_PARAM_ADD_PROGRAM);
    String strAddFunction = (String)requestMap.get(Search.REQ_PARAM_ADD_FUNCTION);
    String strDoConnect = (String)requestMap.get(Search.REQ_PARAM_DO_CONNECT);


   String strLoadPage = (String)requestMap.get(Search.REQ_PARAM_LOAD_PAGE);
   String strLoadPageMode = (String) requestMap.get ("loadPageMode");



    Search search = new Search();

    try {

    	ProductLineCommon productBean = new ProductLineCommon();
       if( (strDoConnect != null) && (strDoConnect.equalsIgnoreCase("true")) ) {
        Map programMap = new HashMap();
        Map reqMap = new HashMap();
        Enumeration enumParamNames = emxGetParameterNames(request);
        while(enumParamNames.hasMoreElements())
        {
          String paramName = (String) enumParamNames.nextElement();
          String paramValues[] = emxGetParameterValues(request,paramName);
          if (paramValues != null ) {
            reqMap.put(paramName, paramValues);
          }
        }
        programMap.put(REQ_MAP, reqMap);
        programMap.put(REQ_TABLE_MAP, requestValuesMap);
        String[] methodargs =JPO.packArgs(programMap);
        JPO.invoke(context, strAddProgram, null, strAddFunction, methodargs, String.class);
      }
      else if( (strMidBusType == null) || (strMidBusType.equals("")) ) {
        for (int i=0; i<strTableRowIds.length; i++)  
      {
          if ( strIsTo.equalsIgnoreCase("false") )  {
               for (int j=0; i<strTableRowIds.length; i++)
           {
                 StringBuffer Demo = new StringBuffer(param);
                   StringTokenizer Tok = new StringTokenizer(Demo.toString(),"&,=");
                 String rowid="";
                 Vector vtr = new Vector();

                   while (Tok.hasMoreElements())
                {
                     String nextTok = Tok.nextToken();
                  if(nextTok.equalsIgnoreCase("emxTableRowId"))
                  {
                         vtr.add(Tok.nextToken());
                  }

                 }
                 int siz = vtr.size();
                for(int n =0; n<siz ;n++)
             {
                   String str1 =(String) vtr.get(n);
                   StringTokenizer Tok1 = new StringTokenizer(str1,"|");
                   Vector vtr1 = new Vector();
                   while (Tok1.hasMoreElements())
                {
                      vtr1.add(Tok1.nextToken());
                   }
                   String FeatureId=(String)(vtr1.get(1));
                   arrObjectIds =productBean.disconnectConnectRDO(context,FeatureId,strTableRowIds[j],strSrcDestRelName); 
                }

               
             }//end of my for
           
          }
          else  {
            search.connectObjects( context ,  strTableRowIds[i] , strObjectId ,strSrcDestRelName);
          }
        }
      }
      else
      {
        
        for (int i=0; i<strTableRowIds.length; i++)
          {
            String midBusOId = search.createObject(context, strMidBusType);
            if ( strIsTo.equalsIgnoreCase("true") )
              {
                search.connectObjects( context , strObjectId , midBusOId , strSrcMidRelName);
                search.connectObjects( context , midBusOId , strTableRowIds[i] , strMidDestRelName);
              }
            else
              {
                search.connectObjects( context , strTableRowIds[i] , midBusOId , strSrcMidRelName);
                search.connectObjects( context , midBusOId ,  strObjectId , strMidDestRelName);
              }
          }
      }
        ContextUtil.commitTransaction(context);
    }
    catch (Exception excp) {
      excp.printStackTrace();
      %>
        <script>

          var tableFooterFrame = findFrame(parent,"listFoot");
          tableFooterFrame.setTableSubmitAction(true);
        </script>
      <%
      throw excp;
    }

  %>


  <script>
  var contentFrame = openerFindFrame (getTopWindow(), "detailsDisplay");
  if(getTopWindow().getWindowOpener().getTopWindow().addMultipleStructureNodes != null) {
  <%
    StringBuffer sBuffer = new StringBuffer();

    for(int j = 0 ;j < strTableRowIds.length ; j++) {
      if (j != 0)
      {
        sBuffer.append(',');
      }
      sBuffer.append(strTableRowIds[j]);

  %>
      getTopWindow().getWindowOpener().getTopWindow().addMultipleStructureNodes( "<%=XSSUtil.encodeForJavaScript(context,sBuffer.toString())%>",'<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>','','',false);
  <%
    }
  %>
  }


   if (parent.window.getWindowOpener().parent != null) {
        
        if(parent.window.getWindowOpener().parent.reloadTableEditPage != null && parent.window.getWindowOpener().parent.reloadTableEditPage != 'undefined') {
            parent.window.getWindowOpener().parent.reloadTableEditPage();
        } else {
            parent.window.getWindowOpener().parent.location = parent.window.getWindowOpener().parent.location;
        }
    }  else  if (contentFrame) {
      contentFrame.location.reload();
    }

  <%  if (strLoadPage != null && strLoadPage.trim().length() > 0)
  { %>
    window.location.href='<%=XSSUtil.encodeForURL(context,strLoadPage)+"?mode="+XSSUtil.encodeForURL(context,strLoadPageMode)+"&parentObjId="+XSSUtil.encodeForURL(context,strObjectId)%>';
  <%  } else { %>
    getTopWindow().closeWindow();
  <%  } %>

  </script>
  <%
  }
  }
} // End of try
catch(Exception ex) {
    ex.printStackTrace();
  session.putValue("error.message", ex.getMessage());
} // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
