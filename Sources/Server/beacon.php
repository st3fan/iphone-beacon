<?

/*
 * (C) Copyright 2010, Stefan Arentz, Arentz Consulting Inc.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

$hostname = 'localhost';
$username = 'root';
$password = '';
$database = 'beacon';

$VALID_PARAMETERS = array(
   'applicationIdentifier',
   'applicationVersion',
   'deviceIdentifier',
   'deviceModel',
   'deviceSystemVersion',
   'deviceJailbroken',
   'hardwareMachine',
   'hardwareModel'
);

$link = @mysql_connect($hostname, $username, $password);
if (is_resource($link))
{
   if (@mysql_select_db($database, $link))
   {
      $sql = sprintf("insert into signals (createDate,ip,%s) values (now(),'%s','%s','%s','%s','%s','%s','%s','%s','%s')",
         implode(",", $VALID_PARAMETERS),
         mysql_real_escape_string($_SERVER['REMOTE_ADDR']),
         mysql_real_escape_string($_GET['applicationIdentifier']),
         mysql_real_escape_string($_GET['applicationVersion']),
         mysql_real_escape_string($_GET['deviceIdentifier']),
         mysql_real_escape_string($_GET['deviceModel']),
         mysql_real_escape_string($_GET['deviceSystemVersion']),
         mysql_real_escape_string($_GET['deviceJailbroken']),
         mysql_real_escape_string($_GET['hardwareMachine']),
         mysql_real_escape_string($_GET['hardwareModel']));

      @mysql_query($sql, $link);
   }

   @mysql_close($link);
}

?>