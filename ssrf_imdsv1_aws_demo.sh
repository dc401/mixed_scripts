#!/bin/bash
#add this to instance user data
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum install httpd -y
amazon-linux-extras enable php7.4
yum clean metadata
yum install php -y
systemctl stop httpd
echo '<?php phpinfo(); ?>' > /tmp/phpinfo.php
wget -O /tmp/ssrf_html.php 'https://raw.githubusercontent.com/dc401/mixed_scripts/master/ssrf_html.php'
cp /tmp/phpinfo.php /var/www/html/
cp /tmp/ssrf_html.php /var/www/html/
systemctl start httpd
