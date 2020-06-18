//=================================================================
// JavaScript File - emxUITableUtil.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//
// static const char RCSID[] = $Id: emxUITableUtil.js.rca 1.53.2.2 Tue Dec 23 02:55:23 2008 ds-arajendiran Experimental $
//=================================================================
//
var emxUITableUtil ={};
var normalCheckedCheckbox = null;
var shiftCheckedCheckbox = null;

function reloadTableComponent(customParams)
{
   var listWindow     = window.name == "listDisplay" ? window : findFrame(window, "listDisplay");
   var timeStamp      = listWindow.document.forms['emxTableForm'].timeStamp.value;
   var urlParameters  = emxUICore.getData("../common/emxCustomTableUtility.jsp?mode=postRefresh&uiType=table&timeStamp="+timeStamp);
   urlParameters      = urlParameters.substring(0,urlParameters.indexOf('@'));
   if(customParams)
   {
   	 for(var param in customParams)
   	 {
   		urlParameters = resetURLParameter(param,customParams[param],urlParameters);
   	 }
   }

   listWindow.parent.submitPostToSelf("../common/emxTable.jsp",urlParameters);
}

function loadFilterPage(filterurl){
	var oldurl= listFilter.document.location.href;
	if( oldurl.match("emxBlank.jsp") || oldurl.match("about:blank") ){
	listFilter.document.location.href = filterurl;
	}
}

// Added for User Defined Table to refresh the flat table

function refreshTable(newTable,customSortColumns,CustomSortDirections,timeStamp,uiType,customParams)
{
	/* Added for IR-014448V6R2011 */
	var actualwindow = window.name == "listDisplay" ? window.parent : window;
	var urlParameters =  actualwindow.document.location.href;
	var baseUrl = "";
	if(urlParameters.indexOf("?")>0){
		baseUrl =  urlParameters.substring(0,urlParameters.indexOf("?"));
	}
	else{
		baseUrl = urlParameters;
	}

	if(urlParameters.indexOf("?")>0 && urlParameters.indexOf("&")>0) {
		urlParameters = urlParameters.substring(urlParameters.indexOf("?")+1,urlParameters.length);
	}
	else
	{
		// When parameters are not there in the url(form is submitting to emxTable.jsp page as post).
		// e.g. urlParameters = "http://localhost:8180/ematrix/common/emxTable.jsp?"
		// To get all other parameters, we are doing an ajax call to a jsp page using the timestamp.
		// That jsp page will get the requestMap and send it back to urlParamaters varaible.
		urlParameters = emxUICore.getData("emxCustomTableUtility.jsp?mode=postRefresh&uiType="+uiType+"&timeStamp="+timeStamp);
		urlParameters=urlParameters.substring(0,urlParameters.indexOf('@'));

	}

	urlParameters = resetURLParameter("table",newTable,urlParameters);
	urlParameters = resetURLParameter("dynamic","true",urlParameters);
	urlParameters = resetURLParameter("customSortColumns",customSortColumns,urlParameters);
	urlParameters = resetURLParameter("customSortDirections",CustomSortDirections,urlParameters);

	var fullUrl = baseUrl + "?" + urlParameters ;
	/* IE supports maximum of 2083 characters through GET.*/
	if(actualwindow.document.location && fullUrl.length < 2083){
		actualwindow.document.location.href = fullUrl;
	}
	/* Fix end for IR-014448V6R2011 */
	else
	{
		// Modified for bug no 360700
		var urlParameters = emxUICore.getData("emxCustomTableUtility.jsp?mode=postRefresh&uiType="+uiType+"&timeStamp="+timeStamp);
		urlParameters=urlParameters.substring(0,urlParameters.indexOf('@'));
		urlParameters = resetURLParameter("table",newTable,urlParameters);
		urlParameters = resetURLParameter("dynamic","true",urlParameters);
		urlParameters = resetURLParameter("customSortColumns",customSortColumns,urlParameters);
		urlParameters = resetURLParameter("customSortDirections",CustomSortDirections,urlParameters);

		if(customParams){
			for(var k in customParams){
				urlParameters = resetURLParameter(k,customParams[k],urlParameters);
			}
		}
		actualwindow.submitPostToSelf("../common/emxTable.jsp",urlParameters);
	}
}

function submitPostToSelf(url,formFieldValues)
{
   var frame   = window.frames["postHidden"];
   var form    = frame.document.createElement('form');
   form.name   = "emxHiddenForm";
   form.id     = "emxHiddenForm";

   formFieldValues = getKeyValuePairs(formFieldValues);
   frame.document.body.appendChild(form);

   for(var index=0; index < formFieldValues.length; index++)
   {
	  var input   = frame.document.createElement('input');
	  input.type  = "hidden";
	  input.name  = formFieldValues[index].name;
	  input.value = formFieldValues[index].value;
	  form.appendChild(input);
	}

    form.action = url;
    form.method = "post";
    form.target = "_parent";
    form.submit();
}

function resetURLParameter(parm, val,urlParameters){
    var arrURLparms = urlParameters.split("&");
    var len = arrURLparms.length;
    var count = 0;
    for(var i = 0; i < len; i++){
        arrURLparms[i] = arrURLparms[i].split("=");
        //only change the first matching parm
        if(arrURLparms[i][0] == parm && count == 0){
            count++;
            //set new value
            arrURLparms[i][1] = val;
        }
        arrURLparms[i] = arrURLparms[i].join("=");
    }
    urlParameters = arrURLparms.join("&");
    //if the count is still zero add param to end
    if(count == 0){
        urlParameters += ("&" + parm + "=" + val);
    }
    return urlParameters;
}


var canSubmit = true;
function setTableSubmitAction(submitaction)
{
        canSubmit = submitaction;
}


function submitTable()
{
    if(canSubmit)
    {
        var showAlert = true;
        var selectedIds = this.ids;
        if((!listDisplay.document.emxTableForm.emxTableRowId) || (selectedIds != null && selectedIds != 'undefined' && selectedIds.length > 1)) {
            showAlert = false;
        }

        if(showAlert) {
            alert(document.forms['footerForm'].SubmitAlertMsg.value);
            return;
        }

        setTableSubmitAction(false);
        if(document.forms['footerForm'].SubmitURL){
            listDisplay.document.emxTableForm.action = document.forms['footerForm'].SubmitURL.value;
            listDisplay.document.emxTableForm.target = "listHidden";
            addSecureToken(listDisplay.document.emxTableForm);
            listDisplay.document.emxTableForm.submit();
            removeSecureToken(listDisplay.document.emxTableForm);
        }
    } else {
        return;
    }
}

function closeTable()
{
    listDisplay.document.emxTableForm.action = document.forms['footerForm'].cancelURL.value;
    listDisplay.document.emxTableForm.target = "listHidden";
    listDisplay.document.emxTableForm.submit();
}

function refreshTableContent()
{
  parent.listDisplay.location.reload();
}


function openRenderPDFPage(timeStamp, useAdlibSetup, uiType) {
	
	if (uiType == "table" && useAdlibSetup == 'true') {
		var strURL = "";
		var objListWindow = findFrame(parent, "listDisplay");
		var currentURL = objListWindow.document.location.href;
		if (currentURL.indexOf("?") == -1) {
			strURL = "emxRenderPDFDisplay.jsp";
		} else {
			strURL = "emxRenderPDFDisplay.jsp"
					+ currentURL.substring(currentURL.indexOf("?"));
		}
		if (strURL.indexOf("?") > 0) {
			strURL += "&uiType=table&useAdlibSetup="+useAdlibSetup;
		} else {
			strURL += "?uiType=table&useAdlibSetup="+useAdlibSetup;
		}
		var intWidth = "800";
		var intHeight = "800";
		showNonModalDialog(strURL, intWidth, intHeight, true);

	}

}


/**
* overrides RenderPDF method
*/

function fpOpenRenderPDFPage(){
	
	  	if (displayView === "tree"){
	  		openRenderPDFForTree();
            return;
        }  	
    	
    	strURL = "";
		var currentURL1 = window.location.href;
		
		var res = currentURL1.substring(0, currentURL1.indexOf("/common") + 8)
				+ "emxFreezePanePrinterFriendly.xsl?ajax-no-cache=" + timeStamp;
		var queryString = currentURL1.substring(currentURL1.indexOf("?") + 1,
				currentURL1.length);
		

		var intWidth = "800";
		var intHeight = "800";

		var XSLT = "emxFreezePanePrinterFriendly.xsl";
		var XSLT_DOM = emxUICore.GetXSLRemote(XSLT);		
		var setting  = oXML.createElement("setting");
		setting.setAttribute("name","IsRenderPdf");		
		setting.appendChild(oXML.createTextNode("true"));
		var requestMap =oXML.getElementsByTagName("requestMap")[0];		
		requestMap.appendChild(setting);		
		var strHTML = emxUICore.transformToText(oXML, XSLT_DOM);		
		requestMap.removeChild(setting);
				
		var useAdlibSetup='false';
		useAdlibSetup = useAdlibSetup.toString();
		
		queryString = "uiType=" + uiType + "&timeStamp=" + timeStamp
				+ "&useAdlibSetup=" + useAdlibSetup + "&" + queryString;

		var data = queryString.split("&");

		emxUICore.downloadPDFPost("emxRenderPDF.jsp?" + queryString,
				strHTML);
    	
    }



