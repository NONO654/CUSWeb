<%@page import="java.util.Map"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.JPO"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "java.util.HashMap"%>
<%@page import="matrix.db.Context"%>

                                      
<%@page import = "com.dassault_systemes.smaslm.matrix.common.*"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%-- <%@include file = "../common/emxNavigatorInclude.inc"%> --%>

<script src="../common/scripts/emxUICalendar.js"></script>
<script src="../common/scripts/emxUIModal.js"></script>
<script src="../common/scripts/emxUIPopups.js"></script>
<script src="../common/scripts/emxSearchGeneral.js"></script>

<script src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUISearch.js"></script>
<script src="../emxUIPageUtility.js"></script>

<script language="javascript" src="../common/scripts/emxTypeAhead.js"></script>
<script type="text/javascript"> addStyleSheet("emxUITypeAhead"); </script>

       <jsp:useBean id="tableBean"
       class="com.matrixone.apps.framework.ui.UITable"
       scope="session"/>
       <jsp:useBean id="SearchBean"
       class="com.dassault_systemes.smaslm.matrix.server.SmaTable"
       scope="session"/>
       
        
<%
		final String REL_SIMULATION_JOB = SimulationUtil
		.getSchemaProperty(SimulationConstants
		    .SYMBOLIC_relationship_SimulationJob);
		
		final String TYPE_SIMULATION = SimulationUtil
		.getSchemaProperty(SimulationConstants
		    .SYMBOLIC_type_Simulation);
		
		final String TYPE_SIMULATION_ACTIVITY = SimulationUtil
		.getSchemaProperty(SimulationConstants
		    .SYMBOLIC_type_SimulationActivity);
		
		String tableID = emxGetParameter(request,"tableID");
		        
		try{
            String size = emxGetParameter(request,"ModifiedDisplayStart");                        
                     
            // Get business object list from session level Table bean
            //HashMap tableData = tableBean.getTableData(tableID);
            MapList relBusObjList = tableBean.getObjectList(tableID);
            Map mp=null;
            //HashMap requestMap = tableBean.getRequestMap(tableID);
            if("*".equals(size)||"STAR".equalsIgnoreCase(size))
            {
                tableBean.setFilteredObjectList(tableID,relBusObjList);     
            }
            else{
                MapList filteredObjPageList = new MapList(); 
                Float sizevalue=Float.parseFloat(size);
                for(int i=0;i<relBusObjList.size();i++)
                {
                   mp= new HashMap();
                   mp=(Map)relBusObjList.get(i);
                   String sizeFromTable=(String)mp.get("Size");
                   if(sizeFromTable!=null&&sizeFromTable!="")
                   {
                    Float sizeFromTabfloat=Float.parseFloat(sizeFromTable);
                    if(sizeFromTabfloat>sizevalue)
                        filteredObjPageList.add(mp);
                        
                   }
                }
           
                            
                tableBean.setFilteredObjectList(tableID,filteredObjPageList);          
            }
                
            
		}catch (NumberFormatException nfe) {            
            nfe.printStackTrace();
        }        
%>

<script language="JavaScript">
parent.refreshTableBody();
</script>

</html>
