<%--
  emxProgramCentralDashboardsDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralDashboardsDeleteProcess.jsp.rca 1.12 Wed Oct 22 15:49:32 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file="../emxUICommonAppInclude.inc"%>

<%  
  String[] dashboardName = emxGetParameterValues(request,"emxTableRowId"); 
  dashboardName = ProgramCentralUtil.parseTableRowId(context,dashboardName);
  try 
  {
    // start a write transaction and lock business object
    ContextUtil.startTransaction( context, true );

    //since there is no method to retrieve a set by name, we have to iterate
    SetList sl = matrix.db.Set.getSets( context , true);    
    Iterator setItr = sl.iterator();
    while ( setItr.hasNext() )
    {
      matrix.db.Set foo = ( matrix.db.Set )setItr.next();      
      //loop through each dashboard name selected from the list
      for (int i = 0; i < dashboardName.length; i++)
      {        
        if(foo.getName().indexOf(".dashboard-") != -1) {
          if ( foo.getName().equals( dashboardName[i] ) ) {   // changed for IR-432190-3DEXPERIENCER2017x         
            foo.remove( context );            
            break; // don't need to continue looping
          } // end if
        } //end if 
      } // end for
    } // end while
    // commit the data
    ContextUtil.commitTransaction( context );
  }
  catch (Exception e) {
    ContextUtil.abortTransaction(context);
    e.printStackTrace();
    throw e;
  }
%>
<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    parent.getTopWindow().refreshTablePage();
    // Stop hiding here -->//]]>
  </script>
</html>
