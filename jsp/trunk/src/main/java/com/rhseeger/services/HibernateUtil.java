package com.rhseeger.services;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringEscapeUtils;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.AnnotationConfiguration;

public class HibernateUtil {
//    private static final SessionFactory sessionFactory;
//    static {
//        try {
//            // Create the SessionFactory from standard (hibernate.cfg.xml) config file.
//            sessionFactory = new AnnotationConfiguration().configure().buildSessionFactory();
//        } catch (Throwable ex) {
//            // Log the exception. 
//            System.err.println("Initial SessionFactory creation failed." + ex);
//            throw new ExceptionInInitializerError(ex);
//        }
//    }

//    public static SessionFactory getSessionFactory() {
//        return sessionFactory;
//    }
    
    public static List<String> escapeSql(List<String> input) {
    	List<String> result = new ArrayList<String>();
    	for(String value: input) {
    		result.add(StringEscapeUtils.escapeSql(value));
    	}
    	return result;
    }
}
