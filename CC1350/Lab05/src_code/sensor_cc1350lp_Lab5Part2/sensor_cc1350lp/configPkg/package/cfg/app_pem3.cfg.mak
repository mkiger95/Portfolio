# invoke SourceDir generated makefile for app.pem3
app.pem3: .libraries,app.pem3
.libraries,app.pem3: package/cfg/app_pem3.xdl
	$(MAKE) -f C:\CCSWorkspace\ECG603\sensor_cc1350lp_Lab5Part2\Tools/src/makefile.libs

clean::
	$(MAKE) -f C:\CCSWorkspace\ECG603\sensor_cc1350lp_Lab5Part2\Tools/src/makefile.libs clean

