package com.rhseeger.ingester;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.TimerTask;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.BeanFactory;
import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.REST;
import com.aetrion.flickr.photos.PhotoList;
import com.aetrion.flickr.photos.PhotosInterface;
import com.aetrion.flickr.photos.SearchParameters;
import com.rhseeger.models.Gallery;
import com.rhseeger.models.Photo;
import com.rhseeger.models.TopicList;
import com.rhseeger.services.GalleryManager;
import com.rhseeger.services.GoogleTopicsManager;
import com.rhseeger.services.HibernateUtil;
import com.rhseeger.services.TopicListManager;

/**
 * TODO: 
 * - Multithread this so we can get 20 images per gallery and not take forever
 * - Make the number of images per gallery configurable via web.xml property
 * - If a gallery comes back with less than 10 images, don't use the topic
 * - Only save the topics we get galleries for to the topics list
 */
public class ImageIngesterTask extends TimerTask {
	Logger logger = Logger.getLogger(ImageIngesterTask.class);
	GoogleTopicsManager manager = new GoogleTopicsManager();
	String flickrKey;
	SessionFactory sessionFactory;
	
	public ImageIngesterTask(String flickrKey, SessionFactory sessionFactory) {
		this.flickrKey = flickrKey;
		this.sessionFactory = sessionFactory;
	}
    public void run() {
    	logger.info("Running scheduled task: ImageIngesterTask");
    	
    	try {
    		TopicListManager tlManager = new TopicListManager();
    		//tlManager.setSessionFactory(sessionFactory);
    		GalleryManager gManager = new GalleryManager();
    		//gManager.setSessionFactory(sessionFactory);
    		Session session = sessionFactory.openSession();
    		session.beginTransaction();
    			
    		List<String> topics = manager.getTopics();
    		// TODO: Get the list of images for each topic
    		//       Once we get to 6 topics with 10 or more images, we're done
    		
//    		Session session = HibernateUtil.getSessionFactory().openSession();

    		TopicList tl1 = tlManager.getTopicListOrNew("google", session);
    		tl1.setSource("google");
    		tl1.setTopics(topics);
    		session.saveOrUpdate(tl1);
    		logger.info("Google Topics " + tl1);
		
    		for(String topic : topics.subList(0, 6)) {
    			Gallery gallery = gManager.getGalleryOrNew(topic, session);
    			gallery.setSearchTerm(topic);
    			gallery.setPhotos(toPhotos(getPhotoList(flickrKey, topic)));
    			session.saveOrUpdate(gallery);
    		}
    		
    		session.getTransaction().commit();
    		//session.close();
    	} catch(Exception ex) {
    		logger.warn("Failed to get flickr topics/photos: " + ex.getMessage());
    		logger.warn(StringUtils.join(ex.getStackTrace(),"\n"));
    	}
    }

    
	public List<Photo> toPhotos(List<com.aetrion.flickr.photos.Photo> photoList) {
    	List<Photo> photos = new ArrayList<Photo>();
    	for(com.aetrion.flickr.photos.Photo photo : photoList) {
    		Photo current = new Photo();
    		current.setFlickrPhotoId(photo.getId());
    		current.setTitle(photo.getTitle());
    		current.setDescription(photo.getDescription());
    		current.setFlickrOwnerId(photo.getOwner().getId());
    		current.setFlickrOwnerDisplayName(photo.getOwner().getRealName());
    		current.setFlickrFarm(photo.getFarm());
    		current.setFlickrServer(photo.getServer());
    		current.setFlickrSecret(photo.getSecret());
    		photos.add(current);
    		logger.info("Added photo: " + current);
    	}
    	return photos;
    }
    
    //  PhotoList 	search(SearchParameters params, int perPage, int page) 
	@SuppressWarnings("unchecked")
	public List<com.aetrion.flickr.photos.Photo> getPhotoList(String apiKey, String topic) throws FlickrException, SAXException, IOException, ParserConfigurationException {
		logger.info("Getting Flickr Photos (key=" + apiKey + ") (topic=" + topic + ")");
		Flickr f = new Flickr(apiKey, new REST());
		PhotosInterface photosInterface = f.getPhotosInterface();
		SearchParameters sparams = new SearchParameters();
		sparams.setSort(SearchParameters.INTERESTINGNESS_DESC);
		sparams.setText(topic);
		PhotoList results = photosInterface.search(sparams, 10, 0);
		for(com.aetrion.flickr.photos.Photo photo : (List<com.aetrion.flickr.photos.Photo>)results) {
			logger.info("Photo: " + photo.getThumbnailUrl());
		}
		List<com.aetrion.flickr.photos.Photo> resultList = new ArrayList<com.aetrion.flickr.photos.Photo>();
		for(com.aetrion.flickr.photos.Photo photo : (List<com.aetrion.flickr.photos.Photo>)results) {
			resultList.add(photosInterface.getInfo(photo.getId(), photo.getSecret()));
		}
		return resultList;
	}
}
