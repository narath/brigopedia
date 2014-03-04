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

We recommend the following permission settings within your wiki

    # The following permissions were set based on your choice in the installer
    $wgGroupPermissions['*']['createaccount'] = false;
    # Disable editing by anonymous users
    $wgGroupPermissions['*']['edit'] = false;
    # Disable reading by anonymous users
    $wgGroupPermissions['*']['read'] = false;

### Move your LocalSettings to /etc/mediawiki and put it under version control

    sudo su
    mkdir /etc/mediawiki
    cd /var/www/mediawiki
    mv LocalSettings.php /etc/mediawiki/LocalSettings.php
    ln -s /etc/mediawiki/LocalSettings.php LocalSettings.php
    cd /etc/mediawiki
    git init .
    git add .
    git commit -m "Initial commit with barebones LocalSettings"

### Setup your logo

Copy the logo to /var/www/mediawiki/images

Ours is called logo.jpg

Edit LocalSettings.php

    -$wgLogo             = "$wgStylePath/common/images/wiki.png";
    -
    +$wgLogo             = "$wgScriptPath/images/logo.jpg";


### Add any additional plugins

I had previously used FileExtension, but it broke recently in uploading Word files, so have not used it. Instead the current file uploading is reasonable once you have done it, so we use this instead.

### Move over any previous wiki files you might have

See the [https://github.com/narath/medwiki/wiki/Moving-your-wiki](wiki) for some tips on moving from your prototype wiki to your production wiki.

### Enable file uploading

The image we use uses SELinux, so you will need to follow the instructions 

Enable some additional file extensions

$wgFileExtensions = array('png','gif','jpg','jpeg','doc','xls','mpp','pdf','ppt','tiff','bmp','docx', 'doc', 'xlsx', 'pptx','ps','odt','ods','odp','odg');

Increase the size of file uploads to 5MB

    vim /etc/php.ini
    
Change

    upload_max_filesize = 2M
    
To

    upload_max_filesize = 5M

### Setup calendaring

We use google calendar (NOTE: these calendars are public), and the PHI widget
