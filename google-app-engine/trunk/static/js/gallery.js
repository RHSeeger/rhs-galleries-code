$(document).ready(function() {
	$(".photo-info").css("display", "none");
    Galleria.loadTheme('/galleria/themes/classic/galleria.classic.min.js');
    $("#gallery").galleria({
        width: 640,
        height: 490,
		data_source: image_data,
		transition: 'fade',
		//showInfo: true,
		//popupLinks: true,
		extend: function(options) {
        	Galleria.log(this) // the gallery instance
        	Galleria.log(options) // the gallery options

        	// listen to when an image is shown
        	this.bind('image', function(e) {
				imageData = e["scope"]["_data"][e.index];
				$("#imagedata div.title").html('<a href="' + imageData.linkback + '">' + imageData.title + '</a>');
				$("#imagedata span.username").html(imageData.owner);
				$("#imagedata div.description").html(imageData.description);
            	Galleria.log(e) // the event object may contain custom objects, in this case the main image
            	Galleria.log(e.index) // the current image

            	// lets make galleria open a lightbox when clicking the main image:
            	$(e.imageTarget).click(this.proxy(function() {
               		this.openLightbox();
            	}));
        	});
        	var imageChangeCount = 0;
        	this.bind(Galleria.IMAGE, function(e) {
        		imageChangeCount += 1;
        		if(imageChangeCount > 1) {
        			// Notification that the user has viewed more than the first image
        			_gaq.push(['_trackEvent', 'Navigation', 'ImageChange', document.location.pathname]);
        		}
        		if(imageChangeCount % 5 == 0) {
        			// Now, to see if we can (and are allowed to) update the google ads because we've changed images X times 
        			// ie, enough of the page has changed to consider it a new page view
        		}
        	});
    	}

    });
});

