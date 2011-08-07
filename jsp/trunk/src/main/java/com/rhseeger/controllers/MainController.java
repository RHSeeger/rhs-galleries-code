package com.rhseeger.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import com.rhseeger.models.Gallery;
import com.rhseeger.models.TopicList;
import com.rhseeger.services.GalleryManager;
import com.rhseeger.services.TopicListManager;
 
public class MainController implements Controller {
	static final private Logger logger = Logger.getLogger(MainController.class);
	
	private TopicListManager topicListManager;
	private GalleryManager galleryManager;
	
	public void setTopicListManager(TopicListManager topicListManager) {
		this.topicListManager = topicListManager;
	}
	public void setGalleryManager(GalleryManager galleryManager) {
		this.galleryManager = galleryManager;
	}
	
	public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<String> topics = topicListManager.getTopicList("google").getTopics();
		List<Gallery> galleries = galleryManager.getGalleries(topics.subList(0, 6));

		ModelAndView modelAndView = new ModelAndView("index");
		modelAndView.addObject("topics", topics);
		modelAndView.addObject("galleries", galleries);

		return modelAndView;
	}
}
