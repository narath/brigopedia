How to setup your own Medical Wiki
======

What you will need
---
A virtual machine or a server that you can install the system onto.

This installation assumes that you have a database system already configured that you will also be using.

Our Baseline configuration
----
* Vmware virtual machine
* Centos 6.5
* Shared Mysql server with our own database
* ssh access to the server

Setting up your server
------

### Use the puppet script to setup and install the mediawiki server

You will need to manually step thru the wizard at the end to configure your mediawiki server.

### Decide on your authentication scheme

Possibilities include:
* local users (i.e. only those with local accounts can access the system, you control who can create or self create accounts).
* ActiveDirectory integration

We use ActiveDirectory using the [http://www.mediawiki.org/wiki/Extension:LDAP_Authentication](LDAP plugin). See the [https://github.com/narath/medwiki/wiki/ActiveDirectory](wiki) for some instructions on how to set this up (you will need to get some configuration settings from your ActiveDirectory admin).

### Move your LocalSettings to /etc/mediawiki and put it under version control

### Setup your logo

### Add any additional plugins

We use FileExtension, SimpleCaptcha

### Move over any previous wiki files you might have

### Setup calendaring

We use google calendar (NOTE: these calendars are public), and the PHI widget







