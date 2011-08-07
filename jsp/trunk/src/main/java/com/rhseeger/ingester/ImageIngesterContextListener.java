package com.rhseeger.ingester;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.web.context.support.WebApplicationContextUtils;

public class ImageIngesterContextListener implements ServletContextListener {
	Logger logger = Logger.getLogger(ImageIngesterContextListener.class);
	
	private ScheduledExecutorService scheduler;

	public void contextInitialized(ServletContextEvent event) {
		ServletContext sc = event.getServletContext();
		BeanFactory beanFactory = WebApplicationContextUtils.getRequiredWebApplicationContext(sc);
		SessionFactory sessionFactory = beanFactory.getBean("sessionFactory", SessionFactory.class);

		Integer minutes;
		String flickr_key;
		try {
			minutes = Integer.parseInt(sc.getInitParameter("IngestionDelayInMinutes"));
			flickr_key = sc.getInitParameter("FlickrKey");
		} catch(NumberFormatException ex) {
			logger.error("Could not start ingester task, 'delayInMinutes' init param not specified or not an Integer");
			return;
		}
		logger.info("Starting ingester task every " + minutes + " minutes");
		
	    scheduler = Executors.newSingleThreadScheduledExecutor();
	    scheduler.scheduleAtFixedRate(new ImageIngesterTask(flickr_key, sessionFactory), 0, minutes, TimeUnit.MINUTES);
	}

	public void contextDestroyed(ServletContextEvent event) {
		if(scheduler != null) {
			scheduler.shutdown();
		}
	}
}
