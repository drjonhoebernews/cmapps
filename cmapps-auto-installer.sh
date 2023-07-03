#!/bin/bash
echo -e "\e[31mCMApps\e[0m"

echo -e "\e[32mBaşlıyorum Hazırmısın.\e[0m"
dnf udapte -y
echo -e "\e[32mSunucunu güncelliyorum.\e[0m"

echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1

echo -e "\e[32mNginx i kuruyorum.\e[0m"
# Nginx install
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mPhp81 i kuruyorum.\e[0m"
# PHP 8.1 and extensions install
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.1 -y
sudo dnf install php php-opcache php-gd php-curl php-mysqlnd -y

echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mFPM Ayarlarını yapıyorum.\e[0m"
# Update PHP-FPM configuration for Unix socket
sudo sed -i 's/listen = 127.0.0.1:9000/listen = \/run\/php-fpm\/www.sock/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sudo sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf

echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mFPM başlatıyorum.\e[0m"
# Enable and start PHP-FPM service
sudo systemctl enable php-fpm
sudo systemctl start php-fpm

# Install Composer and Laravel
echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mLaravel Projeni çekip sisteme kaydettiricem ve ayarlarını yapacam.\e[0m"
# shellcheck disable=SC2164
cd /var
mkdir www
# shellcheck disable=SC2164
cd /var/www
git pull https://github.com/HamzaTanik/API.git
sudo chown -R root:nginx /var/www/aPI
sudo chmod -R 755 /var/www/API
setenforce 0
sudo systemctl restart nginx
echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mDomain ayarlarını yapıyorum.\e[0m"
# Nginx server block configuration
# shellcheck disable=SC2016
echo 'server {
    listen 80;
    server_name expressbuchen.net www.expressbuchen.net;
    root /var/www/API/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}' | sudo tee /etc/nginx/conf.d/expressbuchen.net.conf

echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mNginx ve Firewall ayarlarını yapıyorum.\e[0m"

# Check the configuration file and restart Nginx
sudo nginx -t
sudo systemctl restart nginx

sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mSelinux Ayarlarını yapıyorum.\e[0m"
# SELinux configurations
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_unified 1
sudo chcon -R -t httpd_sys_rw_content_t /var/www/API

echo -e "\e[32m3.\e[0m"
sleep 1
echo -e "\e[32m2.\e[0m"
sleep 1
echo -e "\e[32m1.\e[0m"
sleep 1
echo -e "\e[32mve işlemleri bitirdim şimdi api.expressbuchen.net için SSL işlemlerini yapıyorum.\e[0m"

#!/bin/bash
echo -e "\e[32m1. Certbot ve Nginx plugin'inin yüklenmesi...\e[0m"
sudo dnf install certbot python3-certbot-nginx
echo -e "\e[32m2. SSL sertifikası oluşturma ve Nginx konfigürasyonunu güncelleme...\e[0m"
sudo certbot --nginx --non-interactive --agree-tos --email admin@expressbuchen.net -d api.expressbuchen.net
echo -e "\e[32m3. Sertifikanın doğru bir şekilde yenilendiğini doğrulama...\e[0m"
sudo certbot renew --dry-run
echo -e "\e[32mTüm işlemler başarıyla tamamlandı.\e[0m"