function openRenderPDFForTree(){
	
    var tileWidth = 707; // Print width in px, good on A4
    var tileHeight = 1000; // Print height in px, good on A4
    treeToImages(tileWidth, tileHeight, function ready(tiles){
        var nRow = tiles.length;
        var nCol = tiles[0].length;
        var html = '<!DOCTYPE html><html><head><title>' + document.title + '</title>';
        html += '<style type="text/css" media="print">.no-print{display: none;}</style>';
        html += '<style type="text/css" media="screen">.print{display: none;}</style></head><body>';        

        // Add no-print elements
        html += '<div class="no-print"><table style="border-spacing: 10px">';
        var canvas = document.createElement('canvas');            
        canvas.width = tileWidth;
        canvas.height = tileHeight;
        var ctx = canvas.getContext("2d");      
        for (var iRow=0; iRow<nRow; iRow++){
            html += '<tr>';
            for (var iCol=0; iCol<nCol; iCol++){
                ctx.putImageData(tiles[iRow][iCol], 0, 0);
                var imgUrl = canvas.toDataURL("image/png");                    
                html += '<td>';
                html += '<img style="border-width:1px;border-style:dashed;" src="' + imgUrl + '"><div style="page_break_before:always"/>';
                html += '</td>';
            }
            html += '</tr>';
        }        
        html += '</table></div>';        
        
        // Add print elements
        html += '<div class="print">'; 
        for (var iRow=0; iRow<nRow; iRow++){
            for (var iCol=0; iCol<nCol; iCol++){
                ctx.putImageData(tiles[iRow][iCol], 0, 0);
                var imgUrl = canvas.toDataURL("image/png");
                html += '<img src="' + imgUrl + '"><div style="page_break_before:always"/>';
            }
        }
        html += '</div></body></html>';
     //   openHtmlWindow(html);
        
        var currentURL1 = window.location.href;
		
		var queryString = currentURL1.substring(currentURL1.indexOf("?") + 1,
				currentURL1.length);

		var useAdlibSetup ='false';
		queryString = "uiType=" + uiType + "&timeStamp=" + timeStamp
				+ "&useAdlibSetup=" + useAdlibSetup + "&" + queryString;

		var data = queryString.split("&");

		emxUICore.downloadPDFPost("emxRenderPDF.jsp?" + queryString,
				html);
          
        
    });
}


function callConversionPage()
{
  var tableURL = parent.location.href;
  tableURL = tableURL + '&convert=true';
  var windowObject = showNonModalDialog(tableURL, '700', '600',true);
}

function exportToExcelHTML(timeStamp,TransactionType)
{
    var strURL = "emxTableReportView.jsp?timeStamp=" + timeStamp + "&reportFormat=ExcelHTML&TransactionType="+TransactionType;
    var strFeatures = "location=no,menubar=yes,titlebar=yes,width=700,height=500,resizable=yes,scrollbars=auto";
    window.open(strURL, "ExportTable", strFeatures);
}


function exportTableData(timeStamp,TransactionType)
{
   var tableURL="emxTableExport.jsp?timeStamp=" + timeStamp + "&TransactionType="+TransactionType;
   listHidden.location.href = tableURL;
}

function exportData(timeStamp,TransactionType)
{
   exportTableData(timeStamp,TransactionType);

}
function multiColumnSortData(timeStamp,uiType)
{
    if(uiType == "structureBrowser" && isDataModified()){
        alert(emxUIConstants.STR_SORTALERT);
        return;
    }
    var strURL="emxMultiColumnSortDialog.jsp?timeStamp="+ timeStamp + "&uiType="+uiType;
    showModalDialog(strURL, 400, 275, false);
}

function showChartOptions(timeStamp)
{
   var objListWindow = findFrame(parent, "listDisplay");
   var objForm = objListWindow.document.forms[0];
   var totNumobj = objForm.totalNumObjects.value;
   var strchartAlert = objForm.chartAlert.value;
   if(totNumobj <= 0) {
        alert(strchartAlert);
   } else {
        submitList("emxChartOptions.jsp?timeStamp=" + timeStamp, "listHidden","none","true","550","600");
   }
}

function showTableCalcOptions(timeStamp)
{
   var objListWindow = findFrame(parent, "listDisplay");
   var objForm = objListWindow.document.forms[0];
   var totNumobj = objForm.totalNumObjects.value;
   var strcalcAlert = objForm.calcAlert.value;
   if(totNumobj <= 0) {
        alert(strcalcAlert);
   } else {
        showModalDialog("emxTableCalculationOptions.jsp?timeStamp=" + timeStamp,"550","600",true);
   }
}


// Cleanup the session level table bean
function cleanupSession (timeStamp)
{
  emxUICore.getData('emxTableCleanupSession.jsp?timeStamp=' + timeStamp);
}



function reloadTable(timeStamp, sortKey, nextSortDirection,TransactionType)
{
    turnOnProgress("utilProgressBlue.gif");

    var url = "emxTableSortController.jsp?sortColumnName=" + escape(sortKey) + "&timeStamp=" + timeStamp + "&TransactionType=" + TransactionType;
    if (nextSortDirection != null)
        url = url + "&sortDirection=" + nextSortDirection;
    var frm;
    if(window.name == "listDisplay"){
    	frm = findFrame(parent, "listHidden");
    } else {
    	frm = findFrame(this, "listHidden");
    }
    if(!frm){
        if(window.name == "formViewDisplay"){
        	frm = findFrame(parent, "formViewHidden");
        } else {
        	frm = findFrame(this, "formViewHidden");
        }
    }

    frm.document.location.href = url;
}


function navigatePage (page , displayMode)
{

    turnOnProgress("utilProgressBlue.gif");

    //if not a number, calculate position
    if(isNaN(parseInt(page))){
        var iPosition = (page == "next")? 1 : -1;
        var iPos = document.footerForm.menu1.selectedIndex + iPosition;
        document.footerForm.menu1.options[iPos].selected = true;
    }

    var pageUrl = "emxTablePaginationController.jsp?page=" + page + "&displayMode=" + displayMode;
    footerurl = footerurl + "&displayMode=" + displayMode;
    var listFrame = findFrame(this, "listDisplay");
    if(!listFrame) {
    	listFrame = findFrame(parent, "listDisplay");
    }
    listFrame.document.emxTableForm.action = pageUrl;
    listFrame.document.emxTableForm.target = "listHidden";
    listFrame.document.emxTableForm.submit();
}

var footerLoaded = false;
var filterFrameLoaded = false;

function loadFooter(){
	var dpf = document.getElementById("divPageFoot");
	dpf.innerHTML = emxUICore.getDataPost(footerurl,'');
}

function readjustBodytop(){
	var phd = document.getElementById("pageHeadDiv");
	var dpb = document.getElementById("divPageBody");
	if(phd && dpb){
		var ht = phd.clientHeight;
		if(ht <= 0){
			ht = phd.offsetHeight;
		}
		dpb.style.top = ht + "px";
	}
}

function adjustBody(filterfrmsize) {
	addOrHideHeaderItems();
	if(filterfrmsize > 0) {
		var dlf = document.getElementById("divListFilter");
		dlf.style.height = filterfrmsize + "px";
	}
	var phd = document.getElementById("pageHeadDiv");
		var dpb = document.getElementById("divPageBody");
	var ht = phd.clientHeight;
	if(ht <= 0){
		ht = phd.offsetHeight;
	}
	dpb.style.top = ht + "px";
	closeAutoFilterSlideIn();
}


var displayLoaded = false;
function loadDisplayFrame(url){
    if (!displayLoaded){
        displayLoaded = true;
        var displayFrame = findFrame(parent, "listDisplay");
        if (displayFrame)
        {
            displayFrame.location.href= url;
        }
    }
}
function addFooterSubHeaderItems(){
	if(typeof freezePaneLayoutData != "undefined"){
			var subHeaderVal = freezePaneLayoutData.subHeaderText ;
			var subheaderTD  = jQuery('<td id="sb_subHeader"></td>').html(subHeaderVal);
			jQuery("#divPageFoot").find("tr").prepend(subheaderTD);
			subHeaderVal = jQuery("<div/>").html(subHeaderVal).text();
			jQuery("#sb_subHeader").attr("title", subHeaderVal);
	}
}
function addOrHideHeaderItems(){
	var isExtendedHeaderPresent = jQuery(getTopWindow().document).find("#ExtpageHeadDiv").css("display") == "block";
	var pageHeaderTable  =  jQuery("#pageHeadDiv").find("#contentHeader");
	var tempbclist = getTopWindow().bclist;
	var backButtonTooltip = emxUIConstants.STR_BACK_TOOLTIP;
	var forwardButtonTooltip = emxUIConstants.STR_FORWARD_TOOLTIP;
	if(tempbclist){
		backButtonTooltip = tempbclist.getBackButtonTooltip();
		forwardButtonTooltip = tempbclist.getForwardButtonTooltip();
	}
	if(!isExtendedHeaderPresent){
		
		//TODO Modify HTML/ CSS as per what Don provides. 
		if(this.portalMode != "true" && getTopWindow().document.location.href.indexOf("emxNavigatorDialog.jsp")== -1){
			
			var homeTitle = typeof getTopWindow().brandName != "undefined" ? getTopWindow().brandName+" "+getTopWindow().appNameForHomeTitle+" " + emxUIConstants.STR_BC_LABEL_HOME : getTopWindow().appNameForHomeTitle+" " + emxUIConstants.STR_BC_LABEL_HOME;
			var headerButtons='';
			headerButtons = jQuery('<td><div class="field previous button disabled"><a><button class="previous" title="'+backButtonTooltip+'"></button></a></div></td><td><div  class="field next button disabled"><a><button class="next" title="'+forwardButtonTooltip+'"></button></a></div></td>');
			if(!getTopWindow().opener){
				jQuery(".functions tr:first").append(headerButtons);
			}
			//don't append header navigation icons in popup
			
			
			if(tempbclist){
				(tempbclist.currentPosition() > 1) ? jQuery('.previous').removeClass('disabled'): jQuery('.previous').addClass('disabled');
				(tempbclist.currentPosition() < tempbclist.length()) ? jQuery('.next').removeClass('disabled'): jQuery('.next').addClass('disabled');
			}
			if(tempbclist){
			if(tempbclist.currentPosition() == tempbclist.length()){
				jQuery('.field.next.button').addClass('disabled');	
			}else{
				jQuery('.field.next.button').removeClass('disabled');
			}
			}
			jQuery('button.previous').click( function(){
				if(this.className.indexOf("disabled") != -1){
					return false;
				}else{
					getTopWindow().bclist.goBack();
					return false;
				}
			});
			jQuery('button.next').click( function(){
				if(this.className.indexOf("disabled") != -1){
					return false;
				}else{
					getTopWindow().bclist.goForward();
					return false;
				}
			});
			jQuery('button.home').click( function(){
				if(this.className.indexOf("disabled") != -1){
					return false;
				}else{
				getTopWindow().launchHomePage();
					return false;
				}
			});
			jQuery("div#divExtendedHeaderNavigation").find(".field.share.button").hide();
		}
		if(this.portalMode == "true"){
			addFooterSubHeaderItems();
		}
		
	}else{
		if(tempbclist){
			if(tempbclist.currentPosition()==1 || tempbclist.length()==1){
	              getTopWindow().jQuery(".field.previous.button").addClass('disabled');
	              getTopWindow().jQuery('#divExtendedHeaderNavigation').find("a[title=Forward]").removeAttr('href');
	    }
		if(tempbclist.currentPosition() == tempbclist.length()){
			getTopWindow().jQuery(".field.next.button").addClass('disabled');
			getTopWindow().jQuery('#divExtendedHeaderNavigation').find("a[title=Forward]").removeAttr('href');
		}else{
			getTopWindow().jQuery(".field.next.button").removeClass('disabled');
			getTopWindow().jQuery('#divExtendedHeaderNavigation').find("a[title=Forward]").attr('href','javascript:getTopWindow().bclist.goForward();');
			}
		}
		if(getTopWindow().document.location.href.indexOf("emxNavigatorDialog.jsp") > 0) {
			jQuery("div",jQuery("div#divExtendedHeaderNavigation")).not("div.field.previous.button, div.field.next.button, div.field.refresh.button , div.field.resize-Xheader.button").hide();
			jQuery("div#divExtendedHeaderNavigation").find(".field.share.button").show();
		}
		var subheaderObj =  jQuery(pageHeaderTable).find("#pageSubHeader");
		var tdSubheaderObj = jQuery(subheaderObj).find("#sb_subHeader");
		if(subheaderObj.length > 0 && tdSubheaderObj.length == 0 ){
			var subheaderTD  = jQuery('<td id="sb_subHeader"></td>').html(subheaderObj);
			jQuery("#divPageFoot").find("tr").prepend(subheaderTD);
		}else if(subheaderObj.length == 0 && this.portalMode == "true"){
			addFooterSubHeaderItems();	
		}
		//hide the page header if the extended header is present.
		if(pageHeaderTable){
			jQuery(pageHeaderTable).hide();
		}
		getTopWindow().jQuery('#divExtendedHeaderNavigation div.field.previous.button a').attr("title",backButtonTooltip);
		getTopWindow().jQuery('#divExtendedHeaderNavigation div.field.next.button a').attr("title",forwardButtonTooltip);
				
		hideExtendedPageHeader();				
	}
	readjustBodytop();
}


