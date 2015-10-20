default path was

Variable value:     C:\Python27;C:\Python27\Scripts



in Have a look by opening regedit, and checking the values of:

HKEY_CLASSES_ROOT\Python.File\shell\open\command
"C:\Python27\python.exe" "%1" %*
