
/*** @author Mohamed El-Etreby <mohamed.a.el-etreby@ibm.com>* XSS and SQL injection*/
$CFG->task_scheduled_concurrency_limit = 20; // Defaults to 3
$CFG->task_adhoc_concurrency_limit = 50; // Defaults to 3
$CFG->task_concurrency_limit = [
    'core\task\course_backup_task' => 25,
    'core_course\task\course_delete_modules' => 5,
];
$CFG->forceclean = true;
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Missing HttpOnly Attribute in Cookie* HttpOnly attribute helps mitigate the risk of client side script accessing the protected cookie.*/
$CFG->cookiehttponly = true;
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Missing Secure Attribute in Encrypted Session (SSL) Cookie.* If server is accepting only https connections it is recommended to enable sending of secure cookies.*/
$CFG->cookiesecure= true;
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Clickjacking * Not allowing this website to be loaded in iframe in other websites*/
$CFG->allowframembedding = false;
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Session doesn't invalidate on password reset* Force other session to logout in case of password reset*/
$CFG->passwordchangelogout = true;
/*** @author Ahmed Abdulmajeed<ahmed.abdulmajeed@ibm.com>* Number of failed login attempts that result in account lockout.*/
$CFG->lockoutthreshold= 3;

/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Host Header Injection* validate whether the host header value is same as that of the domain serving the request*/
if (isset($_SERVER['HTTP_HOST']) && $_SERVER['HTTP_HOST'] != '' && $CFG->wwwroot != '' && strpos($CFG->wwwroot, $_SERVER['HTTP_HOST']) === false) {header('HTTP/1.0 403 Forbidden');die();}
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Cross-Site Request Forgery* validate that sesskey is not manipulated to avoid Cross-Site Request Forgery*/
if (isset($_REQUEST['sesskey']) && $_REQUEST['sesskey'] != '' && $_REQUEST['sesskey'] != sesskey()) {
    header('HTTP/1.0 403 Forbidden');die();
}
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Cross-Site Request Forgery* Check if Origin & Referer are setin header then their domain must beequal*/
if (isset($_SERVER['HTTP_REFERER']) && $_SERVER['HTTP_REFERER'] != '' && isset($_SERVER['HTTP_ORIGIN']) && $_SERVER['HTTP_ORIGIN'] != '') {
    $http_referer_domain = filter_var($_SERVER['HTTP_REFERER'], FILTER_VALIDATE_URL) !== FALSE ? parse_url($_SERVER['HTTP_REFERER'])['host'] : '';
    $http_origin_domain = filter_var($_SERVER['HTTP_ORIGIN'], FILTER_VALIDATE_URL) !== FALSE ? parse_url($_SERVER['HTTP_ORIGIN'])['host'] : '';
    if ($http_referer_domain != '' && $http_origin_domain != '' && $http_referer_domain != $http_origin_domain) {
        header('HTTP/1.0 403 Forbidden');die();
    }
}
/*** @author Mohamed Wafaa <mohamed.wafaa@ibm.com>* Validating that passed 'url' in parameter either exist in* $config_urls_whitelist OR $config_domains_whitelist*/
//create a list of allowed urls
$config_urls_whitelist = array($CFG->wwwroot,);
//create a list of allowed domains
$config_domains_whitelist = array(parse_url($CFG->wwwroot)['host']);
if (isset($_REQUEST['url']) && $_REQUEST['url'] != '') {
	//clear URL
	$url = clean_param($_REQUEST['url'], PARAM_URL);$_POST['url'] = isset($_POST['url']) ? clean_param($_POST['url'], PARAM_URL) : null;$_GET['url'] = isset($_GET['url']) ? clean_param($_GET['url'], PARAM_URL) : null;
	//validate if its actual url
	if (filter_var($url, FILTER_VALIDATE_URL) === FALSE) {$_REQUEST['url'] = null;$_POST['url'] = null;$_GET['url'] = null;
	//$url = false;}
	//if valid url passed
	if ($url) {
		//search for url in allowed urls
		$found_in_urls_whitelist = in_array($url, $config_urls_whitelist);
		//search for url in allowed urls
		$passed_domain = parse_url($url)['host'];
		$found_in_domains_whitelist = in_array($passed_domain, $config_domains_whitelist);
		//if url not found then remove it
		if (!$found_in_urls_whitelist && !$found_in_domains_whitelist) {
		    $_REQUEST['url'] = null;$_POST['url'] = null;$_GET['url'] = null;
        }
		}
	}
	}