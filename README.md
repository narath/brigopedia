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

We use ActiveDirectory using the http://www.mediawiki.org/wiki/Extension:LDAP_Authentication. See the https://github.com/narath/medwiki/wiki/ActiveDirectory for some instructions on how to set this up (you will need to get some configuration settings from your ActiveDirectory admin).

We recommend the following permission settings within your wiki

    # The following permissions were set based on your choice in the installer
    $wgGroupPermissions['*']['createaccount'] = false;
    # Disable editing by anonymous users
    $wgGroupPermissions['*']['edit'] = false;
    # Disable reading by anonymous users
    $wgGroupPermissions['*']['read'] = false;

TODO: how to enable LDAP to give you email addresses so that users can receive notifications about watched pages.

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

See the https://github.com/narath/medwiki/wiki/Moving-your-wiki for some tips on moving from your prototype wiki to your production wiki.

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

### Setup Foreground Skin for responsive site

We use the Mediawiki Foreground Skin to add reponsive layouts to our mediawiki installation.  

#### Installation Notes:

    sudo su
    # navigate to the mediawiki skins directory
    cd /opt/mediawiki/mediawiki-{version}/skins

    # clone foreground skin from github repo
    git clone https://github.com/thingles/foreground.git

    # change ownership to apache
    chown apache:apache /opt/mediawiki/mediawiki-{version}/skins -R

    # Add the following lines to LocalSettings.php: 
    # require_once "$IP/skins/foreground/foreground.php";
    vi /opt/mediawiki/mediawiki-{version}/LocalSettings.php

    # Optionally, change the default skin to foreground for mobile devices (also in LocalSettings.php)
    #    if (preg_match("/(mobile|webos|opera mini)/i", $_SERVER['HTTP_USER_AGENT'])) {
    #       $wgDefaultSkin = 'foreground';
    #    } else {
    #       $wgDefaultSkin = 'vector';
    #    }

#### Additional Styling Notes:

In addition to the standard vector and foreground skins we added supplimental styles to support responsive "panels" on the main wiki page.  The wiki page https://github.com/narath/mediki/wiki/Additional-Styles---MediaWiki:Common.css shows the styles we used. These styles were added to /index.php/MediaWiki:Common.css page.


### Setup Twitter Widget extension

