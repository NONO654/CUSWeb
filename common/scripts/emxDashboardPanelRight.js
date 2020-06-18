
$(document).ready(function() {
	initPage();
	resizeTable();

	$("td.counterCell").bind("mouseenter", function() { $(this).find(".counterText").addClass("counterTextHighlight");    });
	$("td.counterCell").bind("mouseleave", function() {	$(this).find(".counterText").removeClass("counterTextHighlight"); });

});

$(window).resize(function(){
	resizeTable();
});

function resizeTable() {
	var widthLeft 			= $(window).width() - $("#middle").width() - $("#right").width() - 1;
	$("#left").width(widthLeft + "px");
	$("#details").width(widthLeft + "px");	
	$("#frameDashboard").width(widthLeft + "px");
}

function hidePanel() {

	$("#right").fadeOut('200', function() {

		$("#right").width("0px");
		$("#middle").width("20px");
		$("#middle").show();

		var widthNew = $(window).width() - 20 - 1;

		if($("#details").length != 0) {
			if($("#details").is(':visible')) {
				$("#details").width(widthNew + "px");
			} else {
				$("#left").width(widthNew + "px");
				$("#frameDashboard").width(widthNew + "px");			
			}
		} else {
			$("#left").width(widthNew + "px");
			$("#frameDashboard").width(widthNew + "px");
		}

	});
}

function showPanel() {

	var chartpanelwidth = 570;
	if(getTopWindow().isMobile == true){
		chartpanelwidth = 320;
	}
	var widthNew = $(window).width() - chartpanelwidth - 1;

	$("#middle").hide();
	$("#middle").width("0px");

	if($("#details").length != 0) {
		if($("#details").is(':visible')) {
			$("#details").width(widthNew + "px");
		} else {
			$("#left").width(widthNew + "px");
			$("#frameDashboard").width(widthNew + "px");			
		}
	} else {
		$("#left").width(widthNew + "px");
		$("#frameDashboard").width(widthNew + "px");
	}

	$("#right").width(chartpanelwidth + "px");
	$("#right").fadeIn("0");

}

// Data selection

function openURLInDetails(url) {

	if($("#left").is(':visible')) { $("#left").fadeOut("0"); }

	if($("#details").html() == "") {
		$("#details").html("<iframe id='frameDetails' style='width:" + widthDetails + "px;border:none;' src=''></iframe>");
	}
	if(!$("#details").is(':visible')) {
		var widthDetails = $(window).width() - $(middle).width() - $("#right").width() - 1;
		$("#details").width(widthDetails + "px");
		$("#details").fadeIn("100");
	}

	if($("#details").is(':visible')) {
		var frameDetails = document.getElementById("frameDetails");
		if(frameDetails != null) {
			var urlTest = 	url.replace(/\.\.\//g, "");
			urlTest = urlTest.replace(/ /g, "%20");
			if(frameDetails.src.indexOf(urlTest) == -1) {
				frameDetails.src = url;
			}
		}
	}


}

function removeFilter(idHeader, idChart, idFilter) {
	$(idFilter).fadeOut(0);
	$(idFilter).css("visibility", "hidden");
	var visible = $(idChart).is(':visible');
	if(visible == false) {
		$(idHeader).css('border-radius', '4px 4px 4px 4px');
	}
}

function restoreLeft() {
	var divLeft 		= document.getElementById("left");
	var widthLeft 		= $(window).width() - 571;
	var visibleLeft		= $("#left").is(':visible');
	if($("#details").is(':visible')) { $("#details").fadeOut("0");	}
	if(!visibleLeft) { $("#left").fadeIn("100");	}
}

function selectGlobalFilter(filterValue) {
	var url = document.location.href;
	if(url.indexOf("&filterGlobal=") != -1) { url = url.substring(0, url.indexOf("&filterGlobal=")); }
	url += "&filterGlobal=" + filterValue;
	document.location.href = url;
}
