<!DOCTYPE HTML>
<!--
	TXT 1.0 by HTML5 Up!
	html5up.net | @n33co
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Query.CompositeFilterOperator" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator" %>

<%
BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
%>

<html>
	<head>
		<title>Audio Push</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:400,700|Open+Sans+Condensed:700" rel="stylesheet" />
		<script src="js/jquery-1.8.3.min.js"></script>
		<script src="css/5grid/init.js?use=mobile,desktop,1000px&amp;mobileUI=1&amp;mobileUI.theme=none&amp;mobileUI.titleBarOverlaid=1"></script>
		<noscript>
			<link rel="stylesheet" href="css/5grid/core.css" />
			<link rel="stylesheet" href="css/5grid/core-desktop.css" />
			<link rel="stylesheet" href="css/5grid/core-1200px.css" />
			<link rel="stylesheet" href="css/5grid/core-noscript.css" />
			<link rel="stylesheet" href="css/style.css" />
			<link rel="stylesheet" href="css/style-desktop.css" />
		</noscript>
		<!--[if lte IE 9]><link rel="stylesheet" href="css/ie9.css" /><![endif]-->
		<!--[if lte IE 8]><link rel="stylesheet" href="css/ie8.css" /><![endif]-->
		<!--[if lte IE 7]><link rel="stylesheet" href="css/ie7.css" /><![endif]-->
		
		<style>
		table.center {
			margin-left: auto;
			margin-right: auto;
		}
		</style>
		
	</head>
	<body class="homepage">

<%
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
%>
	<nav id="nav" class="mobileUI-site-nav">
		<ul>
			<li><a href="index.jsp">Home</a></li>
			<li><a href="library.jsp">Your library</a></li>
			<li><a href="publicfeed.jsp">Public records</a></li>
			<li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Sign Out</a></li>
		</ul>
	</nav>
<%
    }
%>
	
	<br><br>
	<br><br>
	
<%
    if (user != null) {
    
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Entity record = datastore.get(KeyFactory.stringToKey(request.getParameter("item")));
    
    Query tagQuery = new Query("Tag").addFilter("record_key", FilterOperator.EQUAL, KeyFactory.keyToString(record.getKey()));
    List<Entity> tags = datastore.prepare(tagQuery).asList(FetchOptions.Builder.withLimit(10));
    
    String printableTags = "";
    
    for (Entity tag : tags) {
    	printableTags = printableTags + tag.getProperty("record_tag") + ", ";
    }
    
    //printableTags[printableTags.length()-1] = "";
    if (tags.size() > 0) {
    	printableTags = printableTags.substring(0, printableTags.length()-2);
    }
    
%>
	<div id="banner-wrapper">
		<section id="banner">
		<div style="text-align: center;">
		<form action="/delete" method="post">
		
		<h1>Are you sure you want to delete this record?</h1>
		
		<input type="hidden" name="recordKey" value="<%= request.getParameter("item") %>"/>
		<input type="submit" class="button" value="Yeah, delete it"/><br>
		</form>
		</div>
		</section>
	</div>
<%
    } else {
%>
	<div id="banner-wrapper">
		<section id="banner">
			<h2>Audio Push</h2>
			<span class="byline">Hello stranger, sign in well ya?</span>
			<a class="button" href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
		</section>
	</div>
<%
    }
%>
			<footer id="footer" class="5grid-layout">
				<div class="row">
					<div class="12u">
							<section>
								<h2 class="major"><span>What's this about?</span></h2>
								<p>
									Audio Push is a free service that allows you to upload your recent thoughts to the cloud.
									Have an idea? Record it using our Android app, upload to the cloud and hear what the world
									has to say about that!
								</p>
							</section>
					</div>
				</div>
				<div class="row">
						<div id="copyright">
							&copy; 2013 Audio Push | Images: <a href="http://fotogrph.com">Fotogrph</a> + <a href="http://iconify.it">Iconify.it</a> | Design: <a href="http://html5up.net/">HTML5 Up!</a>
						</div>
				</div>
			</footer>
	</body>
</html>