<%--     emxCalendarInclude.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCalendarInclude.inc.rca 1.6 Wed Oct 22 16:17:44 2008 przemek Experimental przemek $";

--%>


<script language="Javascript">

  //get date to start with
  todayDate=new Date();
  thismonth=todayDate.getMonth()+1;
  thisday=todayDate.getDate();
  thisyear=todayDate.getYear();

  //incorrect year is obtained in netscape (add 1900 if below 500)
  if (thisyear < 500){
    thisyear = thisyear + 1900;
  }

  originalLocation = "emxCalendarPopup.jsp?day=" + thisday + "&month=" + thismonth + "&year=" + thisyear;

  function getDate(formName,dateField){
    updatedLocation = originalLocation + "&formName=" + formName + "&dateField=" + dateField;
    showModalDialog(updatedLocation, 280, 300);
  }

  function changeDate(m,d,y,formName,dateField){
    // DATE FORMAT MM/DD/YYYY
    formattedDate = m + "/" + d + "/" + y;

    // Get the Form and Field objects and assing the date value.
    var formObject = document.forms[formName];
    var fieldObject = formObject.elements[dateField];
    fieldObject.value=formattedDate;
  }

</script>

<%--        Sample code showing a table and how to get a formatted date

            getDate(  FORM NAME , FIELD NAME )

<form name=tempform >

<input type="text" name=date value="" />
<a href="javascript:getDate('tempform','date')" ><img src="../common/images/iconCalendar.gif" border="0" /></a>

</form>


--%>
