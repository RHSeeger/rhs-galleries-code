var addthis_config = {
   data_ga_property: 'UA-23898692-1',
   data_track_clickback: true
};

$(document).ready(function() {
	$(".random a.random-gallery").click(function() {
		_gaq.push(['_trackEvent', 'Navigation', 'Random', document.location.pathname]);
		return true;
	});
});
