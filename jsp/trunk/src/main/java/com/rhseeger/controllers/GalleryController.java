package com.rhseeger.controllers;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.rhseeger.models.Gallery;
import com.rhseeger.models.Photo;
import com.rhseeger.services.GalleryManager;
 
/**
 * In this Controller, we use the annotation system to set things up
 * The GalleryManager is auto-wired
 * The topic is automatically pulled from the path by the request mapping
 * @author Robert
 *
 */
@Controller
@RequestMapping("/gallery")
public class GalleryController {
	static final private Logger logger = Logger.getLogger(GalleryController.class);
	
	@Autowired
	@Qualifier("myGalleryDAO")
	private GalleryManager galleryManager;
	
	@RequestMapping(value="/{topic}", method=RequestMethod.GET)
	public String getGallery(@PathVariable String topic, Model model) {
		if(topic == null) {
			logger.error("topic was null");
		} else {
			logger.info("topic was '" + topic + '"');
		}
		Gallery gallery = galleryManager.getGallery(topic);
		for(Photo photo : gallery.getPhotos()) {
			logger.info("Photo: " + photo.toString());
		}
		model.addAttribute("gallery", gallery);  
		return "gallery"; 
	}
}