function hideExtendedPageHeader(){
	var extHeaderRef = jQuery(getTopWindow().document);
	var extpageHeadDiv = extHeaderRef.find("#ExtpageHeadDiv");
	var lsValue = localStorage.getItem('minHeaderView');	

	if((lsValue && extpageHeadDiv.hasClass("page-head"))||(!lsValue && extpageHeadDiv.hasClass("page-head-mini"))){
		extHeaderRef.find("#resize-Xheader-Link").trigger("click");			
	}	
}

/*
         * emxTableColumnLinkClick method modified for PowerView Enhancement Feature.
         * The emxTableColumnLinkClick method dynamically assigns the 'src' of iframe with the required 'href'
         * and displays the 'href' content in the target tab.
         * 16 Aug 2007
         */

//modified for bug 346636

function emxTableColumnLinkClick(href, width, height, modal, target, onselaction, colValue, indentedTableBln,strPopupSize, slideinWidth)
{
         var objPowerView;
         var showTabHeader= 'false';
         var targetBln = 'false';
         var targetType = '';

         if(href.indexOf("showTabHeader=") != -1)
         {
             var index = href.indexOf("showTabHeader=");
             var boolVal = href.substring(index+14,index+15);
             if(boolVal == 't' || boolVal == 'T')
             {
                 showTabHeader =  true;
             }
             else
             {
                 showTabHeader =  false;
             }
         }
        href = encodeAllHREFParameters(href);
    try{
         if(getTopWindow().getWindowOpener())
         {
             if(indentedTableBln == 'true' && !parent.objPortal)
             {
                 // For Structure Browser opened in a popup thru Launch button i.e., if indentedTableBln = true
                 // and there is no portal object in the PopUp.
                objPowerView = getTopWindow().getWindowOpener().parent.objPortal;
             }else if(parent.parent.objPortal)
             {
                //For Flat table opened in a popup and if the Target Location is on the same popup window.
                objPowerView = parent.parent.objPortal;
             }else if(parent.objPortal || indentedTableBln == 'true')
             {
                 // For Structure Browser opened in a popup and if the Target Location is on the same popup window.
                objPowerView = parent.objPortal;
             }else
             {
                 //For Flat table opened in a popup thru Launch button and there is no portal object in the Popup.
                objPowerView = getTopWindow().getWindowOpener().parent.parent.objPortal;
             }

         }
           else if(indentedTableBln == 'true')
           {
              objPowerView  = parent.objPortal;
           }
           else
           {
              objPowerView  = parent.parent.objPortal;
           }
    }catch(e){}

         if(objPowerView)
         {
              for(var i =0 ; i < objPowerView.rows.length ; i++)
              {
                for (var j =0 ; j < objPowerView.rows[i].containers.length ; j++ )
                {
                    for(var k = 0 ; k < objPowerView.rows[i].containers[j].channels.length;k++ )
                    {
                        var mItems = objPowerView.rows[i].containers[j].tabset.menu;
					if(typeof mItems != 'undefined'){ 
                          for(var r=0;r<mItems.items.length;r++)
                        {
                            if(objPowerView.rows[i].containers[j].channels[k].tabName == target || mItems.items[r].text == target)
                            {
                                targetBln = true;
                                targetType = "tab";
                            }
                        }
                        if(mItems.items.length == 0)
                        {
                        if(objPowerView.rows[i].containers[j].channels[k].tabName == target)
                        {
                            targetBln = true;
                            targetType = "tab";
                        }
                    }
                }
              }
               }
		}
              var matchFound = false;
              for(var i =0 ; i < objPowerView.rows.length ; i++)
              {
                for (var j =0 ; j < objPowerView.rows[i].containers.length ; j++ )
                {
                    if(href.indexOf("emxRefreshChannel.jsp") != -1){
                            var channelName = objPowerView.rows[i].containers[j].channelName;
                            if(channelName != null && href.indexOf("channel="+channelName) > -1){
                                targetBln = true;
                                targetType = "channel";
                                matchFound = true;
                                break;
                            }else{
                                targetBln = false;
                                targetType = "channel";
                            }
                        }
                }
                if(matchFound){
                    break;
                }
              }

                   if(targetBln == true && targetType == "tab")
                   {
                    for(var i =0 ; i < objPowerView.rows.length ; i++)
                    {
                        for (var j =0 ; j < objPowerView.rows[i].containers.length ; j++ )
                        {
                            for(var k = 0 ; k < objPowerView.rows[i].containers[j].channels.length;k++ )
                            {
                                if(objPowerView.rows[i].containers[j].channels[k].tabName == target)
                                {
                                //Fetched URL from Command
                                    objPowerView.rows[i].containers[j].channels[k].url = href;
                                //The URL set to iframe src
                                    objPowerView.rows[i].containers[j].channels[k].data.src =href;
                                    if(getTopWindow().getWindowOpener() && !parent.parent.objPortal && !parent.objPortal)
                                    {
                                        window.blur();
                                    }
                                    if(showTabHeader == true){
                                    objPowerView.rows[i].containers[j].channels[k].tabdiv.innerHTML = colValue;
                                    objPowerView.rows[i].containers[j].channels[k].tabdiv.style.display = 'block';
                                    }else
                                    {
                                    objPowerView.rows[i].containers[j].channels[k].tabdiv.style.display = 'none';
                                    }
                                    var objSet = objPowerView.rows[i].containers[j].tabset;
                                    var tabID = objPowerView.rows[i].containers[j].channels[k].index;
                                var menuItems = objPowerView.rows[i].containers[j].tabset.menu;

                                var bVal = false;
                                for(var l=0;l<objSet.tabs.length;l++)
                                {
                                    if(objSet.tabs[l].channel.tabName == target)
                                    {
                                     bVal = true;
                                    }

                                }

                                if(menuItems.items.length > 0 && bVal == false)
                                {
                                    for(var m=0;m<menuItems.items.length;m++)
                                    {
                                           objSet.tabs[objSet.selectedID].sendToBack();

                                               //If the selected tabs "URL" is not equal to the target "href" only then swap happens.
                                               //If this check is not done,then there will be a swap of channels everytime the user clicks on the target href.
                                           if(objSet.tabs[objSet.selectedID].channel.url != href)
                                           {
                                                   if(menuItems.items[m].channel.tabName == target)
                                                {
                                                   var objChannel = menuItems.items[m].channel;
                                                   menuItems.items[m].channel = objSet.tabs[objSet.selectedID].channel;
                                                   objSet.tabs[objSet.selectedID].channel= objChannel;
                                                }
                                              }

                                           // For Menu
                                           objSet.menu.items[m].rowElement.firstChild.lastChild.innerHTML = menuItems.items[m].channel.text;
                                           objSet.menu.items[m].rowElement.firstChild.lastChild.title = menuItems.items[m].channel.fulltext;
                                           // For Tab Items
                                           objSet.tabs[objSet.selectedID].element.title = objSet.tabs[objSet.selectedID].channel.fulltext;
                                           objSet.tabs[objSet.selectedID].element.innerHTML = "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td class=\"text\" nowrap=\"nowrap\">" + objSet.tabs[objSet.selectedID].channel.fulltext + "</td><td class=\"corner\"><img src=\"" + IMG_SPACER + "\" width=\"16\" height=\"1\" /></td></tr></table>";

                                           objSet.tabs[objSet.selectedID].bringToFront();

                                    }
                                }else
                                {
                                    for(var l=0;l<objSet.tabs.length;l++)
                                    {
                                        if (objSet.tabs[l].channel.tabName== target)
                                            {
                                                    objSet.tabs[l].bringToFront();
                                             objSet.selectedID = l;
                                            }
                                            else
                                            {
                                                    objSet.tabs[l].sendToBack();
                                            }
                                    }
                                }
                            }
                        }
                     }
                 }
                   }else if(targetBln == true && targetType == "channel")
                    {
                        var strHref = "";
                        var jsData = null;
                        createRequestObject();
                        var portalName = "";
                        var portalDisplayFrame = null;
                        portalDisplayFrame = findFrame(getTopWindow(),"portalDisplay");
                        if(portalDisplayFrame == null){
                        if (getTopWindow().getWindowOpener()) {
                            portalDisplayFrame = getTopWindow().getWindowOpener().findFrame(getTopWindow().getWindowOpener().getTopWindow(),"portalDisplay");
                        } else {
                            portalDisplayFrame = findFrame(getTopWindow(),"portalDisplay");
	                        }
                        }
                        var qb = buildRequestParam(portalDisplayFrame.location.href);
                        portalName = qb["portal"];
                        var objectId = FORM_DATA["objectId"];
                        var strHref = "";
                        if(href.indexOf("?") > -1){
                            strHref = href + "&portal="+portalName+"&objectId="+objectId+"&refresh=true&isIndentedTable="+indentedTableBln;
                        }else{
                            strHref = href + "?portal="+portalName+"&objectId="+objectId+"&refresh=true&isIndentedTable="+indentedTableBln;
                        }
                        //highlight current Row
                        var portalHiddenForm = null;
                        if(portalDisplayFrame.document.getElementById("portalHiddenForm") == null){
                            portalHiddenForm = portalDisplayFrame.document.createElement("FORM");
                            portalHiddenForm.id = "portalHiddenForm";
                            portalHiddenForm.name = "portalHiddenForm";
                            portalDisplayFrame.document.body.appendChild(portalHiddenForm);
                            portalHiddenForm.action = strHref;
                            portalHiddenForm.method = "post";
                            portalHiddenForm.target = "listHidden";
                            portalHiddenForm.style.width = "1px";
                            portalHiddenForm.style.height = "1px";
                            portalHiddenForm.submit();
                        }else{
                            portalHiddenForm = portalDisplayFrame.document.getElementById("portalHiddenForm");
                            portalHiddenForm.action = strHref;
                            portalHiddenForm.method = "post";
                            portalHiddenForm.target = "listHidden";
                            portalHiddenForm.submit();
                        }
                    }
                    else if(targetType == "channel" && targetBln == false){
                        alert(emxUIConstants.STR_JS_InvalidChannelName);
                    }
                    else if(target == "slidein"){
                        getTopWindow().showSlideInDialog(href + '&windowMode=slidein', modal, window.name, '', slideinWidth);
                        return;
                    }
                    else
                    {
                         openAsPopup(href, width, height, modal, target, onselaction,strPopupSize);
                         return;
                    }
          }else if(target == "slidein"){
              getTopWindow().showSlideInDialog(href + '&windowMode=slidein', modal, window.name, '', slideinWidth);
              return;
          }else
          {
        	  if(target == "content" && getTopWindow() && getTopWindow().closeWindowShadeDialog && getTopWindow().document.getElementById("windowshade").style.display == "block") {
                  getTopWindow().closeWindowShadeDialog();
              }
             openAsPopup(href, width, height, modal, target, onselaction,strPopupSize);
             return;
          }
}
function buildRequestParam(qStr) {
    if (!qStr) { qStr = ""; }
    var baseUrl = qStr.replace(/[?].*/, "");
    var items = new Object();
    var search = qStr.substr(baseUrl.length+1);
    if (search == qStr) { search = ""; }
    var params = search.split("&");
    for (var i = 0; i<params.length; i++) {
        var param = params[i];
        if (param == '') continue;
        var name = decodeURIComponent(param.replace(/=.*/, ""));
        var value = decodeURIComponent(param.substr(name.length + 1));
        items[name]=value;
    }
    return items;
}
/*
         * openAsPopup method added for PowerView Enhancement Feature.
         * The openAsPopup method opens the 'href' content in a popup if the target tab is not found
         * and also in case it is outside PowerView Context.
         * 16 Aug 2007
         */

