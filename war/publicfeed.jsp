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
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query.CompositeFilterOperator" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator" %>

<%@ page import="java.util.List" %>

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
			<li class="current_page_item"><a href="publicfeed.jsp">Public records</a></li>
			<li><a href="<%= userService.createLogoutURL("/index.jsp") %>">Sign Out</a></li>
		</ul>
	</nav>
<%
    } else {
    	response.sendRedirect("index.jsp");
    }
%>

	<div id="main-wrapper">
		<div id="main" class="5grid-layout">
			<div class="row">
				<div class="12u">
				<section class="is-blog">
					<div class="5grid">
						<div class="row">
							<div class="4u">
	<ul class="style2">

<%
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    
    Query query = new Query("AudioRecord").addFilter("file_visibility", FilterOperator.EQUAL, "public").addSort("rating", Query.SortDirection.DESCENDING);
    List<Entity> records;
    boolean isPageFilled = false;
    
    if(request.getParameter("offset") != null) {
    	int offset = Integer.parseInt(request.getParameter("offset"));
    	records = datastore.prepare(query).asList(FetchOptions.Builder.withOffset(offset).limit(15));
    	isPageFilled = true;
    }
    else {
    	records = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(15));
   	}
    
	int recordCounter = 0;
    for (Entity record : records) {
    
	Query guestBookQuery = new Query("Greeting").addFilter("record_key", FilterOperator.EQUAL, KeyFactory.keyToString(record.getKey())).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(guestBookQuery).asList(FetchOptions.Builder.withLimit(50));
	    
	    
	    recordCounter++;
%>
		<li>
			<article class="is-post-summary">
				<h3><a href="/view.jsp?item=<%= KeyFactory.keyToString(record.getKey()) %>"><%=record.getProperty("file_title")%></a>
				<a href="viewprofile.jsp?username=<%=(record.getProperty("file_owner"))%>"><b>(by: <%= (record.getProperty("file_owner")) %>)</b></a></h3>
					<ul class="meta">
						<li class="timestamp">Posted: <%= record.getProperty("date")%></li>
						<li class="comments"><%= greetings.size() %></li>
					</ul>
					<ul class="meta">
						<li class="none">Rating: <%= record.getProperty("rating") %></li>
					</ul>
					<% Query tagQuery = new Query("Tag").addFilter("record_key", FilterOperator.EQUAL, KeyFactory.keyToString(record.getKey()));
					   List<Entity> tagEntities = datastore.prepare(tagQuery).asList(FetchOptions.Builder.withLimit(15));
					   if (tagEntities.size() > 0) {
					   for (Entity tag : tagEntities) {
					%>
					<ul class="meta">
						<li class="tag"><a href="/tag.jsp?view=<%=tag.getProperty("record_tag") %>"><%= tag.getProperty("record_tag") %></a></li>
					</ul>
					  <% } } %>
			</article>
		</li>
	
<%
	if (recordCounter == 5 || recordCounter == 10) {
%>
	</ul>
	</div>
	<div class="4u">
	<ul class="style2">
<% }
	if (recordCounter == 15) {
%>
	</ul>
	</div>
	</div>
<% }} %>
					
<% if (isPageFilled == true) { %>			
	<div style="text-align: center">
		<% 
		int offset;
		if (request.getParameter("offset") != null) {
			offset = Integer.parseInt(request.getParameter("offset")) + 15;
		} else {
			offset = 15;
		} 
		%>
		<a href="http://localhost:8888/publicfeed.jsp?offset=<%= offset %>" class="button button-alt">Show more records</a>
	</div>
<% } %>
						</section>
					</div>							
				</div>
			</div>
		</div>
	</div>
	
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
			<!-- Copyright -->
				<div id="copyright">
					&copy; 2012 Untitled Something | Images: <a href="http://fotogrph.com">Fotogrph</a> + <a href="http://iconify.it">Iconify.it</a> | Design: <a href="http://html5up.net/">HTML5 Up!</a>
				</div>
			<!-- /Copyright -->
		</div>
	</footer>
	</body>
</html>