<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>



<%
	try
  {
	
	String strObjId = emxGetParameter(request, "objectId");
	String[] strTableRowIds    = emxGetParameterValues(request, "emxTableRowId");
	String strConfigCtxObjIds[]=null;
    strConfigCtxObjIds = new String[strTableRowIds.length];
    StringBuffer sbTableRowId = null;
    for (int i = 0; i < strTableRowIds.length; i++)      // for each table row
    {
    	StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[i] ,"|");
    	strConfigCtxObjIds[i]=strTokenizer.nextToken();
    }
    
    
    //If the selection is empty given an alert to user
    if(strTableRowIds==null){
%>    
      
      <script language="javascript" type="text/javaScript">
          alert("<emxUtil:i18n localize='i18nId'>Effectivity.Alert.FullSearch.Selection</emxUtil:i18n>");
      </script>
    <%
    }
    //If the selection are made in Search results page then     
    else{
    	StringList slConfigCtxObj= new StringList(strConfigCtxObjIds);
    	EffectivityFramework.addConfigurationContext(context,slConfigCtxObj,strObjId);     			   
   			
   			   
   		 
    }
    %>

    <script language="javascript" type="text/javaScript"> 
     //getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;

 
if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN){

           findFrame(getTopWindow(),"CFFConfigurationContext").refreshSBTable();           
             //sbFrame.refreshSBTable();
	}else{
      var listFrame=window.parent.getTopWindow().getWindowOpener().parent;
     listFrame.editableTable.loadData();
     listFrame.rebuildView(); 
     parent.window.closeWindow();
}






    </script>
    <%     
    
	
    
    }catch(Exception ex)
    {
    	%>
        <script language="javascript" type="text/javaScript">
         alert("<%=ex.getMessage()%>");//XSSOK                 
        </script>
        <%    
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>    
