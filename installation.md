<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <title>NetworkPainter Installation</title>
  <meta name="description" content="NetworkPainter is a flash-based online software environment which enables biologists to easily visualize and analyze high-throughput experimental data in the context of complex protein network hypotheses, peform quantitative simulations, collaborate with colleagues, and publish experiments and analysis." />
  <meta name="keywords" content="systems biology, software, collaboration, open access, graphics, animations, network diagrams, bayesian, boolean, ODE, mass action kinetics, flow cytometry, data analysis, visualization" />  
  <link rel="stylesheet" type="text/css" href="css/main.css"/>
</head>
<body>
      <p>
		<ol>
			<li>Install <a href="about.php#software">third party software</a></li>
			<li>Download source code from <a href="http://simtk.org/home/networkpainter">SimTK</a></li>
			<li>Setup MySQL database
				<ol>
					<li>Create new database</li>
					<li>Install <a href="/db/schema.sql">/db/schema.sql</a> and <a href="/db/procedures.sql">/db/procedures.sql</a> into new database</li>
					<li>Edit MXML configuration file <a href="/src/edu/stanford/covertlab/networkpainter/data/AboutData.mxml">src/edu/stanford/covertlab/networkpainter/data/AboutData.mxml</a></li>
					<li>Edit PHP configuration file <a href="/bin/configuration.php">/bin/configuration.php</a></li>
				</ol></li>
			<li>Install AMPPHP services
				<ul>
					<li>NetworkPainter <a href="/amfphp/services/NetworkPainter/NetworkPainter.php">amfphp/services/NetworkPainter</a></li>
					<li>KEGG <a href="/amfphp/services/KEGG/KEGG.php">amfphp/services/KEGG</a></li>
				</ul></li>
			<li>Compile application <a href="/src/edu/stanford/covertlab/networkpainter/build.bat">/src/edu/stanford/covertlab/networkpainter/build.bat</a></li>
			<li>Run application <a href="/bin/NetworkPainter.swf">/bin/NetworkPainter.swf</a></li>
			<li>Edit source code using <a href="http://www.flashdevelop.org">FlashDevelop</a></li>
		</ol>
      <p/>
</body>	  
</html>	