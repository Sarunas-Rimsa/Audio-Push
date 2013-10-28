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
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Query.CompositeFilterOperator" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator" %>

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
		.comments-list li{
			    padding: 2.5em;
			    border-bottom: 1px dashed #ccc;
			}

			.comments-list h2{
			    position: relative;
			    margin: 0;
			}

			.comments-list p{
			    margin: 0;
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
    } else {
    	response.sendRedirect("index.jsp");
    }
%>

<%
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Entity record = datastore.get(KeyFactory.stringToKey(request.getParameter("item")));

    Query guestBookQuery = new Query("Greeting").addFilter("record_key", FilterOperator.EQUAL, KeyFactory.keyToString(record.getKey())).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(guestBookQuery).asList(FetchOptions.Builder.withLimit(50));
    
    Query tagQuery = new Query("Tag").addFilter("record_key", FilterOperator.EQUAL, KeyFactory.keyToString(record.getKey()));
    List<Entity> tags = datastore.prepare(tagQuery).asList(FetchOptions.Builder.withLimit(50));
    
    Query ratingsQuery = new Query("Rating").setFilter(FilterOperator.EQUAL.of("record_key", KeyFactory.keyToString(record.getKey())));
	List<Entity> ratings = datastore.prepare(ratingsQuery).asList(FetchOptions.Builder.withLimit(50));
	boolean userVoted = false;
	for (Entity rating : ratings) {
		if (((User) rating.getProperty("user")).getNickname().equals(user.getNickname())) { userVoted = true; }
	}
%>
		
	<div id="main-wrapper">
		<div id="main" class="5grid-layout">
			<div class="row">
				<div class="12u">
					<section class="is-blog">
						<div class="5grid">
							<div class="row">
								<div class="content content-left">
									<article class="is-post">
										<header>
											<h3><a href="#"><%=record.getProperty("file_title")%></a></h3>
												<span class="byline"><%=record.getProperty("file_subtitle")%></span>
													<ul class="meta">
														<li class="timestamp"><%= record.getProperty("date") %></li>
														<li class="comments"><%= greetings.size() %></li>
														<% 
														String fileOwner = (String)record.getProperty("file_owner");
														String loggedInUser = (String)user.getNickname();
														if (fileOwner.equals(loggedInUser)) { %>
														<li class="none"><a href="edit.jsp?item=<%=request.getParameter("item")%>">Edit record</a></li>
														<li class="none"><a href="delete.jsp?item=<%=request.getParameter("item")%>">Delete record</a></li>
														<% } %>
													</ul>
													<ul class="meta">
													<% for (Entity tag : tags) { %>
														<li class="tag"><a href="/tag.jsp?view=<%=tag.getProperty("record_tag") %>"><%= tag.getProperty("record_tag") %></a></li>
													<% } %>
													</ul>
										</header>
										<audio controls="controls">
											<source src="/serve?audio=<%=record.getProperty("content")%>" type="audio/mp4" />
										</audio>
										<p>
											<%= record.getProperty("file_desc") %>
										</p>
										
										<%
										    if (greetings.isEmpty()) {
										        %>
										        <p>Guestbook has no messages.</p>
										        <%
										    } else {
										    	%> <ol class="comments-list"> <%
										        for (Entity greeting : greetings) {
										        	if (((User) greeting.getProperty("user")).getNickname().equals(user.getNickname())) { %>
										                <li><h1><a href="viewprofile.jsp?username=<%=((User) greeting.getProperty("user")).getNickname()%>"><b><%= ((User) greeting.getProperty("user")).getNickname() %></b></a> (<%=greeting.getProperty("date")%>) <a href="/delete_comment.jsp?item=<%=KeyFactory.keyToString(greeting.getKey())%>">[x]</a></h1>
										                <% } else { %>
										                <li><h1><a href="viewprofile.jsp?username=<%=((User) greeting.getProperty("user")).getNickname()%>"><b><%= ((User) greeting.getProperty("user")).getNickname() %></b></a> (<%=greeting.getProperty("date")%>)</h1>
										                <% } %>
										            <p><%= greeting.getProperty("content") %></p></li>
										            <%
										        }
										    	%> </ol> <%
										    }
										%>
										
										<form action="/sign" method="post">
    										<div><textarea name="content" rows="3" cols="60"></textarea></div>
											<div><input type="submit" value="Leave a comment" /></div> 
											<input type="hidden" name="recordKey" value="<%= request.getParameter("item") %>"/>
										</form>
										
										
										<% if (userVoted) { } else { %>
										<br>
										<form action="/rate" method="post">
											Weak<input type="radio" name="rating" value="1">
											<input type="radio" name="rating" value="2">
											<input type="radio" name="rating" value="3" checked>	
											<input type="radio" name="rating" value="4">
											<input type="radio" name="rating" value="5">Superb
											<input type="hidden" name="recordKeyRating" value="<%= request.getParameter("item") %>"/>	
											<input type="submit" value="Rate it" />
										</form>
										<% } %>
										
									</article>
								</div>
							</div>
						</div>
					</section>							
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