function openAsPopup(href, width, height, modal, target, onselaction,strPopupSize)
{
    var url = href;
    var windowObject;
    var targetFrame;

    //Modified for Bug : 347647
    var isContentOverride = false;
    if("contentOverride" == target || "content" == target){
        isContentOverride = true;
        target = "content";
    }

    if (getTopWindow() && getTopWindow().name == "mxPortletContent")
    {
        window.open(url);
        return;
    }

    if (target == "popup")
    {
        if (modal == "true")
            windowObject = showModalDialog(encodeURI(decodeURI(url)), width, height,true,strPopupSize);
        else
            windowObject = showNonModalDialog(encodeURI(decodeURI(url)), width, height,true,true,strPopupSize);
    } else {

        //added to support My Portal pop up details trees (NCZ, 18-Jul-03)
        if (HIDDEN_FRAME_LIST.find(target)==-1  &&
        		openerFindFrame(getTopWindow(), "treeDisplay") == null && href.indexOf("portalCmdName") > -1 && href.indexOf("portalCmdName=null") == -1 && !isContentOverride) {
                 showNonModalDialog(url, 700, 600,true,strPopupSize);
                 return;
        } else if ( (href.indexOf("emxTree.jsp") == 0 || href.indexOf("../common/emxTree.jsp") == 0 ) &&
                ( href.indexOf("mode=insert") != -1) &&
                ( target=="content") &&
                ( openerFindFrame(getTopWindow(), "treeDisplay") != null) &&
                ( getTopWindow().tempTree) )
        {
            href = href.replace("emxTree.jsp", "emxTreeDisplay.jsp");
            targetFrame = openerFindFrame(getTopWindow(), "treeDisplay");

        } else  {
            // targetFrame = findFrame(getTopWindow(), target);
            targetFrame = openerFindFrame(getTopWindow(), target);
        }

      //if there is a target, assign the form's target to it
      if (targetFrame)
      {
          /*
          document.emxTableForm.target = targetFrame.name;
          //assign the URL to the form's action
          document.emxTableForm.action = href;
          //submit the form
          document.emxTableForm.submit();
          */
    	  if(getTopWindow().getWindowOpener() && href.indexOf("emxTree.jsp") > -1 && targetFrame.getTopWindow().location.href.indexOf("emxNavigator.jsp") == -1){
    		  targetFrame.location.href = href;
    	  }else{
    		  if (jQuery.inArray(target,HIDDEN_FRAME_LIST) != -1) {
    			  submitWithCSRF(href,targetFrame);
    		  }else{
    		  targetFrame.location.href = href;
    		  }
    		 
    	  }
          // set the focus to new window
          targetFrame.focus();

        } else {
            //alert("Unable to find the target frame : " + target);
            windowObject = showNonModalDialog(url, '750', '600',true, strPopupSize);
        }
    }

        /*
        'Close Window' : Search Results window will be closed
        'Show Content' : Main content frame will be shown and search results window will
                         be minized, this will be the default value.
        'Show Search'  : Search Results window will remain focussed..
        */

        if(onselaction == "Close Window")
        {
            getTopWindow().closeWindow();
        }
        else if(onselaction == "Show Content")
        {
            getTopWindow().blur();
        }
        else if(onselaction == "Show Search")
        {
            getTopWindow().focus();
        }
}


function onFilterOptionChange(objThis,persist, filterName, filterValue){
	  var actualwindow = window.name == "listDisplay" ? window.parent : window;
	  var currentURL=actualwindow.location.href;
	  var baseURL= currentURL.substring(0, currentURL.indexOf("?")+1);
	  var programURL = filterValue.split("|")[0];
	  var labelURL = filterValue.split("|")[1];
	  var strProgram =  "program";
	  var strProgramLabel ="programLabel";
	  var urlParameters= currentURL.substring(currentURL.indexOf("?")+1,currentURL.length);
	  if(urlParameters.indexOf("inquiry") > -1 && urlParameters.indexOf("inquiryLabel") > -1){
		  strProgram =  "inquiry";
		  strProgramLabel = "inquiryLabel";
	  }
	  urlParameters  =resetTableParameter(strProgram,programURL,urlParameters);
	  urlParameters= resetTableParameter(strProgramLabel,labelURL,urlParameters);
	  var selectFilter= filterValue.split(",")[0];
	  urlParameters= resetTableParameter("selectedFilter",selectFilter,urlParameters);
	  actualwindow.location.href=baseURL+urlParameters;
    return;
}


function openPrinterFriendlyPage(timeStamp,TransactionType)
{
    // var strURL = "";
    // currentURL = parent.frames[1].document.location.href;

    var strURL = "../common/emxTableReportView.jsp?timeStamp=" + timeStamp + "&reportFormat=HTML&TransactionType="+TransactionType;
    showPrinterFriendlyPage(strURL);
}


function openWindow(strURL)
{
    window.open(strURL);
}

function registerCheckedRowIdToCompassInTable(strID) {
	if(getTopWindow().isfromIFWE){
		var strID = objCheckbox.value;
		strID = strID.split('|');
		var oid = strID[1];
    	var physicalid = JSON.parse(emxUICore.getData('../resources/bps/physicalids?oid_list=' + oid));	
  	  getTopWindow().registerIdtoCompass(physicalid[0],getTopWindow().curSecCtx);
  	}
}


// Methods for Tracking the selections
function register(strID) {

    var toolBarFrame;
    if (parent.frames){
        toolBarFrame = parent;
    }

    if (!parent.ids) {
            parent.ids = "~";
    }

    if (parent.ids.indexOf(strID + "~") == -1) {
            parent.ids += strID + "~";
    }

    toolBarFrame = parent;
    if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
        toolBarFrame.toolbars.setListLinks( parent.ids.length > 1);
    }
}

