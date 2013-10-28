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
			<li class="current_page_item"><a href="index.jsp">Home</a></li>
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
%>
	<div id="banner-wrapper">
		<section id="banner">
		<div style="text-align: center;">
		<form action="<%= blobstoreService.createUploadUrl("/upload") %>" method="post" enctype="multipart/form-data">
		<table class="center">
		<tr><td><h1>Title for your Audio:*</td>
			<td><input type="text" name="file_title" placeholder="eg: 'My first guitar solo'" size="35" required/></td>
		</tr>
		<tr><td><h1>Subtitle: </h1></td>
			<td><input type="text" name="file_subtitle" placeholder="eg: 'Recorded while visiting my brother'" size="35" /></td>
		</tr>
		<tr><td><h1>MP4 file:*</h1></td>
			<td><input type="file" name="audio_file" required/></td>
		</tr>
		<tr><td><h1>Tags (comma separated): </h1></td>
			<td><input type="text" name="file_tags" placeholder="eg: 'rock, good-music, yolo'" size="35" /></td>
		</tr>
		<tr><td><h1>Short description: </h1></td>
			<td><textarea name="file_desc" rows="5" cols="28" placeholder="If you want to tell us why your record is so cool, please feel free to do it here!"></textarea></td>
		</tr>		
		<tr><td><h1>Visibility: </h1></td>
			<td><select name="visibility">
				<option value="public">I want to make this upload public</option>
				<option value="private">This one is just for me</option>
				</select></td>
		</tr>
		</table>
		
		<input type="submit" class="button" value="Upload file"/><br>
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