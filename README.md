## Tiny Web Application (PHP only) based on php-fpm ( or php-fpm-alpine, depends on tag ). 
###PHP extensions which are needed for composer already installed:
    - phar
    - json
    - curl
    - iconv
    - interbase
    - curl
    - pdo
    - pdo_firebird
    - ctype
    
If your project demand more than these, just modify **PHP_MODULES** variable

####Simple instance:
#####tty is necessary 
```` docker run -d -t -e PHP_MODULES=modules -v /path/to/data:/you/want/bind/````
