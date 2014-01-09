<?php
session_start();
echo '<?xml version="1.0" encoding="UTF-8"?>';
echo '<response isguest="'.($_SESSION['IS_GUEST']+0).'" userid="'.$_SESSION['USER_ID'].'"/>';
?>