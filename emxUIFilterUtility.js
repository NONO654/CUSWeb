//   emxUIFilterUtility.js
//   This page has functions to use with filtering drop down on UI Level 3 pages as well as
//   common icons placed in the upper right corner of the page [printer,help,conversion]
//
//   Copyright (c) 1992-2018 Dassault Systemes.
//   All Rights Reserved.
//   This program contains proprietary and trade secret information of MatrixOne,
//   Inc.  Copyright notice is precautionary only
//   and does not evidence any actual or intended publication of such program
//
//   static const char RCSID[] = $Id: emxUIFilterUtility.js.rca 1.29 Wed Oct 22 16:10:14 2008 przemek Experimental przemek $
//   ================================================================

  function openPrinterFriendlyPage(timestamp){
    var PageHeadingText = "";
    if(document.mx_filterselect_hidden_form.pheader){
      PageHeadingText = document.mx_filterselect_hidden_form.pheader.value;
    }
    callPrinterPage(PageHeadingText);
  }


  function onFilterOptionChange(){
    var passedParam = document.mx_filterselect_hidden_form.filter_passed_param.options[document.mx_filterselect_hidden_form.filter_passed_param.selectedIndex].value;
    currentURL = document.location.href;

    var remainingURL = "";
    var filterPoint = currentURL.indexOf("mx.page.filter");
    if (filterPoint > -1){
      remainingURL = currentURL.substring(filterPoint,currentURL.length);
      var amppoint = remainingURL.indexOf("&");
      if(amppoint > -1)
      {
        remainingURL = remainingURL.substring(amppoint, currentURL.length);
      }
      else
      {
        remainingURL = "";
      }

      currentURL = currentURL.substring(0,filterPoint -1 );
    }

    newPage = "";
    if (currentURL.indexOf("?") == -1){
        newPage = currentURL + "?mx.page.filter=" + passedParam + remainingURL;
    }
    else
    {
        newPage = currentURL + "&mx.page.filter=" + passedParam + remainingURL;
    }

    document.location.href = newPage;
    return;
  }

  var printDialog = null;

  function callPrinterPage(heading){
    var randomnumber=Math.floor(Math.random()*123456789101112);
    strURL = "";
    var strFilterit="";
    var filteringValue="";
    currentURL = findFrame(window,"pagecontent").document.location.href;
    
    if(document.mx_filterselect_hidden_form.filter_passed_param==null)
    {
      //do nothing
    }
    else
    {
       strFilterit= document.mx_filterselect_hidden_form.filter_passed_param.options[document.mx_filterselect_hidden_form.filter_passed_param.selectedIndex].value;

         if(parent.frames[1].document.formInbox==null){
          //do nothing
         }else{
                 filteringValue=parent.frames[1].document.formInbox.txtSubjectFilter.value;
                 if(filteringValue==null || filteringValue=="" || filteringValue=="*"){
                     parent.frames[1].document.formInbox.filter.value = "false";
                 }else{
                     parent.frames[1].document.formInbox.filter.value = "true";
                 }
         }
    }

    if (currentURL.indexOf("?") == -1){
      // strURL = currentURL + "?PrinterFriendly=true&mx.rnd=" + randomnumber + "&pfheading=" + heading+"&mx.page.filter="+strFilterit+"&txtSubjectFilter="+filteringValue;
      strURL = currentURL + "?PrinterFriendly=true&mx.rnd=" + randomnumber +"&mx.page.filter="+strFilterit+"&txtSubjectFilter="+filteringValue+ "&pfheading=" + heading+"&showWarning=false";
    }else{
      //strURL = currentURL + "&PrinterFriendly=true&mx.rnd=" + randomnumber + "&pfheading=" + heading+"&mx.page.filter="+strFilterit+"&txtSubjectFilter="+filteringValue;
      strURL = currentURL + "&PrinterFriendly=true&mx.rnd=" + randomnumber +"&mx.page.filter="+strFilterit+"&txtSubjectFilter="+filteringValue+ "&pfheading=" + heading+"&showWarning=false";
    }
    iWidth = "700";
    iHeight = "600";
    bScrollbars = true;

      //make sure that there isn't a window already open
    if (!printDialog || printDialog.closed) {

      //build up features string
      var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";

      //calculate center of the screen
      var winleft = parseInt((screen.width - iWidth) / 2);
      var wintop = parseInt((screen.height - iHeight) / 2);

      if (isIE)
        strFeatures += ",left=" + winleft + ",top=" + wintop;
      else
        strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;

      strFeatures +=  ",toolbar=yes";

      //are there scrollbars?
      if (bScrollbars) strFeatures += ",scrollbars=yes";

      //open the window
      printDialog = window.open(strURL, "printDialog" + (new Date()).getTime(), strFeatures);

      //set focus to the dialog
      printDialog.focus();

    } else {
          //if there is already a window open, just bring it to the forefront (NCZ, 6/4/01)
      if (printDialog) printDialog.focus();
    }
  }

  function callConversionPage() {
    var randomnumber=Math.floor(Math.random()*123456789101112);
    newPage = "";
    currentURL = parent.frames[1].document.location.href;
    if (currentURL.indexOf("?") == -1){
      newPage = currentURL + "?convert=true&mx.rnd=" + randomnumber;
    }else{
      newPage = currentURL + "&convert=true&mx.rnd=" + randomnumber;
    }
    //openExternalWindowLarge(newPage);
    showModalDialog(newPage,'1000','300',"scrollbars=yes");
    return;
  }
