<%--  WhereUsedTableFilterIncludeProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program --%>

<!-- Include file for error handling -->
<!-- Include file for error handling -->

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<!-- Page directives -->
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
    String STR_ALL = "all";
    String strTableID = emxGetParameter(request, "tableID");
    String strSelectedLevel = emxGetParameter(request,"Level");
	String strSelectedType = emxGetParameter(request,"Type");
    String strSelectedState = emxGetParameter(request,"State");
        
	if(strSelectedLevel == null || 
	   "null".equals(strSelectedLevel) ||
	   "".equals(strSelectedLevel) )
	 {
      strSelectedLevel = STR_ALL;
     }

    if(strSelectedType == null || 
	   "null".equals(strSelectedType) ||
	   "".equals(strSelectedType) ) 
	 {
      strSelectedType = STR_ALL;
     }

    if(strSelectedState == null ||
	   "null".equals(strSelectedState) ||
	   "".equals(strSelectedState)) 
	 {
      strSelectedState = STR_ALL;
	 }

   
	MapList mlFilteredObjMapList = new MapList();
    MapList mlTempMapList = tableBean.getObjectList(strTableID);
	Map mpTempMap = null;
	String strDoObjLevel = "";
    String strDoObjType = "";
    String strDoObjState = "";
    
	/* The following code loops through the each table row 
	   (each map in the mlTempMapList)and filters the table data 
	   by comparing the tabledata(column data) values with the 
	   values selected by the user on the filter bar */
    for(int i=0;i < mlTempMapList.size(); i++) {
		mpTempMap = (Map) mlTempMapList.get(i);
		//Begin of Modify by Vibhu,Enovia MatrixOne for OOC:Issue no. 974 on 26 April,05
        strDoObjType = (String)mpTempMap.get(DomainConstants.SELECT_TYPE);
		strDoObjLevel = (String)mpTempMap.get(DomainConstants.SELECT_LEVEL);
		strDoObjState = (String)mpTempMap.get(DomainConstants.SELECT_CURRENT);
		//End of Modify by Vibhu,Enovia MatrixOne for OOC:Issue no. 974 on 26 April,05

		//Type Pattern
       if( !((strSelectedType.equalsIgnoreCase(strDoObjType))||
		    (STR_ALL.equalsIgnoreCase(strSelectedType)))  ) {
			 continue;
				}
		//Level Pattern 
           else if(!( (strSelectedLevel.equalsIgnoreCase(strDoObjLevel))||
			      (STR_ALL.equalsIgnoreCase(strSelectedLevel)) ) ){
			   continue;
					}
		        //State Pattern 
				else if (! ( (strSelectedState.equalsIgnoreCase(strDoObjState))
					||(STR_ALL.equalsIgnoreCase(strSelectedState)) )) {
                  continue;
						}
				    else {
						  //add to filtered object's maplist
						  mlFilteredObjMapList.add(mpTempMap);
					     }
        //}//end if
	}//end for loop
    
	//put the filetered object's maplist to the tablebean 
    tableBean.setFilteredObjectList(strTableID,mlFilteredObjMapList);

%>
<!--Refreshes the table -->
<script language="JavaScript">
        parent.refreshTableBody();
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
