$(document).ready(function() {
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
		$("#imagedata span.username").html(imageData.user);
		$("#imagedata div.description").html(imageData.description);
            	Galleria.log(e) // the event object may contain custom objects, in this case the main image
            	Galleria.log(e.index) // the current image
                
            	// lets make galleria open a lightbox when clicking the main image:
            	$(e.imageTarget).click(this.proxy(function() {
               	    this.openLightbox();
            	}));
            });
    	}
        
    });
});