function unregister(strID) {
    var strTemp = parent.ids;
    if(strTemp == null || strTemp == 'undefined')
        return;
    var toolBarFrame;

    if (parent.frames){
        toolBarFrame = parent;
    }

    if (strTemp.indexOf("~" + strID + "~") > -1) {
            strTemp = strTemp.replace(strID + "~", "");
            parent.ids = strTemp;
    }
    toolBarFrame = parent;
    if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
            toolBarFrame.toolbars.setListLinks( parent.ids.length > 1);
    }
    normalCheckedCheckbox = null;
    
    if(getTopWindow().isfromIFWE){
  	  getTopWindow().unregisterIdtoCompass();
  	}
}


function doCheckboxClick(objCheckbox, event) {
	if(getTopWindow().isfromIFWE){
       registerCheckedRowIdToCompassInTable(objCheckbox.value)
	}
    var evnt = event;
    if(!evnt){
        evnt = window.event;
    }
    if (objCheckbox.checked){
        register(objCheckbox.value);

        if(evnt && evnt.shiftKey){
            doCheckCheckboxes(objCheckbox, true)
        }else{
            doCheckCheckboxes(objCheckbox, false)
        }
    }else{
        unregister(objCheckbox.value);
    }
}

/**
* Puts the check mark to the checkboxes and registers it
* @param User selected checkbox
* @param shiftDown Boolean value indicating whether shift key is down or not
*/
function doCheckCheckboxes(objCheckbox, shiftDown){
    var checkboxList = getAllTableCheckboxes("emxTableForm");
    var checkboxLength = checkboxList.length;
    for(var i=0; i < checkboxLength; i++){
        if(checkboxList[i].value == objCheckbox.value){
            if(shiftDown){
                shiftCheckedCheckbox = i;

                if(normalCheckedCheckbox){
                    //Takes care of reverse shift clicking
                    if(normalCheckedCheckbox > shiftCheckedCheckbox){
                        var tempChecked = shiftCheckedCheckbox;
                        shiftCheckedCheckbox = normalCheckedCheckbox;
                        normalCheckedCheckbox = tempChecked;
                    }

                    // Actual checking happens here
                    for(var ckLen = normalCheckedCheckbox; ckLen < shiftCheckedCheckbox; ckLen++){
                        if(checkboxList[ckLen] && checkboxList[ckLen].type == "checkbox"){
                            checkboxList[ckLen].checked = true;
                            register(checkboxList[ckLen].value);
                        }
                    }
                }
                normalCheckedCheckbox = shiftCheckedCheckbox;
            }else{
                normalCheckedCheckbox = i;
                shiftCheckedCheckbox = null;
            }
        }
    }
}

/**
* Returns an array of all the checkboxes given the form name.
* @param formName Form name to find the checkboxes in it
*/
function getAllTableCheckboxes(formName){
    var checkboxList = document.getElementsByTagName("input");
    var checkboxLength = checkboxList.length;
    var checkboxes = new Array();

    for(var i = 0; i < checkboxLength; i++){
        if(checkboxList[i].type == "checkbox")
            checkboxes.push(checkboxList[i]);
    }
    return checkboxes;
}

function doRadioButtonClick(objCheckbox) {
	if(getTopWindow().isfromIFWE){
    registerCheckedRowIdToCompassInTable(objCheckbox.value)
	}
    parent.ids = "~";
    register(objCheckbox.value);
}

function doCheckUpdate() {

    var objForm = document.forms["emxTableForm"];
	if(!objForm){
		objForm = document.forms['frmFormView'];
	}
    if (objForm.emxTableRowId)
    {
        if (objForm.emxTableRowId[0])
        {
            if (parent.ids)
                for (var i = 0; i < objForm.emxTableRowId.length; i++)
                    if (parent.ids.indexOf("~" + objForm.emxTableRowId[i].value + "~") > -1){
                        objForm.emxTableRowId[i].checked = true;
                    }else{
                        objForm.emxTableRowId[i].checked = false;
                    }
        } else {

            if (parent.ids)
                if (parent.ids.indexOf("~" + objForm.emxTableRowId.value + "~") > -1){
                    objForm.emxTableRowId.checked = true;
                }else{
                    objForm.emxTableRowId.checked = false;
                }
        }
    }
    if(objForm.chkList) {
        objForm.chkList.checked = false;
    }

}


function doCheck(formname, headercheckBox, tableCheckbox)
{
    if(headercheckBox == 'undefined' || headercheckBox == '' || headercheckBox == null) {
      headercheckBox = 'chkList';
    }

    if(tableCheckbox == 'undefined' || tableCheckbox == '' || tableCheckbox == null) {
      tableCheckbox = 'emxTableRowId';
    }

    if(formname == 'undefined' || formname == '' || formname == null) {
      formname = 'emxTableForm';
    }

    var objForm = document.forms[formname];
	if(!objForm){
		objForm = document.forms['frmFormView'];
		formname = 'frmFormView';
	}

    if (eval('objForm.' + tableCheckbox))
    {
        if (eval('objForm.' + tableCheckbox + '[0]'))
        {
        	 if(getTopWindow().isfromIFWE){
        		 var lastCheckedRow = eval('objForm.' + tableCheckbox + '.length') - 1;
        		 var strList = eval('objForm.' + tableCheckbox + '[lastCheckedRow].checked');
        		 registerCheckedRowIdToCompassInTable(strList);
        		 
        	}
            for (var i = 0; i < eval('objForm.' + tableCheckbox + '.length'); i++)
            {
                eval('objForm.' + tableCheckbox + '[i].checked = document.' + formname + '.' + headercheckBox + '.checked');
                var strID = eval('objForm.' + tableCheckbox + '[i].value');

                if (eval('objForm.' + tableCheckbox + '[i].checked'))
                {
                    register(strID);
                }
                else
                {
                   if  (objForm.emxTableRowId[i].type != 'hidden')
                    {
                      unregister(strID);
                    }
                }
            }
        } else {
            eval('objForm.' + tableCheckbox + '.checked = document.' + formname + '.' + headercheckBox + '.checked');
            var strID = eval('objForm.' + tableCheckbox + '.value');

            if (eval('objForm.' + tableCheckbox + '.checked'))
            {
                register(strID);
            }
            else
            {
                unregister(strID);
            }
        }
    }
}


// Methods used for Table Auto Filter
function doFilterCheckboxClick(objFilterCheckbox, columnName)
{

    var objForm = document.forms["emxAutoFilterForm"];
    var filterItemCheckboxObject = objForm.elements[columnName];

    if (objFilterCheckbox.checked == false && filterItemCheckboxObject)
    {
        // Un check all the filter values for this item
        if (filterItemCheckboxObject.length == null || (filterItemCheckboxObject.length == "undefined"))
        {
            if (filterItemCheckboxObject.checked == true)
            {
                filterItemCheckboxObject.checked = false;
            }
        }
        else
        {
            for (var i = 0; i < filterItemCheckboxObject.length; i++)
            {
                if (filterItemCheckboxObject[i].checked == true)
                {
                    filterItemCheckboxObject[i].checked = false;
                }
            }
        }

    }
    else if (filterItemCheckboxObject)
    {

    if (filterItemCheckboxObject.length == null || (filterItemCheckboxObject.length == "undefined"))
    {
         filterItemCheckboxObject.checked = true;
    }
    else
    {
         for (var i = 0; i < filterItemCheckboxObject.length; i++)
         {
        filterItemCheckboxObject[i].checked = true;
         }
    }
     }
}



function doFilterItemCheckboxClick(objFilterItemCheckbox)
{

    var objForm = document.forms["emxAutoFilterForm"];
    var filterHeaderCheckboxObject = objForm.elements[objFilterItemCheckbox.name + 'Filter'];

    var filterCheckboxObject = objForm.elements[objFilterItemCheckbox.name];
    var checkHeader=0;

    if (objFilterItemCheckbox.checked ==false)
    {
        filterHeaderCheckboxObject.checked =false ;
    }
    else
    {
        if (filterCheckboxObject.length == null || (filterCheckboxObject.length == "undefined"))
        {
            filterHeaderCheckboxObject.checked = true;
        }
        else
        {
            for (var i = 0; i < filterCheckboxObject.length; i++)
            {
                if (filterCheckboxObject[i].checked == true)
                {
                	checkHeader += 1;
                }
            }

            if (checkHeader == filterCheckboxObject.length)
        {
             filterHeaderCheckboxObject.checked = true;
        }

        else
        {
              filterHeaderCheckboxObject.checked = false;

        }
        }

    }
}


function filterTable()
{
    var pageUrl = "emxTableAutoFilterController.jsp";
    document.emxAutoFilterForm.action = pageUrl;
    document.emxAutoFilterForm.target = "pagehidden";
    document.emxAutoFilterForm.submit();
}

function filterStructureBrowser()
{
    document.emxAutoFilterForm.action = "emxFreezePaneAutoFilterController.jsp";
    document.emxAutoFilterForm.target = "pagehidden";
    document.emxAutoFilterForm.submit();
}

function resetFilters()
{
    var objForm = document.forms["emxAutoFilterForm"];

    for (var i = 0; i < objForm.elements.length; i++)
        if ( objForm.elements[i].type == "checkbox" && objForm.elements[i].checked == true)
            objForm.elements[i].checked = false;
}


function refreshTableBody()
{
    // Verify the table page, if the user has already checked/selected some items.
	var dpf = document.getElementById("divPageFoot");
    if (this.ids)
    {
        if(confirm("Refreshing the table data will reset all previous selections. Click OK to continue"))
        {
            this.ids = null;
            listDisplay.location.href=listDisplay.location.href;
            //listFoot.location.href=listFoot.location.href;
        	dpf.innerHTML = emxUICore.getData(footerurl);
            var toolBarFrame;
            if (parent.frames){
                toolBarFrame = parent;
            }
            toolBarFrame = this;
            if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
                var setLink = false;
                if(this.ids!=null){
                    setLink = true;
                }
                toolBarFrame.toolbars.setListLinks(setLink);
            }
        }

    } else {
            listDisplay.location.href=listDisplay.location.href;
            //listFoot.location.href=listFoot.location.href;
        	dpf.innerHTML = emxUICore.getData(footerurl);
    }

}


