cd %~dp0

::Start frida-server.
adb shell "su -c setsid /data/local/tmp/frida-server-16.1.4-android-x86_64"

::Instrument js code which will record constantly keylogs of SSL.
start "ssh-key-logging" /i frida -U -l .\sslkeylogging.js -f cn.damai -o .\keylog.txt

::Add path of termux to the env, in order to call 'tcpdump' for package capture.
start "tcp-dumping" /i "adb" shell "export PATH=/data/data/com.termux/files/usr/bin:$PATH & su -c tcpdump -i any -s 0 -w /data/local/tmp/tcp.pcap"

::Exit controll
@echo TCP dumping...
@echo Click any button if you want to stop dumping.
pause

::Kill tcpdump in Android
%or pkill -f -9 tcpdump%
for /f "delims=" %%t in ('adb shell "ps -ef |grep tcpdump |grep -v grep |awk '{print $2}'"') do set TCPDUMP_PID=%%t
@echo "Kill tcpdump - %TCPDUMP_PID%"
adb shell "ps -ef|grep tcpdump| grep -v grep|awk '{print $2}'|su -c xargs kill -9"

::Kill process
call taskkill /f /im adb.exe
call taskkill /f /im frida.exe

pause