<%--  emxInfoCustomTableBody.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  
  Description : This file renders table data retrieved from JPO Program into 
  HTML Table.
 
--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html>

<%@include file = "MCADTopInclude.inc"%>
<%@include file = "MCADTopErrorInclude.inc"%>
<%@include file = "emxInfoCustomTableInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%!
 String INFEncode(String href, HttpServletRequest request)
 {
     // Encode the URL for Netscape
  
  String browser = request.getHeader("USER-AGENT");
  if(!(browser.indexOf("MSIE") > 0)){
    href = FrameworkUtil.encodeURLParamValues(href);   
  }
  else
  {
    href = href.replace(' ','+');
  }

  return href;

 }

%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

    String objectId			= emxGetParameter(request, "objectId");
    String sTarget			= emxGetParameter(request, "custTargetLocation");
    String displayMode		= emxGetParameter(request, "custDisplayMode");
    String pagination		= emxGetParameter(request, "custPagination");
    String topActionbar		= emxGetParameter(request, "custTopActionbar");
    String bottomActionbar	= emxGetParameter(request, "custBottomActionbar");
    String sortColumnName	= emxGetParameter(request, "custSortColumnName");
    String sortDirection	= emxGetParameter(request, "custSortDirection");
    String sortDataType		= emxGetParameter(request, "custSortType");   
    String sPage			= emxGetParameter(request, "custPageNo");
    String header			= emxGetParameter(request, "custHeader");
    String selection		= emxGetParameter(request, "custSelection");
    String helpMarker		= emxGetParameter(request, "HelpMarker");
    String suiteDir			= emxGetParameter(request, "suiteDirectory");
    String timeStamp		= emxGetParameter(request, "timeStamp");
    String reSortKey		= emxGetParameter(request, "custReSortKey");
    String sPFmode			= emxGetParameter(request, "PFmode");    
    String sHeaderRepeat	= emxGetParameter(request, "custHeaderRepeat");
    String suiteKey			= emxGetParameter(request, "suiteKey");
    String DateFrm			= (new Integer(java.text.DateFormat.MEDIUM)).toString();
    String targetFrame		= null;
    int noOfColumns			= 0;
    int noOfItemsPerPage	= 0;

    // Get table data from session
    CustomMapList tableData = (CustomMapList)session.getAttribute("TableData" + timeStamp);
    //Stores table data to be displayed in current page
    CustomMapList tablePageData = new CustomMapList();

    //Get column definitions from session
    ArrayList columns = (ArrayList)session.getAttribute("ColumnDefinitions" + timeStamp);

    if (sHeaderRepeat == null)
        sHeaderRepeat = "15";
    
    if (sTarget == null)
        sTarget = "content";
    
    if (sortDirection == null)
        sortDirection = "ascending";
   
    if (sortDataType == null)
        sortDataType = "string";
    
    if (reSortKey != null && reSortKey.length() > 0)
        sortColumnName = reSortKey;
    
	try 
	{
         //Starts Database transaction  
    	 ContextUtil.startTransaction(context, false);

     	 if (tableData != null && tableData.size() > 0 && sortColumnName != null && sortColumnName.length()>0)
     	 {
             boolean columnSpan = false;
             //Sorts table rows by column header
%>
<%	     
    	}
   
		if (pagination == null || pagination.trim().length() == 0 || pagination.equals("null") )
		{
	    	pagination = UINavigatorUtil.getSystemProperty(application, "emxFramework.PaginationRange");
	    	if (pagination == null)
            	pagination = "10";
    	} 
    	else if ( pagination.equals("0") ) 
    	{
        		pagination = "0";
        		displayMode = "singlePage";
    	}
  		noOfItemsPerPage = Integer.parseInt(pagination);
    
		if (tableData != null && tableData.size() > 0)
    	{
			// Render page using current page index
            if (noOfItemsPerPage == 0)
                noOfItemsPerPage = tableData.size();

		    int currentIndex = ((Integer)session.getAttribute("CurrentIndex" + timeStamp)).intValue();
		    
			if ( sPage == null || sPage.trim().length() == 0 || sPage.equals("null") )
        	    sPage = "1";
		    if ( sPFmode == null || !sPFmode.equals("true") )
        	{
            	if (sPage != null && sPage.equals("next")) 
            	{
          			currentIndex += noOfItemsPerPage;
        		}
        		else if (sPage != null && sPage.equals("previous")) 
        		{
          			currentIndex -= noOfItemsPerPage;
        		} 
        	    else if (sPage != null && Integer.parseInt(sPage) >= 1) 
        	    {
          		    int pageNo = Integer.parseInt(sPage);
          		    currentIndex = (pageNo - 1) * noOfItemsPerPage;
        	    } 
        	    else
        	    {
        		    currentIndex = 0;
        	    }
       	    } 	

            Integer currentIndexObj = new Integer(currentIndex);
            session.setAttribute("CurrentIndex" + timeStamp, currentIndexObj);
	    	int lastPageIndex;
            if (displayMode != null && displayMode.compareTo("multiPage") == 0)
            {
               	// currentIndex = 0;
               	lastPageIndex = currentIndex + noOfItemsPerPage;
            } 
            else if (displayMode != null && displayMode.compareTo("singlePage") == 0)
            {
               currentIndex = 0;
               lastPageIndex = currentIndex + tableData.size();
            }
            else 
            {
              	lastPageIndex = currentIndex + noOfItemsPerPage;
            }
        
           	for (int i = currentIndex; i < lastPageIndex; i++)
            {
                if (i >= tableData.size())
                	break;
                tablePageData.add(tableData.get(i));
            }
    }
%>

	<head>
		<title>Table View</title>
<%
	if ( sPFmode != null && sPFmode.equals("true") )
	{
%>
			<link rel="stylesheet" href="../common/styles/emxUIDefaultPF.css" type="text/css">
			<link rel="stylesheet" href="../common/styles/emxUIListPF.css" type="text/css">
<%
	} 
	else
    {
%>
			<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
			<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<%
	}
%>
	
	<script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
	</head>

	<body>

		<form name=emxTableForm method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

<%
    // Show the header if the mode is "PrinterFriendly"
	if ( sPFmode != null && sPFmode.equals("true") )
	{
        header = parseTableHeader(application, context, header, objectId, suiteKey, request.getHeader("Accept-Language"));
    	String userName = context.getUser();
    	java.util.Date currentDateObj = new java.util.Date(System.currentTimeMillis());
    	String currentTime = currentDateObj.toString();
%>
		    <hr noshade>
    		<table border="0" width="100%" cellspacing="2" cellpadding="4">
    		 <tr>
			    <!--XSSOK-->
        		<td class="pageHeader" width="60%"><%=header%></td>
        		<td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" alt=""></td>
        		<td width="39%" align="right"></td>
        		<td nowrap>
            		<table>
					    <!--XSSOK-->
            			<tr><td nowrap=""><%=userName%></td></tr>
						<!--XSSOK-->
            			<tr><td nowrap=""><%=currentTime%></td></tr>
            		</table>
        		</td>
    		 </tr>
    		</table>
    		<hr noshade>

<%
	}
%>

<% 
	// Render table data, use column definitions to render the data
    if(columns != null && columns.size()>0)
    {
   	    noOfColumns = columns.size(); 
  		if ( sPFmode != null && sPFmode.equals("true") )
  		{
%>				<table border="0" width="100%">
	 				<tr>
						<td><img src="../common/images/utilSpacer.gif" border="0" width="5" height="30" alt=""></td>
     				</tr> 
   				</table>
				<table border="0" cellpadding="5" cellspacing="0" width="100%">

<%
        } 
  		else 
  		{
 %>
		<table border="0" width="100%" cellspacing="2" cellpadding="3" >
		<tr>
<%
  		}

        //Display Table headers
	    if ( sPFmode != null && sPFmode.equals("true") )
    	{
%>
             
<%      
        }
		else if(selection != null && selection != "")
		{
		    if(selection.compareTo("multiple") == 0)
			{
%>
					<th width="5%" style="text-align:center"><input type="checkbox" name="chkList" onclick="doCheck()"></th>

<%
			}
		    else if(selection.compareTo("single") == 0)
		    {
%>	  
  			   		<th width="5%">&nbsp;</th>
<%
		    }
		}    
        
        ColumnDefinition columnDefinition = null;
        String anchorClass = "sorted";
	
        for(int i=0;i<columns.size();i++)
        {
            String columnName = null;
    	    String title = null;
    	    String sortType = null;
    	    boolean sortable = true;
    	    boolean isMultipleImages = false;
    	    int numMultipleImages  = 0;
    	    columnDefinition = (ColumnDefinition) columns.get(i);
    	    
    	    if(columnDefinition != null)
    	    {
    		    columnName = columnDefinition.getColumnKey();
    		    title = i18nNow.getI18nString(columnDefinition.getColumnTitle(),null,request.getHeader("Accept-Language"));
        	    sortable = columnDefinition.getColumnIsSortable();
        	    sortType = columnDefinition.getColumnDataType();
				isMultipleImages =     columnDefinition.getIsMultipleImages();
                if(sortable && tablePageData.size()>0)
        		{
           		    if (sortColumnName == null || (sortColumnName.compareTo(columnName) != 0) || ( sPFmode != null && sPFmode.equals("true") ) )
            	    {
                        if ( sPFmode != null && sPFmode.equals("true") )
                    	{
%>                    		
                        <!--XSSOK-->
                        <th><%=title%></th>
<%
                    	} 
                    	else 
                    	{
%>                    		<th>
                            <!--XSSOK-->
                            <a href="javascript:reloadCustomTable('<%=columnName%>','ascending','<%=sortType%>')"> <%= title %> </a>
<%
                    	}
            		} 
            
            		else
            		{                              
                		String sortImage = "";
                		String nextSortDirection = "";
                		if (sortDirection.compareTo("ascending") == 0)
                		{
                    		nextSortDirection = "descending";
                    		sortImage = "../common/images/utilSortArrowUp.gif";
                		} 
                		else 
                		{
                    		nextSortDirection = "ascending";
                    		sortImage = "../common/images/utilSortArrowDown.gif";
                		}
%>
					<th class=sorted>
					<table border="0" cellspacing="0" cellpadding="0"><tr><th>
					<!--XSSOK-->
					<a href="javascript:reloadCustomTable('<%=columnName%>', '<%=nextSortDirection%>','<%=sortType%>')"> <%= title %> </a>
					<!--XSSOK-->
					</th><td><img src="<%=sortImage%>" align="absmiddle" border="0" /></td></tr>
					</table>
					</th>

<%   
            		}
           		}  	 
        		else if(title.equals(" ") ||title.equals("") || title == null)
        		{
        			if (sPFmode != null && sPFmode.equals("true"))
                    {
                    		
%>
						
<%
                    } 
                    else
                    {
                    	
%>
                       <th class=sorted>&nbsp;</th>
<%
                    }                    	
                   	
      			
        			
       			}	  
        		else
        		{
%>
                    <!--XSSOK-->
        			<th class=sorted> <%=title%> </th>            	
<%        	
        		}
  			}
        }//End of for(int i=0;i<columns.size();i++)
    } 
    
    
%>
</tr>
<%
	    if (columns == null || columns.size() == 0)
	    {
%>
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr class=even> 
			    <!--XSSOK-->
				<td class="error" align=center><%=i18nNow.getI18nString("mcadIntegration.CustomTable.NoCoulmnsFound",null,request.getHeader("Accept-Language"))%></td>
			</tr>
		</table>
<%
    	} 
	    else if (tableData == null || tableData.size() == 0 )
    	{
  		    int totalColumns = noOfColumns + 1;
%>
		   <!--XSSOK-->
		   <tr class=even> <td class="error" colspan="<%=totalColumns%>" align=center><%=i18nNow.getI18nString("mcadIntegration.Common.NoItemsFound",null, request.getHeader("Accept-Language"))%></td> </tr>
		
<%
	    } 
	    else 
	    {
  		    String checkboxName = "emxTableRowId";
  		    String sValue ="";
  		    String sReadOnly ="";
  		    int iOddEven = 1;
      		String sRowClass = "odd";
      		int headerRepeatCount = 15;
      		for(int rowCount=0;rowCount<tablePageData.size();rowCount++)
      		{     		
        	
      		
  			   if (sHeaderRepeat != null && sHeaderRepeat.trim().length() > 0)
        		headerRepeatCount = Integer.parseInt(sHeaderRepeat);
        	if ( (rowCount != 0) && (headerRepeatCount != 0) && (rowCount % headerRepeatCount == 0) )
        	{
%>
				<tr>
<%
          		if ( ( selection.compareTo("single") == 0 || selection.compareTo("multiple") == 0 ) && ( sPFmode == null || sPFmode.equals("false") ) )
          		{
%>
					<th class="sub" width="5%">&nbsp;</th>
<%
 		        }

        		ColumnDefinition columnDefinition = null;
        		String anchorClass = "sorted";
	
        		for(int i=0;i<columns.size();i++)
        		{
            		String columnName = null;
    	    		String title = null;
    	    		String sortType = null;
    	    		boolean sortable = true;
     	    		columnDefinition = (ColumnDefinition) columns.get(i);
    	    
    	    		if(columnDefinition != null)
    	    		{
    		    		columnName = columnDefinition.getColumnKey();
    		    		title = i18nNow.getI18nString(columnDefinition.getColumnTitle(),null,request.getHeader("Accept-Language"));
        	   			sortable = columnDefinition.getColumnIsSortable();
        	    		sortType = columnDefinition.getColumnDataType();

               		   if (sortColumnName == null || (sortColumnName.compareTo(columnName) != 0))
         			   {
         			   	 if(title.equals("") || title.equals(" ") || title.length()==0)
         			   	 {
%>
							<th class="sub">&nbsp;
<%
						
                         }
                         else
                         {
%>                         		
                                <!--XSSOK-->
                         		<th class="sub"><%=title%>
<%                         		
                         	
                         }							
			          }
            		  else
              		  {
%>						
							<th class="subSorted">
<%
                  			String sortImage = "";
                  			if (sortDirection.compareTo("ascending") == 0)
								sortImage = "../common/images/utilSortArrowUp.gif";
                  			else
			                    sortImage = "../common/images/utilSortArrowDown.gif";  			
					
%> 
                            <!--XSSOK-->
							<%=title%> 
							<!--XSSOK-->
							<img src="<%=sortImage%>" align="absmiddle" border="0" />
<%
              			}
%>
							</th>
<%
           			
           			}	
        	}	
        }	
%>        		
		</tr>

<%
		//Iteration of  each row of table
      	Map row = (Map)tablePageData.get(rowCount);
             
		iOddEven = rowCount;
		    if ((iOddEven%2) == 0)
        	   sRowClass = "even";
             else
         	    sRowClass = "odd"; 
%>		
            <!--XSSOK-->
			<tr class="<%=sRowClass%>" >
<%
		    if ( sPFmode != null && sPFmode.equals("true") )
		    {
%>
               <!-- <th></th> -->
<%
		    }
		    
 		    else if(selection != null && selection != "")
 		    {
			    if (selection.compareTo("multiple") == 0) 
			    {
			     	//sValue = java.net.URLEncoder.encode((String)row.get("ID"));
                    sValue = (String)row.get("ID");
			     	sReadOnly = (String)row.get("ReadOnly");
			     	if(sReadOnly != null && sReadOnly.equals("true"))
			     	{
%>

					   <!--XSSOK-->
                       <td style="text-align: center"><input type="checkbox" name="<%=checkboxName%>" value="<%=sValue%>" disabled="true"></td>
<%			    	
			     		
			     	}
			     	else
        	     	{
%>
                        <!--XSSOK-->
 				        <td style="text-align: center"><input type="checkbox" name="<%=checkboxName%>" value="<%=sValue%>" ></td>
<%
			     		
			     	}
				
    		    } 
    		    else if (selection.compareTo("single") == 0) 
   			    {
     			   //sValue = java.net.URLEncoder.encode((String)row.get("ID"));
                   sValue = (String)row.get("ID");
     			   sReadOnly = (String)row.get("ReadOnly");
     			   if(sReadOnly != null && sReadOnly.equals("true"))
			       {
%>
                     <!--XSSOK-->
                     <td style="text-align: center"><input type="radio" name="<%=checkboxName%>" value="<%=sValue%>" disabled="true"></td>
<%			    	
			     		
			       }
			       else
        	       {
%>
                    <!--XSSOK-->
 				    <td style="text-align: center"><input type="radio" name="<%=checkboxName%>" value="<%=sValue%>"></td>
<%
			     		
			       }
   				
   			    }
            }
       
  	    	ColumnDefinition columnDef = null;
    
   	    	for(int j=0;j<columns.size();j++)  
   		    {
     		    CellData objCellData = null;
     		    StringTokenizer iconUrlTokenizer = null;
     		    StringTokenizer hrefTokenizer = null;
     		    StringTokenizer iconToolTipTokenizer = null;
         	    String columnType = null;
         		String columnKey  = null;
     	    	String iconUrl    = null;
     		    String href       = null; 
     		    String colValue   = null;
     		    String target     = null;
     		    String iconImage  = null;
     		    String parsedIconUrl = null;
     		    String parsedHref    = null;
     		    String parsedIconToolTip    = "";
     		    String columnDataType = null;
     		    String iconToolTip    = null;
     		    
                columnDef = (ColumnDefinition)columns.get(j);  
            
                if(columnDef != null)
         		{
     	    		columnKey  = columnDef.getColumnKey();
     	         	columnType = columnDef.getColumnType();
     			    target     = columnDef.getColumnTarget();
     	     	    columnDataType = columnDef.getColumnDataType();
     	                 	            
     			    if(columnType.equalsIgnoreCase("icon"))
         		    {  
     	    	        String encodedHref = null;
     	    	        objCellData  = (CellData)row.get(columnKey);
     	  	            iconUrl  = objCellData.getIconUrl();
     	  		        href     = objCellData.getHrefCellData();
     	  		        colValue = objCellData.getCellText();
     	  		        iconToolTip = objCellData.getIconToolTip();
     	  		        
     	  		        if(colValue == null)
     	  		         colValue = "";
     	  		        if(iconToolTip == null)
     	  		         iconToolTip = " "; 
     	  		        if ( sPFmode != null && sPFmode.equals("true") )
           		        {
           		               if(colValue != "" && colValue != " ")
           		               {
           		                   iconUrlTokenizer = new StringTokenizer(iconUrl, ",", false);
%>
							    	<td class="listCell" valign="top">
								    <table border="0" cellspacing="0" cellpadding="0" width="100%">
								    <tr>
<%  	          			   		
  	          			   		    while (iconUrlTokenizer.hasMoreTokens()) 
 								    { 
 							 	    								 	
         							   parsedIconUrl = iconUrlTokenizer.nextToken();
%>         							
                                       <!--XSSOK-->
									   <td><img border="0"  src="<%=parsedIconUrl%>">
<%         							
							        }
   	          			       	
%>
                                    <!--XSSOK-->
			                        <%=colValue%></td>
			                        </tr>
			                        </table>
			                        </td>
			                        
<%
           		               }
           		        }	  		              	  		         
     	  		        else 
           		        {
  	          		        if(colValue == null || colValue.equals("") || colValue.equals(""))
  	          		        {
  	          			       if((href == null || href.equals("") || href.equals(" ") ) && iconUrl != null)
  	          			       {
%>
								<td  >
								 <table border="0" cellspacing="0" cellpadding="0" width="100%"><tr>
								
<%  	          			       	
  	          			       	 iconUrlTokenizer = new StringTokenizer(iconUrl, ",", false);
  	          			       	 iconToolTipTokenizer = new StringTokenizer(iconToolTip, ",", false);
 								 while (iconUrlTokenizer.hasMoreTokens() && iconToolTipTokenizer.hasMoreTokens() ) 
 								 { 
         							parsedIconUrl = iconUrlTokenizer.nextToken();
         							parsedIconToolTip = iconToolTipTokenizer.nextToken();
         							if(parsedIconToolTip.equals(" ") || parsedIconToolTip == null)
         							  parsedIconToolTip = "";
         							
%>         							<td class="listCell" valign="top">
                                    <!--XSSOK-->
                                    <img border="0" alt="<%=parsedIconToolTip%>" src="<%=parsedIconUrl%>"> 
                                    </td>
<%         							
							     }
%>
				
  				     		    
       				 	 	    </tr>
       				 	 	    </table>
       				 	 	    </td>        
       				 	 	    
<%  	          			       	
  	          			       	
  	          			       }
							   else if((href == null || href.equals("") || href.equals(" ") ) && (iconUrl == null || iconUrl == "" || iconUrl == " " ))
							   {
%>
							    <td class="listCell" valign="top">
  				     		    &nbsp;
       				 	 	    </td>        
<%							   
							   }
							   else
  	          			       {
  	          			         
  	          			         hrefTokenizer = new StringTokenizer(href, ",", false);
  	          			         iconUrlTokenizer = new StringTokenizer(iconUrl, ",", false);
  	          			         iconToolTipTokenizer = new StringTokenizer(iconToolTip, ",", false);
  	          			                			         
%>
								 <td  >
								 <table border="0" cellspacing="0" cellpadding="0" width="100%"><tr>
		<%  	          			         
  	          			           	    
		      			         while (hrefTokenizer.hasMoreTokens() && iconUrlTokenizer.hasMoreTokens()) 
 								 { 				 	
  	          			             parsedHref =  hrefTokenizer.nextToken();
  	          			             parsedHref = parsedHref +"&targetFrame="+target;
  	          			             parsedIconUrl = iconUrlTokenizer.nextToken();
  	          			             parsedIconToolTip = iconToolTipTokenizer.nextToken();
  	          			             if(parsedIconToolTip.equals(" ") || parsedIconToolTip == null)
         							  parsedIconToolTip = "";
         					         parsedHref = convJS(parsedHref);
							  parsedHref = INFEncode(parsedHref,request);	
         					         //encodedHref = FrameworkUtil.encodeURLParamValues(parsedHref);
         					         
  	          			          	 
%>  	          	           
									<td class="listCell" valign="top">
									<!--XSSOK-->
									<a href="JavaScript:emxTableColumnLinkClick('<%=parsedHref%>', '600', '600', 'false', '<%=target%>')" class="object"><img border="0" alt="<%=parsedIconToolTip%>" src="<%=parsedIconUrl%>"></a>
									</td>
<%	
								 }//End of while(hrefTokenizer..)       	
%>  				     		       
  				     		       
				     		    </tr>
				     		    </table>   
       			 		        </td> 
<%  	                       
							 }
  	          		       }
  	          		        else if(href == null || href.equals("") || href.equals(" "))
  	          		        {
  	          		           if(columnDataType.equals("date"))
  	          		           {
%>  	          		           	
  	          		            
								<td class="listCell" valign="top">
								<!--XSSOK-->
		                        <img border="0" src="<%=iconUrl%>"> 
								<!--XSSOK-->
					 		    <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%= colValue %></emxUtil:lzDate>
       				 	 	    </td>    	
<%  	          		           
  	          		           
  	          		           }
  	          		           else
  	          		           {
%>  	          		           	
  	          		           	<td class="listCell" valign="top">
								   <!--XSSOK-->
		                           <img border="0" src="<%=iconUrl%>"><%=colValue%>
               					</td>
<%               					  
  	          		           	 
  	          		           }
  	          		        }
  	          		        else
  	          		        {
  	          		           if(columnDataType.equals("date"))
  	          		           {
                                       
  	          		            //href = href.replace(' ','+');
                                         href = INFEncode(href,request);
%>  	          		           	
  	          		            <td class="listCell" valign="top">
								<!--XSSOK-->
  				     		    <a href="JavaScript:emxTableColumnLinkClick('<%=href%>', '', '', 'false', '<%=target%>')" class="object"><img border="0" alt="<%=iconToolTip%>" src="<%=iconUrl%>">
								<!--XSSOK-->
  				     		    <emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%= colValue %></emxUtil:lzDate>
  				     		    </a>
       				 	 	    </td>    	
<%  	          		           
  	          		           
  	          		           }
  	          		           else
  	          		           {
  	          		           	 if(iconToolTip == null || iconToolTip.equals(" "))
     	  		                   iconToolTip = ""; 
  	          		           	  href = convJS(href);
  	          		           	 // encodedHref = FrameworkUtil.encodeURLParamValues(href);
//  	          		           	 href = href.replace(' ','+');
                                         href = INFEncode(href,request);
%>  	          		           	
  	          		        	<td class="listCell" valign="top">
								<!--XSSOK-->
               					<a href="JavaScript:emxTableColumnLinkClick('<%=href%>', '', '', 'false', '<%=target%>')" class="object"><img border="0" alt="<%=iconToolTip%>" src="<%=iconUrl%>"><%=colValue%></a>
               					</td>        	
<%               					  
  	          		           	 
  	          		           }
  	          	
  	 	      		        }  	              	  	
         		        }
     			    }
     	     	    else if(columnType.equalsIgnoreCase("href"))
     			    {
     				    String encodedHref = null;
     				    objCellData  = (CellData)row.get(columnKey);
     		   		    href     = objCellData.getHrefCellData();
     				    colValue = objCellData.getCellText();
     				    if(colValue == null)
     				    colValue = "";
     				    if ( sPFmode != null && sPFmode.equals("true") )
           			    {
%>                     
                         <!--XSSOK-->
						 <td class="listCell" valign="top"><%=colValue%></td>
<%
 			            }
           			    else
           			    {
           			    	href = convJS(href);
           			    	//encodedHref = FrameworkUtil.encodeURLParamValues(href);
//           			    	href = href.replace(' ','+');           			    	
                                  href = INFEncode(href,request);
           	%>
				     	<td class="listCell" valign="top">
						    <!--XSSOK-->
     	  					<a href="JavaScript:emxTableColumnLinkClick('<%=href%>', '550', '550', 'false', '<%=target%>')" class="object"><%=colValue%></a>
     					</td>	
     	
<%
			            }
     			    }
     		        else
     		        {
     			        objCellData = (CellData)row.get(columnKey);
     		            colValue = objCellData.getCellText();
     		            if(colValue == null)
     		            colValue="";
%>
                <!--XSSOK-->
				<td class="listCell" valign="top"><%=colValue%></td>	
<%
    	
     		        }
     	        }   	
   	        }//End of for(int j=0;j<columns.size();j++)  
%>  
	</tr> 

<%
    }//End (int rowCount=0;rowCount < tablePageData.size();rowCount++)
  }
 }//End of try 

 	catch (Exception ex) 
 	{
    	ContextUtil.abortTransaction(context);
       
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage(ex.toString().trim());

	}
	finally 
	{
    	ContextUtil.commitTransaction(context);
	}

