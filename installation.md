# NetworkPainter installation #

1. Install [third party software](about.php#software)
2. Download source code from [Github](http://github.com/CovertLab/NetworkPainter)
3. Setup MySQL database
   1. Create new database
   2. Install [`db/schema.sql`](db/schema.sql) and [`db/procedures.sql`](db/procedures.sql) into new database
   3. Edit MXML configuration file [`src/edu/stanford/covertlab/networkpainter/data/AboutData.mxml`](src/edu/stanford/covertlab/networkpainter/data/AboutData.mxml)
   4. Edit PHP configuration file [`bin/configuration.php`](bin/configuration.php)
4. Install AMPPHP services
   1. NetworkPainter [`amfphp/services/NetworkPainter`](amfphp/services/NetworkPainter)
   2. KEGG [`amfphp/services/KEGG`](amfphp/services/KEGG)
5. Compile application using [`src/edu/stanford/covertlab/networkpainter/build.bat`](src/edu/stanford/covertlab/networkpainter/build.bat)
6. Run application `bin/NetworkPainter.swf`
7. Edit source code as necessary using [FlashDevelop](http://www.flashdevelop.org)
