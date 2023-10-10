cd %~dp0

::Start frida-server.
start "" /b "adb" shell "su -c setsid /data/local/tmp/frida-server-16.1.4-android-x86_64"

::Instrument js code which will record constantly keylogs of SSL.
start "ssh-key-logging" /i frida -U -l .\sslkeylogging.js -f cn.damai -o .\keylog_test.txt

::Add path of termux to the env, in order to call 'tcpdump' for package capture.
start "tcp-dumping" /i "adb" shell "export PATH=/data/data/com.termux/files/usr/bin:$PATH & su -c tcpdump -i any -s 0 -w /data/local/tmp/tcp.pcap"

::Exit controll
@echo TCP dumping...
@echo Click any button if you want to stop dumping.
pause

::Kill process
taskkill /f /im adb.exe
taskkill /f /im frida.exe
