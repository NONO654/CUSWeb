function changeURLParam(strURL, paramName, paramValue){
    var paramPoint = strURL.indexOf(paramName);
    var remainingURL = "";
    if (paramPoint > -1){
      remainingURL = strURL.substring(paramPoint, strURL.length);
      var amppoint = remainingURL.indexOf("&");
      if(amppoint > -1)
      {
        remainingURL = remainingURL.substring(amppoint, strURL.length);
      }
      else
      {
        remainingURL = "";
      }
      strURL = strURL.substring(0, paramPoint - 1);
    }

    if ((paramValue != null) || (paramValue != '') || (paramValue != 'undefined')){
      if (strURL.indexOf("?") == -1){
        strURL = strURL + "?" + paramName + "=" + paramValue;
      }else
      {
        strURL =strURL + "&" + paramName + "=" + paramValue;
      }
    }

    strURL += remainingURL;
    return strURL;
  }
 
  function noPagination(){  
   // Code added for BUG 252437 to enable the Single Pagination Options
   // check if the page requires Persistence in pagination
   // populate the idArray with all the values selected in the current page
   if (this.frames['pagecontent'].hasPersistence)
	   this.frames['pagecontent'].populateArray();

    var loc = this.frames['pagecontent'].document.location.href;
    loc = changeURLParam(loc, "showPaginationMinimized", true);
    pgfooterurl = changeURLParam(pgfooterurl, "showPaginationMinimized", true);
    loadfooterFrame(pgfooterurl, pgheaderurl);
    this.frames['pagecontent'].document.location = loc;    
  }

  function yesPagination(){
   // Code added for BUG 252437 to enable the Single Pagination Options
    // check if the page requires Persistence in pagination
    // populate the idArray with all the values selected in the current page
    if (this.frames['pagecontent'].hasPersistence)
      this.frames['pagecontent'].populateArray();

    var loc = this.frames['pagecontent'].document.location.href;
    loc = changeURLParam(loc, "showPaginationMinimized", false);
    pgfooterurl = changeURLParam(pgfooterurl, "showPaginationMinimized", false);
    loadfooterFrame(pgfooterurl, pgheaderurl);
    this.frames['pagecontent'].document.location = loc;
  }


  function doNavigation(){
    selectObject = document.forms['bottomCommonForm'].mxpagenumber;

    var passedParam = selectObject.options[selectObject.selectedIndex].value;
    passedParam = parseInt(passedParam,10);
    pageNumber = passedParam;
    updateSelectBox();

    this.frames['pagecontent'].document.location.href = changeURLParam(this.frames['pagecontent'].document.location.href,  "pageNumber", pageNumber);
    return;


  }

  function nextPage(){
    selectObject = document.forms['bottomCommonForm'].mxpagenumber;
    var passedParam = selectObject.options[selectObject.selectedIndex].value;       
    
    passedParam = parseInt(passedParam,10);

    if (passedParam < pages){
      pageNumber = passedParam + 1;
      updateSelectBox();

      this.frames['pagecontent'].document.location.href = changeURLParam(this.frames['pagecontent'].document.location.href,  "pageNumber", pageNumber);
      pgfooterurl = changeURLParam(pgfooterurl, "pageNumber", pageNumber);
      loadfooterFrame(pgfooterurl, pgheaderurl);
     }
    return;
  }


  function previousPage(){  
    selectObject = document.forms['bottomCommonForm'].mxpagenumber;
    var passedParam = selectObject.options[selectObject.selectedIndex].value;
    passedParam = parseInt(passedParam,10);

    if (passedParam != 1){
      pageNumber = passedParam - 1;
      if (parseInt(pageNumber,10) < 1)
        pageNumber = 1;

      updateSelectBox();
      this.frames['pagecontent'].document.location.href = changeURLParam(this.frames['pagecontent'].document.location.href,  "pageNumber", pageNumber);
      pgfooterurl = changeURLParam(pgfooterurl, "pageNumber", pageNumber);
      loadfooterFrame(pgfooterurl, pgheaderurl);
  }
    return;
  }

  function updateSelectBox(){

    // check if the page requires Persistence in pagination
    // populate the idArray with all the values selected in the current page
    if (this.frames['pagecontent'].hasPersistence)
      this.frames['pagecontent'].populateArray();
      
    selOption = parseInt(pageNumber,10);
    selOption--;
    if (document.forms['bottomCommonForm'].mxpagenumber){
      selectObject = document.forms['bottomCommonForm'].mxpagenumber;
      if (selOption <= (selectObject.options.length-1)){
        selectObject.options[selOption].selected = true;
      }
    }
    
    
  return;
  }



  //New Unload logic for IE only
  function doUnload() {
    if (getTopWindow().modalDialog) {
      if (isIE) {
        eval("try { getTopWindow().modalDialog.releaseMouse() } catch (e) {}");
      } else {
        getTopWindow().modalDialog.releaseMouse();
      }
    }
  }
  //New Unload logic for IE only

  function goToPage(pg){   
    this.frames[1].location  = pg;
    return;
  }

  var progressBarCheck = 1;

  function removeProgressBar(){
    updateSelectBox();
    progressBarCheck++;
       turnOffProgress();
    
    return true;
  }