//check to see if all objects are selected
function doSelectAllCheck()
{
    var objForm = document.forms["emxTableForm"];

	if(!objForm){
		objForm = document.forms['frmFormView'];
	}
    var checkAll = true;

    /*
    For structure browser pagination issue added an extra emxTableRowIdActual HTML field.
    So need to modified this method to verify checkbox selection
    */
    if (objForm.emxTableRowIdActual)
    {
        if (objForm.emxTableRowIdActual[0])
        {
            for (var i = 0; i < objForm.emxTableRowIdActual.length; i++)
            {
                if(!objForm.emxTableRowIdActual[i].checked)
                {
                  checkAll=false;
                  break;
                }
            }
        } else {

                if(!objForm.emxTableRowIdActual.checked)
                 {
                    checkAll=false;
                 }
        }

        if(objForm.chkList) {
            objForm.chkList.checked=checkAll;
        }
    }
    else if (objForm.emxTableRowId)
    {
        if (objForm.emxTableRowId[0])
        {
            for (var i = 0; i < objForm.emxTableRowId.length; i++)
            {
                if(!objForm.emxTableRowId[i].checked)
                {
                  checkAll=false;
                  break;
                }
            }
        } else {

                if(!objForm.emxTableRowId.checked)
                 {
                    checkAll=false;
                 }
        }

        if(objForm.chkList) {
            objForm.chkList.checked=checkAll;
        }
    }
}



var tempIds = "~";
var finalIds = "";

function unregisterID(strID) {


    var listFrame;
    var toolbarFrame;
    var listFrameForm;

    if (parent.frames){
        listFrame = findFrame(parent, "listDisplay");
        toolbarFrame = parent;
    }

    listFrameForm = listFrame.document.forms[0];

    if(finalIds == "") {
        for(var i=1; i<listFrameForm.elements.length; i++) {
            if(listFrameForm.elements[i].type=="checkbox" && listFrameForm.elements[i].checked=="false") {
                tempIds +=listFrameForm.elements[i].value+"~";
            }
        }
        finalIds = tempIds;
    }

    var strTemp = tempIds;
    if ( strTemp.indexOf("~" + strID + "~") > -1) {
            strTemp = strTemp.replace(strID + "~", "");
            finalIds = strTemp;
    }
    toolBarFrame = parent;
    if (toolbarFrame && toolbarFrame.toolbars && toolbarFrame.toolbars.setListLinks) {
            toolbarFrame.toolbars.setListLinks( strTemp.length > 1);
    }

}


function doCheckboxSelect(formname, headercheckBox, tableCheckbox)
{

    if(headercheckBox == 'undefined' || headercheckBox == '' || headercheckBox == null) {
      headercheckBox = 'chkList';
    }

    if(tableCheckbox == 'undefined' || tableCheckbox == '' || tableCheckbox == null) {
      tableCheckbox = 'emxTableRowId';
    }

    if(formname == 'undefined' || formname == '' || formname == null) {
      formname = 'emxTableForm';
    }

    var objForm = document.forms[formname];

	if(!objForm){
		objForm = document.forms['frmFormView'];
		formname = 'frmFormView';
	}
    var strID ;
    for(i=1; i<objForm.elements.length; i++ )
    {
      if(objForm.elements[i].name==tableCheckbox && objForm.elements[i].type=="checkbox") {

          strID = objForm.elements[i].value;

          if(objForm.elements[i].checked) {
                 register(strID);
                break;
          }
          else {
            unregisterID(strID);
          }
      }
    }

     var operand = "";
     var bChecked = false, allSelected = true;
     var typeStr = "";
     var count = eval("document." + formname + ".elements.length");

     for(var i = 1; i < count; i++)  //exclude the checkAll checkbox
     {
        typeStr = eval("document." + formname + ".elements[" + i + "].type");
        if(typeStr == "checkbox")
        {
                bChecked = eval("document." + formname + ".elements[" + i + "].checked");
                if(bChecked == false)
                {
                      allSelected = false;
                      break;
                }
            }
     }


     operand = "document." + formname + ".elements[0].checked = " + allSelected + ";";
     eval (operand);
}


function doCheckbox(){
    if(document.forms.length>0){
        var objForm = document.forms[0];
        var objFormName = document.forms[0].name;
        var headercheckBox = null;
        var tableCheckbox = null;


        for (var i = 0; i < document.forms[0].elements.length; i++ )
        {

          if(document.forms[0].elements[i].type == "checkbox"){
              if(headercheckBox == null){
                   headercheckBox = document.forms[0].elements[i].name;
              }else{
                   tableCheckbox = document.forms[0].elements[i].name;
                   break;
              }

         }
        }

        for (var i = 0; i < document.forms[0].elements.length; i++ )
        {
              if(document.forms[0].elements[i].type == "checkbox" && document.forms[0].elements[i].name == headercheckBox){
                  cbElement = document.forms[0].elements[i];
                  var fnconclick = " " + cbElement.getAttribute("onclick");
                  if(!cbElement.onclick || fnconclick.indexOf("doCheck()") >= 0 ) {
                    cbElement.onclick = function(){doCheck(objFormName, headercheckBox, tableCheckbox)};
                  }
              } else if(document.forms[0].elements[i].type == "checkbox"){
                  cbElement = document.forms[0].elements[i];
                  if(!cbElement.onclick)
                    cbElement.onclick = function(){doCheckboxClick(this)};
              }
        }
    }

}
//Added for User Defined Table feature
function changeImage(response,timeStamp,uiType,objectId)
{
    var obj = null;
    var objTemp ;
    if(objContextToolbar!= null && objContextToolbar!="undefined")
    {
    for(var i = 0; i < objContextToolbar.items.length ; i++){
        var iurl = objContextToolbar.items[i].text;
        var id = objContextToolbar.items[i].id;
        if(iurl && id == "customTableSplitButton")
        {
            obj = objContextToolbar.items[i];
            break;
        }
    }
    }
    if(obj)
    {
         if(obj.element == null || obj.element=="undefined")
        {
             objTemp = obj.buttonElement;
        }
        else
        {
            objTemp = obj.element;
        }
        strText = objTemp.innerHTML;
        var system = "systemTable";
        var user = "userTable";
        var derived = "derivedTable";

        var regA = /\n\r/g;
        var resp = response.replace(regA,"");

        var sMatch = resp.match(user);
        if(sMatch==null)
            sMatch= resp.match(system);

        if(sMatch==null)
            sMatch= resp.match(derived);

        if(sMatch == "systemTable")
        {
            var regAt = /\/[a-z]*.gif/i;
            strText = strText.replace(regAt,"/iconActionSystemColumns.gif");
            objTemp.innerHTML = strText;
            objTemp.title =emxUIConstants.STR_CUSTOMIZE;
             obj.url = "javascript:showModalDialog('../common/emxCustomizeTablePopup.jsp?objectId="+objectId+"&uiType="+uiType+"&timeStamp="+timeStamp+"','750','658','true')";
        }

        if(sMatch == "derivedTable")
        {
            var regAt = /\/[a-z]*.gif/i;
            strText = strText.replace(regAt,"/iconActionSystemColumns.gif");
            objTemp.innerHTML = strText;
            objTemp.title =emxUIConstants.STR_SHOW_CUSTOM_COLUMNS;
            var temp = null;
            if (uiType == "structureBrowser") {
				var derivedTableNames = emxUICore.selectSingleNode(oXML, "/mxRoot/tableControlMap/setting[@name = 'derivedTables']");
				if (derivedTableNames) {
					var tableName = emxUICore.getText(derivedTableNames).split(",")[0];
					temp = "javascript:void(refreshSBTable('" + tableName + "','','','true','1434648059313','structureBrowser'))@";
				}
			} else {
				temp=emxUICore.getData("emxCustomTableUtility.jsp?mode=toggle&timeStamp="+timeStamp+"&uiType="+uiType+"").toString();
			}

             temp=temp.substring(0,temp.indexOf('@'));
             obj.url =temp;


        }
        if(sMatch == "userTable")
        {
            var regAt = /\/[a-z]*.gif/i;
            // Replace the image name
            strText = strText.replace(regAt,"/iconActionCustomColumns.gif");
            objTemp.innerHTML = strText;
            //alert(strText);
            objTemp.title =emxUIConstants.STR_SHOW_SYSTEM_COLUMNS;
            var temp = null;
            if (uiType == "structureBrowser") {
				var tableName = getTableNameFromXML().split("~")[1];
				temp = "javascript:void(refreshSBTable('" + tableName + "','','','true','1434648059313','structureBrowser'))@";
			} else {
				temp=emxUICore.getData("emxCustomTableUtility.jsp?mode=toggle&timeStamp="+timeStamp+"&uiType="+uiType+"").toString();
			}
             temp=temp.substring(0,temp.indexOf('@'));
             obj.url =temp;

        }

     }
}


 function showIcon(timeStamp,uiType,objectId,isStructureCompare)
 {
	var respText = null;
	if (uiType == "structureBrowser") {
		if (oXML == null) {
			return;
		}
		var userTableSetting = getRequestSetting("userTable");
		var isUserTable = "false";
		if (userTableSetting) {
			isUserTable = emxUICore.getText(userTableSetting);
		}
		if (isUserTable == "true") {
			respText = "userTable";
		} else {
			var derivedTableNames = emxUICore.selectSingleNode(oXML, "/mxRoot/tableControlMap/setting[@name = 'derivedTables']/text()")
			if (derivedTableNames) {
				respText = "derivedTable";
			} else {
				respText = "systemTable";
			}
		}
	} else {
		 respText = emxUICore.getData("emxCustomTableUtility.jsp?mode=alt&uiType="+uiType+"&timeStamp="+timeStamp+"&IsStructureCompare="+isStructureCompare);
	}
     changeImage(respText,timeStamp,uiType,objectId);
 }
 //User Defined Table feature addition ends