We added the Twitter Widget extension (http://www.mediawikiwidgets.org/Twitter) to our mediawiki installation. This extension has a dependency on the Widget extension (http://www.mediawiki.org/wiki/Extension:Widgets).

#### Installation Notes:

We first installed the Widget extension. We performed the follow steps starting from the mediawiki home diretory:

    cd extensions
    git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Widgets.git
    cd Widgets
    git submodule init
    git submodule update

Then we added the follow instruction to the LocalSettings.php file:

    require_once "$IP/extensions/Widgets/Widgets.php";
    
Then we changed the Widget extension file owership and granted read-write access to the web server to the Widgets/compliled_templates directory:

    chown -R apache:apache /opt/mediawiki/mediawiki-{version}/extensions/Widgets
    chmod -R 755 /opt/mediawiki/mediawiki-{version}/extensions/Widgets/compiled_templates
    
Then we then configured SELinux to allow the web server to write to the `compiled_templates` directory:

    semanage fcontext -a -t httpd_sys_rw_content_t /opt/mediawiki/mediawiki-{version}/extensions/Widgets/compiled_templates
    restorecon -v /opt/mediawiki/mediawiki-{version}/extensions/Widgets/compiled_templates
    
Next we declared the Twitter Widget by creating a new page called Widget.Twitter and adding the following content:

    <noinclude>__NOTOC__
    This widget allows you to embed a '''[http://twitter.com/widgets/html_widget Twitter feed]''' (HTML version) on your wiki page.

    Created by [http://www.mediawikiwidgets.org/User:Sergey_Chernyshev Sergey Chernyshev]

    == Using this widget ==
    For information on how to use this widget, see [http://www.mediawikiwidgets.org/Twitter widget description page on MediaWikiWidgets.org].

    == Copy to your site ==
    To use this widget on your site, just install [http://www.mediawiki.org/wiki/Extension:Widgets MediaWiki Widgets extension] and copy [{{fullurl:{{FULLPAGENAME}}|action=edit}} full source code] of this page to your wiki as '''{{FULLPAGENAME}}''' article.
    </noinclude><includeonly><a class="twitter-timeline" href="" data-widget-id="<!--{$id|escape:'html'}-->"></a>
    <!--{counter name="twittercounter" assign="twitblogincluded"}--><!--{if $twitblogincluded eq 1}--><script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script><!--{/if}--></includeonly>

Finally, we are able to embed the Twitter widget on any page with the following syntax:

    {{#widget:Twitter|user=perfplanet|id=573172210619322368}}


### Setup TopTenPages extension

We added the TopTenPages extension (http://www.mediawiki.org/wiki/Extension:TopTenPages) to our mediawiki installation.

#### Installation Notes:

We manually created the file TopTenPages.php in the `/opt/mediawiki/mediawiki-{version}/extensions` directory with the following contents:

    <?php
     
    # To install the extension, add to your LocalSettings.php:
    # require_once("$IP/extensions/TopTenPages.php");
    
    /*
    	Syntax:
    	<TopTenPages/>
    	<TopTenPages>5</TopTenPages>
    	<TopTenPages offset="1"/>
    	{{Special:TopTenPages}}
    	{{Special:TopTenPages/-/5}}
    	{{Special:TopTenPages/1/5}}
    */
    
    $wgExtensionCredits['specialpage'][] = array(
    	'name' => 'TopTenPages',
    	'version' => '0.3.2',
    	'author' => array(
    		'Timo Tijhof',
    		'Sascha',
   	),
   	'url' => 'https://www.mediawiki.org/wiki/Extension:TopTenPages',
    	'description' => 'Shows most viewed pages.',
    );
     
    $wgAutoloadClasses['SpecialTopTenPages'] = __DIR__ . '/SpecialTopTenPages.php';
    $wgSpecialPages['TopTenPages'] = 'SpecialTopTenPages';
    $wgSpecialPageGroups['TopTenPages'] = 'other';
     
    $wgExtensionFunctions[] = 'efTopTenPages';
     
    # When including, always start the list numbering at one, even if offset was set.
    # Defaults to false so that if (for example) offset is 1, the list will be numbered 2, 3, 4 ...
    $wgttpAlwaysStartAtOne = false;
     
    function efTopTenPages() {
    	global $wgParser;
    	$wgParser->setHook( 'TopTenPages', 'efTopTenPagesRender' );
    }
     
    /**
     * The callback function for converting the input text to HTML output.
     */
    function efTopTenPagesRender( $text, array $args, Parser $parser, PPFrame $frame ) {
    	if (array_key_exists('offset', $args)) {
    		$offset = (int) $args['offset'];
    	} else {
    		$offset = 0;
    	}
    	if ($text > 0){
    		$limit = (int) $text;
    	} else {
    		$limit = 10;
    	}
     	return $parser->recursiveTagParse( "{{Special:TopTenPages/$offset/$limit}}", $frame );
    }

We added the following lines to the `/opt/mediawiki/mediawiki-{version}/LocalSettings.php` file:

    require_once("$IP/extensions/TopTenPages.php");
    $wgttpAlwaysStartAtOne = true;

The TopTenPages widget can now be added to any page by adding the `<TopTenPages/>` tag.

### Setup Calendaring with HTMLets extension

We use Google Calendar for this through the mediawiki HTMLet extension.  HTMLets allow you to inject pre-defined HTML widgets into your mediawiki content.

#### Installation Notes:

    sudo su
    # download HTMLets mediawiki extension
    wget https://codeload.github.com/wikimedia/mediawiki-extensions-HTMLets/legacy.tar.gz/REL1_22

    # unpack HTMLets extension
    tar xvfz {tar file name} 

    # make directory for HTMLets extension
    mkdir /opt/mediawiki/mediawiki-{version}/extensions/HTMLets

    # move contents to mediawiki extensions directory
    mv wikimedia-mediawiki-extensions-HTMLets-895af16/* /opt/mediawiki/mediawiki-{version}/extensions/HTMLets

    # go to mediawiki extensions directory
    cd /opt/mediawiki/mediawiki-{version}/extensions

    # Add the following lines to LocalSettings.php: 
    # require_once( "$IP/extensions/HTMLets/HTMLets.php" );
    # $wgHTMLetsDirectory = "$IP/htmlets";
    vi /opt/mediawiki/mediawiki-{version}/LocalSettings.php

    # Create new /opt/mediawiki/mediawiki-{version}/htmlets directory
    mkdir /opt/mediawiki/mediawiki-{version}/htmlets

    # Create new HTMLet file in the /opt/mediawiki/mediawiki-{version}/htmlets directory
    # Include any html in the new file.

    # change ownership of HTMLets extension and htmlets directory
    chown apache:apache /opt/mediawiki/mediawiki-{version}/extensions/HTMLets -R
    chown apache:apache /opt/mediawiki/mediawiki-{version}/htmlets -R


### Setup VisualEditor extension

The VisualEditor extension provides convienent, user-friendly way for editors to modify wiki content without needing to know wiki syntax.

#### Installation Notes:

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
    vi /etc/init.d/parsoid   # see https://github.com/narath/medwiki/wiki/Parsoid-Node-Server-init.d-script for an example

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
    vi LocalSettings.php  # see https://github.com/narath/medwiki/wiki/VisualEditor-LocalSettings.php-properties

### Setup DynamicPageList (Intersection) extension

The DynamicPageList (Intersection) extension allows users to embed lists of pages based on page categories.

#### Installation Notes:

    sudo su

    # go to mediawiki extensions directory
    cd /opt/mediawiki/mediawiki-{version}/extensions

    # git clone Intersection extension
    git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/intersection.git intersection

    # Add the following line to LocalSettings.php to enable the Dynamic Page List (Intersection) extension
    # require_once("$IP/extensions/intersection/DynamicPageList.php");
    vi LocalSettings.php

### Backup Mediawiki

Our backup script backups several disparate artifacts.  We first perform a mysqldump of the mediawiki database, then we create a tarball which includes the mysqldump data, the entire mediawiki application, as well as the mediawiki configuration files located under the /etc/mediawiki directory.

The backup script then compresses the resulting tarball and gives it a date-stamped filename, for example, backup-201403111314.tgz.  Then the compressed backup file is uploaded to our Amazon S3 bucket.  The opensource AWS tools scripts are used to upload the backup file to Amazon S3, http://timkay.com/aws/.  A sample backup script can be found here: https://github.com/narath/medwiki/wiki/Mediawiki-sample-backup-script.

### Security updates

We created a Google Group, brigopedia-security-alerts@googlegroups.com, which you can subscribe to to receive information about vurnerabilities and security updates for the following brigopedia components:

* CentOS
* Mediawiki

It would nice to be able to subscribe to mailing lists for these items, as well, but we were not able to locate lists for these extensions:

* LDAPAuthentication
* VisualEditor
* Widgets extension

# Feedback / Ideas / Suggestions

I'd welcome your thoughts and feedback on this. Just post your thoughts in the issues and I should see it there. 


