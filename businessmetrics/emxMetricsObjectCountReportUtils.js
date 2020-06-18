/*!==========================================================================
 *  JavaScript Report Functions
 *  
 *  emxMetricsObjectCountReportUtils.js
 *
 *  This file contains the code for populating the select boxes of the dialog page etc
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 * 
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsObjectCountReportUtils.js.rca 1.4 Wed Oct 22 16:11:57 2008 przemek Experimental $
 *============================================================================
 */


function updateAttributes(){
  var dialogFormName = document.forms [0].name
  var emxType = arguments[0];
   
  //if emxType == null get emyType from form
  if((typeof emxType) == "undefined"){
       emxType = document.getElementById("txtTypeActual").value;
  }  
   
  if (dialogFormName == "BPMObjectCountReportForm"){
      // this is submitting in hidden frame....The frame "metricsReportHidden"
      // is present in the emxBPMReport.jsp
      
      document.forms [0].target = "metricsReportHidden"; 
      document.forms [0].action = "emxMetricsObjectCountReportGetValues.jsp?Type="+emxType;
      document.forms [0].submit ();  
  }
  updateType();
}

function updateSubgroup(){
    var dialogFormName = document.forms [0].name
    var emxType = arguments[0];
    //if emxType == null get emyType from form
    if((typeof emxType) == "undefined"){
        emxType = document.getElementById("txtTypeActual").value;
    }  

    var attrName = document.getElementById("lstGroupBy").value;
    document.forms [0].target = "metricsReportHidden"; 
    document.forms [0].action = "emxMetricsObjectCountReportSubGroupValues.jsp?Type="+emxType+"&AttributeName="+attrName;
    document.forms [0].submit ();  
}
