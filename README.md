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

We use ActiveDirectory using the [http://www.mediawiki.org/wiki/Extension:LDAP_Authentication](LDAP plugin). See the [https://github.com/narath/medwiki/wiki/ActiveDirectory|https://github.com/narath/medwiki/wiki/ActiveDirectory](wiki) for some instructions on how to set this up (you will need to get some configuration settings from your ActiveDirectory admin).

We recommend the following permission settings within your wiki

    # The following permissions were set based on your choice in the installer
    $wgGroupPermissions['*']['createaccount'] = false;
    # Disable editing by anonymous users
    $wgGroupPermissions['*']['edit'] = false;
    # Disable reading by anonymous users
    $wgGroupPermissions['*']['read'] = false;

### Configure SMTP (Mail) Settings

If using a remote SMTP server, make sure you have enabled httpd to use network connections in SELinux.  This is currently handled by the Puppet script (see task 'Enable Mediawiki to connect to remote smtp service').

Append to the LocalSettings file:

    $wgSMTP = array(
     'host'     => "mail.example.com", // could also be an IP address. Where the SMTP server is located
     'IDHost'   => "example.com",      // Generally this will be the domain name of your website (aka mywiki.org)
     'port'     => 25,                 // Port to use when connecting to the SMTP server
     'auth'     => true,               // Should we use SMTP authentication (true or false)
     'username' => "my_user_name",     // Username to use for SMTP authentication (if being used)
     'password' => "my_password"       // Password to use for SMTP authentication (if being used)
    );


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

The image we use uses SELinux, so you will need to follow the instructions here http://www.mediawiki.org/wiki/Manual:Configuring_file_uploads

Enable some additional file extensions

$wgFileExtensions = array('png','gif','jpg','jpeg','doc','xls','mpp','pdf','ppt','tiff','bmp','docx', 'doc', 'xlsx', 'pptx','ps','odt','ods','odp','odg');

Increase the size of file uploads to 5MB

    vim /etc/php.ini
    
Change

    upload_max_filesize = 2M
    
To

    upload_max_filesize = 5M

### Setup calendaring

We use google calendar for this, and are working on using an integrated widget

### Setup VisualEditor extension

The VisualEditor extension provides convienent, user-friendly way for editors to modify wiki content without needing to know wiki syntax.

Installation Notes:
-------------------

    sudo su
    mkdir /opt/services
    cd /opt/services
    
    # Parsoid is a necessary component to support saving edits performed by VisualEditor
    git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid
    
    # Install Epel repository; necessary for installing nodejs/npm
    rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    
    # Install nodejs and npm
    yum -y --enablerepo=epel install npm nodejs
    
    cd /opt/services/parsoid
    npm install
    cd /opt/services/parsoid/api
    cp localsettings.js.example localsettings.js
    
    # Edit localsettings.js modifying the interwiki line to point to localhost non-https url.  We needed to expose a new port on apache for this which was only accessible from localhost, for example: parsoidConfig.setInterwiki( 'localhost', 'http://localhost:81/api.php' );
    vi localsettings.js
    
    cd /opt/services/parsoid
    
    # Test parsoid node server
    node api/server.js
    
    # kill parsoid node server
    ^C

    # Create parsoid user to run parsoid node server
    useradd parsoid

    # Grant parsoid user ownership of /opt/services/parsoid
    chown parsoid:parsoid /opt/services/parsoid -R

    # Create parsoid init.d script in /etc/init.d/ to start parsoid node server
    vi /etc/init.d/parsoid   # see [https://github.com/narath/medwiki/wiki/Parsoid-Node-Server-init.d-script] for an example

    chmod 755 /etc/init.d/parsoid
    chkconfig --add /etc/init.d/parsoid

    # start parsoid node server
    /etc/init.d/parsoid start

    # confirm parsoid node server is running
    curl localhost:8000

    # go to mediawiki extensions directory
    cd /opt/mediawiki/mediawiki-{version}/extensions

    # git clone VisualEditor extension
    git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git

    # go to VisualEditor extension directory
    cd VisualEditor/

    # initialize VisualEditor extension
    git submodule update --init

    # Add VisualEditor settings to mediawiki LocalSettings.php
    vi LocalSettings.php  # see [https://github.com/narath/medwiki/wiki/VisualEditor-LocalSettings.php-properties]

### Backup Mediawiki

Our backup script backups several disparate artifacts.  We first perform a mysqldump of the mediawiki database, then we create a tarball which includes the mysqldump data, the entire mediawiki application, as well as the mediawiki configuration files located under the /etc/mediawiki directory.

The backup script then compresses the resulting tarball and gives it a date-stamped filename, for example, backup-201403111314.tgz.  Then the compressed backup file is uploaded to our Amazon S3 bucket.  The opensource AWS tools scripts are used to upload the backup file to Amazon S3, [http://timkay.com/aws/].  A sample backup script can be found here: [https://github.com/narath/medwiki/wiki/Mediawiki-sample-backup-script].

# Feedback / Ideas / Suggestions

I'd welcome your thoughts and feedback on this. Just post your thoughts in the issues and I should see it there. 

