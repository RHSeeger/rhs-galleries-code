package com.rhseeger.services;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.orm.hibernate3.HibernateTemplate;

import com.rhseeger.models.Gallery;
import com.rhseeger.models.Photo;

public class GalleryManager {
	static final private Logger logger = Logger.getLogger(GalleryManager.class);
	private HibernateTemplate hibernateTemplate;

	public void setSessionFactory(SessionFactory sessionFactory) {
		logger.info("SessionFactory supplied");
		this.hibernateTemplate = new HibernateTemplate(sessionFactory);
	}
	public SessionFactory getSessionFactory() {
		return hibernateTemplate.getSessionFactory();
	}

	public List<Gallery> getGalleries(List<String> topics) {
		Session session = hibernateTemplate.getSessionFactory().openSession();
		session.beginTransaction();
        try {
        	return getGalleries(topics, session);
        } finally {
            session.getTransaction().commit();
//          session.close();
        } 
	}
	public List<Gallery> getGalleries(final List<String> topics, Session session) {
        @SuppressWarnings("unchecked")
        List<Gallery> galleries = (List<Gallery>)(session
        	.createQuery("FROM Gallery AS gallery LEFT JOIN FETCH gallery.photos WHERE searchTerm in ('" + StringUtils.join(HibernateUtil.escapeSql(topics), "','") + "')")
        	.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY)
        	.list());
        Collections.sort(galleries, new Comparator<Gallery>() {
        	public int compare(Gallery g1, Gallery g2) {
        		Integer index1 = topics.indexOf(g1.getSearchTerm());
        		Integer index2 = topics.indexOf(g2.getSearchTerm());
        		return index1.compareTo(index2);
        	}
        });
        return galleries;
	}	
	
	
	// Can we find a way to set this transaction to read-only?
	public Gallery getGallery(String searchTerm) {
		Session session = hibernateTemplate.getSessionFactory().openSession();
        session.beginTransaction();
        try {
        	return getGallery(searchTerm, session);
        } finally {
            session.getTransaction().commit();
//            session.close();
        }
	}	
	
	/**
	 * 
	 * @param searchTerm
	 * @param session
	 * @return
	 */
	public Gallery getGallery(String searchTerm, Session session) {
		// We need to use DISTINCT_ROOT_ENTRY so that multiple results of the same gallery (one for each photo)
		// get combined to one
		Query query = session
			.createQuery( "FROM Gallery AS gallery LEFT JOIN FETCH gallery.photos WHERE searchTerm = :searchTerm")
			.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY)
			.setString("searchTerm", searchTerm);

		Gallery result = (Gallery)query.uniqueResult();
		return result;
	}	

	public Gallery getGalleryOrNew(String searchTerm) {
		Gallery result = getGallery(searchTerm);
    	return (result == null) ? new Gallery() : result;
	}	
	
	public Gallery getGalleryOrNew(String searchTerm, Session session) {
		Gallery result = getGallery(searchTerm, session);
    	return (result == null) ? new Gallery() : result;
	}	

}
