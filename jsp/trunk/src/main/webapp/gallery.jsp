<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="/WEB-INF/custom.tld" prefix="custom" %>
<html>
<head>
    <title>Galleries</title>
    <link type="text/css" href="/jqueryui/css/sunny/jquery-ui-1.8.10.custom.css" rel="Stylesheet" />  
    <link rel="stylesheet" type="text/css" media="all" href="/css/gallery.css" />
    <link rel="stylesheet" type="text/css" media="all" href="/css/common.css" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
    <script src="/jqueryui/js/jquery-ui-1.8.10.custom.min.js"></script>
    <script type="text/javascript" src="/javascript/gallery.js"></script>
    <script src="/galleria/galleria-1.2.2.min.js"></script>
    
    
<script>
var image_data = [
<c:forEach var="photo" items="${gallery.photos}">
    {
        image: '<custom:escapeJS value="${photo.url.original}"/>',
        thumb: '<custom:escapeJS value="${photo.url.thumbnail}"/>',
        title: '<custom:escapeJS value="${photo.title}"/>',
        description: '<custom:escapeJS value="${photo.description}"/>',
        user: '<custom:escapeJS value="${photo.flickrOwnerDisplayName}"/>',
        linkback: '<custom:escapeJS value="${photo.linkbackUrl}"/>'
    },
</c:forEach>
];
</script>
</head>
<body>

<div class="page">
    <div class="header ui-corner-all ui-widget">
        <h1>TrendImages</h1>
        <div class="description">Image galleries built from what people are interested around the web.</div>
    </div>

    <div class="body ui-corner-all">
        <div class="breadcrumb ui-corner-all">
            <ul>
                <li class="first ui-corner-all">Gallery</li>
                <li class="ui-corner-all">topic</li>
            </ul>
        </div>
        <div class="content ui-helper-clearfix">
            <div class="lhs">
                <div id="gallery"></div>
                <div id="imagedata">
                    <div class="title"></div> 
                    <div class="user">by <span class="username"></span></div>
                    <div class="description"></div>
                </div>
            </div>
            <div class="rhs">
                <img src="https://www.google.com/adsense/static/en_US/images/160x600.gif" alt="Wide Skyscraper" border="0" height="600" width="160">
            </div>
        </div>
    </div>

    <div class="footer ui-corner-all">
        This is the footer
    </div>
</div>


</body>
</html>

