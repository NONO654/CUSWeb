function toggleChart(idHeader, idChart, chart) {
	var visibleChart	= $(idChart).is(':visible');
	if(visibleChart) {
		$(idHeader).css('border-radius', '4px 4px 4px 4px');
		$(idChart).fadeOut(160);
	} else {
		$(idHeader).css('border-radius', '4px 4px 0px 0px');
		$(idChart).fadeIn(160);
		chart.setSize($(idChart).width(),$(idChart).height(), false);
	}
	jQuery(idHeader).toggleClass("header expanded").toggleClass("header");
}

function toggleChartFilter(idHeader, idChart, chart, idFilter) {
	var visibleChart	= $(idChart).is(':visible');
	var visibleFilter 	= $(idFilter).css('visibility');
	if(visibleChart) {
		if(visibleFilter == "visible") {
			$(idFilter).css('border-bottom', '1px solid #BABABA');
			$(idHeader).css('border-radius', '4px 4px 0px 0px');
		} else {
			$(idHeader).css('border-radius', '4px 4px 4px 4px');
		}
		$(idChart).fadeOut(160);
	} else {
		$(idHeader).css('border-radius', '4px 4px 0px 0px');
		$(idChart).fadeIn(160);
		$(idFilter).css('border-bottom', 'none');
		chart.setSize($(idChart).width(),$(idChart).height(), false);
	}
}

function toggleChartInfo(idHeader, idChart, chart, idInfo) {
	var visibleChart	= $(idChart).is(':visible');
	if(visibleChart) {
		$(idChart).fadeOut(160);
		$(idInfo).css('border-top', 'none');
	} else {
		$(idChart).fadeIn(160);
		if(null != chart) {
			chart.setSize($(idChart).width(),$(idChart).height(), false);
		}
		$(idInfo).css('border-top', '1px solid #bcbcbc');
	}
	jQuery(idHeader).toggleClass("header expanded").toggleClass("header");
}
