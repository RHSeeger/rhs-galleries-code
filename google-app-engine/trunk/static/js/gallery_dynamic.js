$(document).ready(function() {
	_gaq.push(['_trackEvent', 'Navigation', 'DynamicGallery', topic]);
	$(".photo-info").css("display", "none");
    Galleria.loadTheme('/galleria/themes/classic/galleria.classic.min.js');
    var flickr = new Galleria.Flickr("5131c21d9e0f8ac2a5c388c1f0174471");
    flickr.setOptions({
        sort: 'relevance',
        max: 20,
        description: 'true',
        backlink: 'true',
    }).search(topic, function(data) {
    	//alert(JSON.stringify(data));
        $("#gallery").galleria({
            width: 640,
            height: 490,
    		transition: 'fade',
    		data_source: data,
    		extend: function(options) {
            	Galleria.log(this) // the gallery instance
            	Galleria.log(options) // the gallery options

            	// listen to when an image is shown
            	// TODO: update this code so that it puts the correct information on the screen
            	this.bind('image', function(e) {
    				imageData = e["scope"]["_data"][e.index];
    				//alert("Image Data:\n" +  JSON.stringify(imageData));
    				$("#imagedata div.title").html('<a href="' + imageData.link + '">' + imageData.title + '</a>');
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

});

