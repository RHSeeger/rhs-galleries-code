$(document).ready(function() {
	function addTitles() {
		$("div.image").each(function(index, Element) {
			$(this).hover(
					function(eventObject) { // mouse in
						$(this).find("div.searchterm").fadeTo("slow", .8);
					}, 
					function(eventObject) { // mouse out
						$(this).find("div.searchterm").fadeOut("slow");
					}
			);
		});
	}
	addTitles();
});