//Added for RMB START
//This method  will attach RMB attribute to the Table body
 function attachRMBAttribute(tableid){

	 /*	modified for IR-040214V6R2011 */
     // var shwRMB = document.location.search.match("showRMB=false");
     // if (shwRMB == null || shwRMB == "")
	 var shwRMB = document.getElementById('showRMB');
	 if(shwRMB != null) {
		 shwRMB = shwRMB.value;
	 }
	 if (shwRMB !== "false")
	 {
		 if(tableid){
			 var objTable = document.getElementById(tableid);
			 var rmbCheck = objTable.getAttribute("showRMB");
			 //RMB Should be enabled by default
			 if(rmbCheck != "false")
			 {
				 var objTD = objTable.getElementsByTagName('tbody');
				 for (i in objTD)
				 {
					 emxUICore.addEventHandler(objTD[i], "contextmenu", clickRight);
				 }
			 }
		 }
	 }
}
//This Function is called on the Right Click of table/SB cell
function clickRight(evt, appendRMBMenu, node)
{
	/* modified for IR-040214V6R2011 */
	// var shwRMB =     document.location.search.match("showRMB=false");
	// if (shwRMB == null || shwRMB == "")
	var tableRowId;
	var shwRMB = document.getElementById('showRMB');
	if(shwRMB != null) {
		shwRMB = shwRMB.value;
	}
	if (shwRMB !== "false")
	{
		var oEvent = {
				clientX:emxUICore.getEvent().clientX,
				clientY:emxUICore.getEvent().clientY,
				target:emxUICore.getEvent().target
		};
		var rmbSetting = "";
		var rmbID      = "";
		//Added for Bug : 353307
		var rmbrow     = "";
		var rmbRelID   = "";
		var targetTagName = oEvent.target.tagName.toLowerCase();
		if(typeof emxUIRTE != "undefined" && emxUIRTE.RTE_TAGS.find(targetTagName) != -1){
	    	do{
	    		oEvent.target = oEvent.target.parentNode;
	  	  targetTagName = oEvent.target.tagName.toLowerCase();
	    	}while(targetTagName != "td");
		}
		var parentTD;
		var aloid;
		aloid   = oEvent.target.getAttribute("aloid");

		/*
		 * On Flat Tables, show RMB menu only for
		 * anchor tag or image right click
		 */
		createRequestObject();
		try {
			var tmpUIType = uiType;
		} catch(e) {
			tmpUIType = FORM_DATA['uiType'];
		}
		if (tmpUIType == "table" && !(targetTagName == "a" || targetTagName == 'img')) {
			return true;
		}

		if (targetTagName == "td" && aloid != "true" || oEvent.target.getAttribute("rmbid") != null)
		{
			parentTD  = oEvent.target;
		}
		else
		{
			parentTD  = oEvent.target.parentNode;
		}
		if(! (parentTD.hasAttribute("rmb") || parentTD.hasAttribute("rmbid"))){
			parentTD = jQuery(parentTD).parents("td[rmbid]")[0];
		}
		if(targetTagName == 'img' && aloid != "true" && !node)
		{
			var parentA  = oEvent.target.parentNode;
			if(parentA.tagName.toLowerCase() == 'a')
			{
				parentTD = parentA.parentNode;
			}
			else if(tmpUIType != "structureBrowser")
			{
				return true;
			}
		}

		//IR-110229V6R2012x
		var offsetParentElement = null;
		try {
				if(targetTagName == 'img'){
					offsetParentElement = oEvent.target.offsetParent.offsetParent.offsetParent;
				}else{
					offsetParentElement = oEvent.target.offsetParent.offsetParent;
				}			
				if(offsetParentElement.offsetParent.id == "treeBodyTable") {
					parentTD = offsetParentElement;
				}				
			} catch(e) {
				// do Nothing
			}
			//end

		if(aloid == "true"){
			parentTD = oEvent.target;
		}

		if (parentTD != null && parentTD != 'undefined')
		{
			
			rmbID      = parentTD.getAttribute("rmbID");
			if(!rmbID && isIE){
				for(var i = 0; i < parentTD.parentNode.childNodes.length; i++){
					if(parentTD.parentNode.childNodes[i].nodeType == 1){
						if(parentTD.parentNode.childNodes[i].getAttribute("rmbid")){
							parentTD = parentTD.parentNode.childNodes[i];
							rmbID = parentTD.getAttribute("rmbid");
							break;
						}
					}
				}
			}
			rmbSetting =  parentTD.getAttribute("rmb");
			if (rmbID == null  && node != null) {
			    rmbID = node.data.data.getAttribute("o");
			}

			rmbRelID   = parentTD.getAttribute("rmbRelID");
			rmbrow     = parentTD.getAttribute("rmbrow");
			if (rmbrow == null && node != null) {
			    rmbrow = node.data.data.getAttribute("id");
			}
			var rmbrowid = rmbrow;

			if(rmbrow == null || rmbrow == ""){
				rmbrow = parentTD.parentNode.getAttribute("rmbrow");
			}
			//check if have atleast read access on the row ; 'ra' == Read Access
			if(rmbrow){
				var a = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id ='"+rmbrow+"']");
				var rowReadAccess = a.getAttribute("ra");
				if(rowReadAccess == 'f'){
					return true;
				}
			}
			if (rmbID == "" || rmbID == null)
			{
				return true;
			}
		}
		if(aloid == "true" && rmbID != null){
			tableRowId = rmbID;
		}
		else{
			//Structure Browser timeStamp/uiType
			var tempTimeStamp ;
			var tempUIType ;
			tableRowId = rmbID;
			try
			{
				tempTimeStamp = timeStamp;
				tempUIType = uiType;

				rmbrow = document.getElementById("rmbrow-"+rmbrow);
				if(rmbrow != null && rmbrow.value != "") {
					tableRowId = rmbrow.value;
				}
				else {
					tableRowId = "";
					var rid = parentTD.getAttribute("r");
					if (rid) {
						tableRowId = rid;
					}
					tableRowId += "|" + rmbID;
					var parentRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + parentTD.getAttribute("id") + "']/..");
					if (parentRow) {
						tableRowId += "|" + parentRow.getAttribute("o") + "|";
					} else {
						tableRowId += "||";
					}
					tableRowId += rmbrowid;
				}
			}
			catch(e)
			{
				//do nothing
			}
			//Table timeStamp/uiType
			if (tempTimeStamp == null || tempTimeStamp == 'undefined')
			{
				tempTimeStamp=FORM_DATA['timeStamp'];
				tempUIType=FORM_DATA['uiType'];

				if(rmbRelID != null && rmbRelID != "" && rmbRelID != "null"){
					tableRowId = rmbRelID + "|" + rmbID;
				}
			}
			var tempRootOid = "";
			if(tempUIType == "structureBrowser" && FORM_DATA['objectId']){
				rmbID=FORM_DATA['objectId'];
			}
		}
		
		var appendRMBParam = "";
		if (typeof editableTable!=="undefined") {
			appendRMBParam = "&currentView=" + displayView;
			if (displayView == "details" || displayView == "detail") { appendRMBParam += "&sbMode=" + editableTable.mode; }
		}
		
		var rmbdataURL = "emxUIDynamicMenu.jsp?RMBMenu="+rmbSetting+"&frmRMB=true&objectId="+rmbID+"&uiType="+tempUIType+"&timeStamp="+tempTimeStamp+"&rmbTableRowId="+tableRowId + appendRMBParam;
		
		if(parent.FullSearch){
			rmbdataURL = rmbdataURL + "&isFullSearch=true";
		}
		if(tempUIType == "structureBrowser" && isStructureCompare != ""){
			rmbdataURL = rmbdataURL + "&IsStructureCompare="+isStructureCompare;
		}
		if (appendRMBMenu && appendRMBMenu.length > 0) {
			rmbdataURL = rmbdataURL + "&appendRMBMenu=" + appendRMBMenu;
		}
		
		// below code add the column name into FORM_DATA when RMB clicked
		if(displayView == "detail"){
			var currentRMBColumnName = updateColumnDetailsInRequestObject(parentTD);
			
			if (currentRMBColumnName && currentRMBColumnName.length > 0) {
				rmbdataURL = rmbdataURL + "&currentRMBColumnName=" + currentRMBColumnName;
			}		
		}
		
		var rmbdata = emxUICore.getData(rmbdataURL);
		rmbdata = emxUICore.trim(rmbdata);
		eval(rmbdata);
		if(typeof objMenu != "undefined" && objMenu != null)
		{
			objMenu.isRMBMenu = true;
			objMenu.isRMB = "true";
			objMenu.init();
			objMenu.show(oEvent.target, 'right',oEvent.clientX,	oEvent.clientY);
			emxUICore.getEvent().preventDefault();
			emxUICore.getEvent().stopPropagation();
		}
		else
		{
			document.location.href="../emxLogout.jsp";
		}
	}
	return false;
}

//---------- below code add the column name into FORM_DATA when RMB clicked
function updateColumnDetailsInRequestObject(node){
	let columnPosition = getColumnPosition(node);
	if(columnPosition){
		let colMapData = colMap.getColumnByIndex(columnPosition-1);
		if(colMapData && colMapData.name){
				return colMapData.name;
		}
	}
	return "";
}
function getColumnPosition(node){
	if(!node){
		return "";
	}
	if(node && node.hasAttribute("position")){
		return node.getAttribute("position");
	}
	else{
		return  getColumnPosition(node.parentNode);
	}	
	return "";
}
//------------

//Added for power view highlightRow
 function attachTDAttribute(tableid){
	if(tableid){
		var objTable = document.getElementById(tableid);
        var rmbCheck = objTable.getAttribute("showRMB");
        //RMB Should be enabled by default
        if(rmbCheck != "false")
        {
            var objTR = objTable.getElementsByTagName('tr');
            for (j in objTR)
            {
                emxUICore.addEventHandler(objTR[j], "mouseup", highlightRow);
            }
        }
    }
}

