<script src="jquery.js"></script>
<script type="text/javascript">

function setip (ip_remote) {
$.get(
"ajax.php",
    {
        ip_remote:ip_remote
    }
);

}
</script>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=koi8-r" />
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Cache-Control" content="max-age=1, must-revalidate" />
<title>Myserver stat</title>
</head>


<?php
    header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
    header("Last-Modified: " . gmdate("D, d M Y H:i:s")." GMT");
    header("Cache-Control: no-cache, must-revalidate");
    header("Cache-Control: post-check=0,pre-check=0", false);
    header("Cache-Control: max-age=0", false);
    header("Pragma: no-cache");

$client_url="http://".$_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"];
if (isset($_SERVER['REMOTE_ADDR'])){
        $ip_remote=$_SERVER['REMOTE_ADDR'];
}else{
        $ip_remote="";
}
    echo "<script>var a = '$ip_remote';setip(a);</script>";
?>

Уважаемый абонент!
Текст сообщения
Телефон для связи :

<form>
<input type="button" name="button" value="Перейти на целевую страницу" onClick='location.href="<?php echo $client_url; ?>"'>
</form>
