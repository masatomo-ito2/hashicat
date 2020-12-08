#!/usr/bin/env bash

set -x
exec > >(tee /tmp/tf-user-data.log|logger -t hashicat ) 2>&1

logger() {
	DT=$(date '+%Y/%m/%d %H:%M:%S')
	echo "$DT $0: $1"
}
	
sudo add-apt-repository universe
sudo apt -y update
sudo apt -y install apache2
sudo systemctl start apache2
sudo chown -R ubuntu:ubuntu /var/www/html

echo "Generating a site"

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://${PLACEHOLDER}/${WIDTH}/${HEIGHT}"></img></center>
  <center><h2>Meow World!</h2></center>
  Welcome to ${PREFIX}'s app. WELCOME TO THE WORKSHOP!
  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "Script complete."
