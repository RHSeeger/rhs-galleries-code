<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Galleries</title>
    <link type="text/css" href="/jqueryui/css/sunny/jquery-ui-1.8.10.custom.css" rel="Stylesheet" />  
    <link rel="stylesheet" type="text/css" media="all" href="/css/home.css" />
    <link rel="stylesheet" type="text/css" media="all" href="/css/common.css" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
    <script src="/jqueryui/js/jquery-ui-1.8.10.custom.min.js"></script>
    <script type="text/javascript" src="/javascript/home.js"></script>
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
                <li class="first ui-corner-all">Main</li>
            </ul>
        </div>
        <div class="content ui-helper-clearfix">
            <div class="lhs">
                <div class="images">
                    <c:forEach var="gallery" items="${galleries}" varStatus="status">
                        <div class="image image${status.index}">
                            <a href="/gallery/${gallery.searchTerm}">
                                <c:set var='image' value="${gallery.photos[0].url['tiny']}"/>
                                <img src="<c:out value='${image}'/>"/>
                            </a>
                            <div class="searchterm"><c:out value="${gallery.searchTerm}"/></div>
                        </div>
                    </c:forEach>
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