function highlightRow(){
    var targetTagName = emxUICore.getEvent().target.tagName.toLowerCase();
    var target = emxUICore.getEvent().target;
    if (targetTagName == "a")
    {
        var href = emxUICore.getEvent().target.getAttribute("href");
        var parentTR;
        if(target.parentNode && target.parentNode.parentNode){
            parentTR = target.parentNode.parentNode;
        }
        if(parentTR == null){
            return true;
        }
        var isSB = false;
        var reg1 = new RegExp("(javascript:link\\(\\\")(\\d)","i");
        if(reg1.test(href)){
            var colNum = parseInt(RegExp["$2"]);
            var theColumn = colMap.getColumnByIndex(colNum-1);
            href = theColumn.getAttribute("href");
            isSB = true;
        }
        if(href.indexOf("emxRefreshChannel.jsp") > -1){
            if (isSB) {
                var oldRow = emxUICore.selectSingleNode(oXML.documentElement,"/mxRoot/rows//r[@powerView='true']");
				if(oldRow != null)
				{
					var arrChildCells = emxUICore.selectNodes(oldRow,"./c");
					for(var idx = 0; idx< arrChildCells.length; idx++) {
						var styleCell = arrChildCells[idx].getAttribute("styleCell");
						if(styleCell.indexOf(" corresponding") > -1){
							styleCell = styleCell.replace(" corresponding","");
						}else if(styleCell == "corresponding"){
							styleCell = "";
						}
						arrChildCells[idx].setAttribute("styleCell",styleCell);
					}
					oldRow.removeAttribute("powerView");
				}
                //var rowId = this.getAttribute("id");
				var rowId = parentTR.getAttribute("id");
				var nSelectedRow = emxUICore.selectSingleNode(oXML.documentElement,"/mxRoot/rows//r[@id='"+rowId+"']");
				nSelectedRow.setAttribute("powerView","true");
				var arrCells = emxUICore.selectNodes(nSelectedRow,"./c");
				for(var ix = 0; ix< arrCells.length; ix++){
					var styleCell = arrCells[ix].getAttribute("styleCell");
					var theColumn = colMap.getColumnByIndex(ix);
					var editable  = theColumn.getSetting("Input Type") != null && theColumn.getSetting("Editable") == "true" && arrCells[ix].getAttribute("editMask") == null;
					if(styleCell != null && styleCell != ""){
						styleCell += " corresponding";
					}else{
						styleCell = "corresponding";
					}
					styleCell = editable ? "mx_editable " + styleCell : styleCell;

					arrCells[ix].setAttribute("styleCell",styleCell);
				}
            } else {
                var objTable = document.getElementsByTagName('table');
                for (var i = 0; i< objTable.length; i++)
                {
                    var objTR = objTable[i].getElementsByTagName('tr');
                    for (j in objTR)
                    {
                        var strClassName = objTR[j].className;
                        if(strClassName){
                            objTR[j].className = strClassName.replace(" corresponding","");
                        }
                    }
                }
                if(parentTR.offsetParent){
                    parentTR = parentTR.offsetParent;
                }
                if(parentTR.parentNode && parentTR.parentNode.parentNode){
                    parentTR = parentTR.parentNode.parentNode;
                }
                parentTR.className = parentTR.className + " corresponding";
            }
            emxUICore.getEvent().preventDefault();
            emxUICore.getEvent().stopPropagation();
        }
    }else{
        return true;
    }
    return false;
}

//The method is used to Download files,used in AEFDefaultRMB menus
function downloadFile(objectId, action, fileName, format, refresh, closeWindow, appName, appDir, partId, version,SB,customSortColumns, customSortDirections,uiType, table,getCheckoutMapFromSession ,fromDataSessionKey,parentOID)
{
	// This will invoke the callCheckout() from emxUICore.js
	callCheckout(objectId, action, fileName, format, refresh, closeWindow, appName, appDir, partId, version,SB,customSortColumns, customSortDirections,uiType, table,getCheckoutMapFromSession ,fromDataSessionKey,parentOID);
}
//This a Void function used in href for "No Items Found" command
function showLabel()
{
    return false;
}

// CallBack function for Clipboard collection
function callbackFunctionCollection(args)
{
    try
    {
        var array = args.getOids();
        var action = args.getAction();
        var tableRowID = new Array();
        for(var i=0;i<array.length;i++)
        {
            tableRowID[i] = array[i];
        }
        var url = "../common/emxCollectionsAddToProcess.jsp?mode=Consolidated&action="+action;

        if(document.getElementById("emxTableRowId"))
        {
            document.getElementById("emxTableRowId").value=tableRowID;
        }
        else
        {
            var obj = document.createElement("input");
            obj.setAttribute("type","hidden");
            obj.setAttribute("name","emxTableRowId");
            obj.setAttribute("id","emxTableRowId");
            obj.setAttribute("value",tableRowID);
            document.forms[0].appendChild(obj);
        }
        document.forms[0].action = url;
        document.forms[0].method = "post";
        document.forms[0].target = "listHidden";
        document.forms[0].submit();
        if(getTopWindow().refreshTablePage && action=="done")
        {
            getTopWindow().refreshTablePage();
        }
    }
    catch(e)
    {
        alert(e.message);
        return -1;
    }
    return 0;
}
//Method parses the document.location.search
//and add the key - value pair in an Array
function createRequestObject() {
  FORM_DATA = new Object();
  var separator = ',';
  //Previously 'this.location' used to point to table header url,
  //which had timeStamp and UIType information
  //With 2012, we store these information in footerurl,
  //so using footerurl in place of location href.
  //query = '' + this.location;
  if(this.footerurl && this.footerurl!=""){
	  query = '' + this.footerurl;
  }else{
	  query = '' + this.location;
  }
  query = query.substring((query.indexOf('?')) + 1);
  if (query.length < 1) { return false; }
  keypairs = new Object();
  numKP = 1;
  while (query.indexOf('&') > -1)
   {
    keypairs[numKP] = query.substring(0,query.indexOf('&'));
    query = query.substring((query.indexOf('&')) + 1);
    numKP++;
  }
  keypairs[numKP] = query;
  for (i in keypairs)
  {
    keyName = keypairs[i].substring(0,keypairs[i].indexOf('='));
    keyValue = keypairs[i].substring((keypairs[i].indexOf('=')) + 1);
    while (keyValue.indexOf('+') > -1)
    {
      keyValue = keyValue.substring(0,keyValue.indexOf('+')) + ' ' + keyValue.substring(keyValue.indexOf('+') + 1);
    }
    keyValue = unescape(keyValue);
    //IR-139034V6R2013
    if (FORM_DATA[keyName] && keyName == "emxTableRowId")
    {
        FORM_DATA[keyName] = FORM_DATA[keyName] + separator + keyValue;
    }
    else if(!FORM_DATA[keyName])
    {
        FORM_DATA[keyName] = keyValue;
    }
  }
  return FORM_DATA;
}

function refreshTableData()
{
	var dpf = document.getElementById("divPageFoot");
	this.ids = null;
    listDisplay.location.href=listDisplay.location.href;
    //listFoot.location.href=listFoot.location.href;
    dpf.innerHTML = emxUICore.getData(footerurl);

    var toolBarFrame;
    if (parent.frames){
        toolBarFrame = parent;
    }else {
    	toolBarFrame = this;
    }
    parent.ids = "~";

    if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
        toolBarFrame.toolbars.setListLinks(false);
    }
}
//This method is used to change te color of the TD according to the Result of Trigger Validation

function changeColor(result,i)
{
    var obj = document.getElementById("error"+i);
    var parentObj = obj.parentNode;
    if(result=="Pass")
    {
        parentObj.style.background = "#008080";
    }
    else if(result=="Fail")
    {
        parentObj.style.background = "#8B0000";
    }
    if(result=="Warning")
    {
        parentObj.style.background = "#FFFF00";
    }
}

function isRowSelected(uiType) {
	return uiType === "table" ? (this.ids && this.ids.length > 1) : (isAnyRowSelectedInSB(this.oXML) && parent.ids && parent.ids.length > 1) ;
}
function appendQueryString(){
	var URL = getTopWindow().location.href;
	var loadPage = URL.substring(URL.indexOf("loadPage=")+9);
	loadPage = loadPage.split("&", 1);
	getTopWindow().location.href = decodeURIComponent(loadPage[0]) + URL.substring(URL.indexOf("?"));
}
function resetTableParameter(parm, val,urlParameters){
    if(urlParameters.indexOf("amp;") >= 0){
           while(urlParameters.indexOf("amp;") >= 0){
               urlParameters = urlParameters.replace("amp;", "");
           }
       }

   var arrURLparms = urlParameters.split("&");
   var len = arrURLparms.length;
   var count = 0;
   for(var i = 0; i < len; i++){
       arrURLparms[i] = arrURLparms[i].split("=");
       //only change the first matching parm
       if(arrURLparms[i][0] == parm && count == 0){
           count++;
           //set new value
           arrURLparms[i][1] = val;
       }
       arrURLparms[i] = arrURLparms[i].join("=");
   }
   urlParameters = arrURLparms.join("&");
   //if the count is still zero add param to end
   if(count == 0){
       urlParameters += ("&" + parm + "=" + val);
   }
   return urlParameters;
}

function closeAutoFilterSlideIn(targetLocation){
	if(targetLocation != "slidein"){
		var leftSlideInDiv = jQuery('div#leftSlideIn', getTopWindow().document);
		if(leftSlideInDiv.length && leftSlideInDiv.is(':visible')){
			getTopWindow().closeSlideInDialog();
		}
	}
	
}

function loadDelegatedUIAddExistsChangeRequest(){
	if(top.window.loadDelegatedUIChangeRequest){
		top.window.loadDelegatedUIChangeRequest();
	}
}