%>
</table>
<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custSelection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
<!--XSSOK-->
<input type="hidden" name="custPagination" value="<%=noOfItemsPerPage%>">
<input type="hidden" name="custSortColumnName" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custReSortKey" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custSortDirection" value="<xss:encodeForHTMLAttribute><%=sortDirection%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custSortType" value="<xss:encodeForHTMLAttribute><%=sortDataType%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custPageNo" value="<xss:encodeForHTMLAttribute><%=sPage%></xss:encodeForHTMLAttribute>">
<!--XSSOK-->
<input type="hidden" name="custHeader" value="<%=header%>">
<input type="hidden" name="custDisplayMode" value="<xss:encodeForHTMLAttribute><%=displayMode%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custTopActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custBottomActionbar" value="<xss:encodeForHTMLAttribute><%=bottomActionbar%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custHeaderRepeat" value="<xss:encodeForHTMLAttribute><%=sHeaderRepeat%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="suiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDir%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custTargetLocation" value="<xss:encodeForHTMLAttribute><%=sTarget%></xss:encodeForHTMLAttribute>">

</form>
<%
if ( (sPFmode == null || sPFmode.equals("false"))&& tablePageData.size()>0)
{
%>
<script language="JavaScript">

if (document.emxTableForm)
{
    var actBarUrl = "emxInfoCustomTableFooter.jsp?custDisplayMode=" + "<%=XSSUtil.encodeForURL(context,displayMode)%>";
    document.emxTableForm.action = actBarUrl;
    document.emxTableForm.target = "listFoot";
    document.emxTableForm.submit();
}

</script>
<%
}
%>
<%@include file = "MCADBottomErrorInclude.inc"%>
</body>
</html>
