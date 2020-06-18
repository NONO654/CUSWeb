import urllib2
import os, zipfile
import tempfile
import sys
import shutil, errno
import argparse

CKEDITOR_FULL_URL = 'http://download.cksource.com/CKEditor/CKEditor/CKEditor%204.2/ckeditor_4.2_full.zip'
FMATH_ONLY_PLUGIN = 'http://www.fmath.info/download/plugins/fmath_formula-only-plugin-CKEditor-v3.6.2-b1054.zip'
KAMA_SKIN = 'http://download.ckeditor.com/kama/releases/kama_4.2.2.zip'
ONCHANGE_PLUGIN = 'http://martinezdelizarrondo.com/ckplugins/onchange1.8.zip'


parser = argparse.ArgumentParser(description="""(Python 2.7 required) CKEditor script. 
This script allows you to install CKEditor for your ENOVIA local server automatically  
by downloading, unzipping, and copying a predifined set of plugins/options into your deployment directory.""", epilog="""Find a bug? Please contact T94.""")

ARGS = [['-path', 'CKEditor_path', 'XXX', 'The path to your ENOVIA deployment folder (for example "C:/enoviaV6R2014x\server\distrib\enovia"', True], 
				 ['--proxy_protocol', 'proxy_protocol', 'http', 'Your proxy protocol ("http" by default)', False],
				 ['--proxy_ip', 'proxy_ip', '10.6.7.50', """Your proxy IP ("10.6.7.50" by default).
															FYI: var AGProxy="PROXY 10.6.7.50:8080";
															     var APProxy="PROXY 10.5.133.50:8080";
                                                                 var EMEAProxy="PROXY 10.6.69.50:8080";'""", False],
				 ['--proxy_port', 'proxy_port', '8080', 'Your proxy port ("8080" by default)', False]]

for argument in ARGS:
	parser.add_argument(argument[0], dest=argument[1], default=argument[2], help=argument[3], required=argument[4])

result_args = vars(parser.parse_args())

### PARAMETERS ###
TARGET_FOLDER = result_args['CKEditor_path']
PROXY_PROTOCOL = result_args['proxy_protocol']
PROXY_IP = result_args['proxy_ip']
PROXY_PORT = result_args['proxy_port']
### PARAMETERS ###

##########################################################
############## DO NOT EDIT BELOW THIS LINE ###############
##########################################################

### Proxy support ###
proxy_support = urllib2.ProxyHandler({PROXY_PROTOCOL:PROXY_IP + ':' + PROXY_PORT})
proxy_opener = urllib2.build_opener(proxy_support)
urllib2.install_opener(proxy_opener)
### Proxy support ###

### TMP directory to save the files ###
TEMP_DIR_ALL_OS = tempfile.gettempdir() + '/CKEditorTmp'	
CKEDITOR_DIRECTORY = 'ckeditor'  

tmpTargetFolderToClean = os.path.join(TARGET_FOLDER, CKEDITOR_DIRECTORY)
if os.path.exists(tmpTargetFolderToClean):
	print 'Please remove the folder ' + tmpTargetFolderToClean + ' before running this script'
	print 'Press ENTER to exit...'
	raw_input()
	sys.exit()
	
if os.path.exists(TEMP_DIR_ALL_OS):
	print 'Cleaning the old temporary directory ' + TEMP_DIR_ALL_OS + '...'
	shutil.rmtree(TEMP_DIR_ALL_OS)
	
os.makedirs(TEMP_DIR_ALL_OS)
### TMP directory to save the files ###

### Download files ###
filesToDownload = [CKEDITOR_FULL_URL, FMATH_ONLY_PLUGIN, KAMA_SKIN, ONCHANGE_PLUGIN]

for currentFile in filesToDownload:
	file_name = currentFile.split('/')[-1]
	u = urllib2.urlopen(currentFile)
	f = open(TEMP_DIR_ALL_OS + '/' + file_name, 'wb')
	meta = u.info()
	file_size = int(meta.getheaders("Content-Length")[0])
	print "\t Downloading: %s Bytes: %s" % (file_name, file_size)

	file_size_dl = 0
	block_sz = 8192
	while True:
		buffer = u.read(block_sz)
		if not buffer:
			break

		file_size_dl += len(buffer)
		f.write(buffer)
		status = r"        %10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
		status = status + chr(8)*(len(status)+1)
		print status,

	f.close()
### Download files ###

### Extract files ###	
ZIP_EXTENSION = '.zip'	
zippedFiles = os.listdir(TEMP_DIR_ALL_OS)
unZippedFiles = []
for zippedFile in zippedFiles:
	if ZIP_EXTENSION in zippedFile:
		print '\t \t Unzipping ' + zippedFile
		newDirectoryForZipFile = zippedFile.replace(ZIP_EXTENSION, '')
		unZippedFiles.append(newDirectoryForZipFile)
		
		try:
			zFile = zipfile.ZipFile(os.path.join(TEMP_DIR_ALL_OS, zippedFile), 'r')
			zFile.extractall(TEMP_DIR_ALL_OS)
			zFile.close()
		except Exception:
			print 'Exception during extraction of ' + zippedFile
			# NOP
### Extract files ###	

### Copy files into ckeditor directory ###
CKEDITOR_PLUGINS_DIRECTORY = 'ckeditor/plugins'
CKEDITOR_SKINS_DIRECTORY = 'ckeditor/skins'
FMATH_DIRECTORY = 'fmath_formula'
DRAGRESIZE_DIRECTORY = 'dragresize'
LINK_DIRECTORY = 'link'
ONCHANGE_DIRECTORY = 'onchange'
KAMA_DIRECTORY = 'kama'
LICENCE_FILE = 'LICENCE.txt'
README_FILE = 'README.txt'

def copyAnything(src, dst):
    try:
        shutil.copytree(src, dst)
    except OSError as exc: # python > 2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise

if len(unZippedFiles) is not len(filesToDownload):
	print 'An issue happened during the extraction'
	sys.exit()

fMathOri = os.path.join(TEMP_DIR_ALL_OS, FMATH_DIRECTORY)
fMathDest = os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, FMATH_DIRECTORY)

onchangeOri = os.path.join(TEMP_DIR_ALL_OS, ONCHANGE_DIRECTORY)
onchangeDest = os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, ONCHANGE_DIRECTORY)

moonoOri = os.path.join(TEMP_DIR_ALL_OS, KAMA_DIRECTORY)
moonoDest = os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_SKINS_DIRECTORY, KAMA_DIRECTORY)

print '\t Copying ' + fMathOri
print '\t \t to ' + fMathDest
copyAnything(fMathOri, fMathDest)
print '\t Copying ' + onchangeOri
print '\t \t to ' + onchangeDest
copyAnything(onchangeOri, onchangeDest)
print '\t Copying ' + moonoOri 
print '\t \t to ' + moonoDest
copyAnything(moonoOri, moonoDest)
### Copy files into ckeditor directory ###

### Cleaning ###
shutil.rmtree(fMathOri)
shutil.rmtree(onchangeOri)
shutil.rmtree(moonoOri)
os.remove(os.path.join(TEMP_DIR_ALL_OS, LICENCE_FILE))
os.remove(os.path.join(TEMP_DIR_ALL_OS, README_FILE))
for zippedFile in zippedFiles:
	os.remove(TEMP_DIR_ALL_OS + '/' + zippedFile)
# Because in the Python world EAFP (it's easier to ask forgiveness than permission) is preferred to LBYL (look before you leap). 

scriptDir = os.path.dirname(os.path.abspath(__file__))
print '\n\tCopying custom ckeditor/config.js'
shutil.copy(os.path.join(scriptDir, 'installResources/config.js'), os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_DIRECTORY, 'config.js'))
print '\tCopying custom ' + os.path.join(CKEDITOR_PLUGINS_DIRECTORY, FMATH_DIRECTORY, 'dialogs/configMathMLEditor.xml')
shutil.copy(os.path.join(scriptDir, 'installResources/fmath_formula/configMathMLEditor.xml'), os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, FMATH_DIRECTORY, 'dialogs/configMathMLEditor.xml'))
print '\tCopying custom ' + os.path.join(CKEDITOR_PLUGINS_DIRECTORY, FMATH_DIRECTORY, 'dialogs/editor.html')
shutil.copy(os.path.join(scriptDir, 'installResources/fmath_formula/editor.html'), os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, FMATH_DIRECTORY, 'dialogs/editor.html'))
print '\tCopying custom ' + os.path.join(CKEDITOR_PLUGINS_DIRECTORY, LINK_DIRECTORY, 'dialogs/link.js')
shutil.copy(os.path.join(scriptDir, 'installResources/link.js'), os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, LINK_DIRECTORY, 'dialogs/link.js'))
	
print '\tCopying '  + os.path.join(scriptDir, 'installResources', DRAGRESIZE_DIRECTORY)
print '\t \t to ' + os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, DRAGRESIZE_DIRECTORY)
shutil.copytree(os.path.join(scriptDir, 'installResources', DRAGRESIZE_DIRECTORY), os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_PLUGINS_DIRECTORY, DRAGRESIZE_DIRECTORY))

tmpPathOri = os.path.join(TEMP_DIR_ALL_OS, CKEDITOR_DIRECTORY)
tmpPathDest = os.path.join(TARGET_FOLDER, CKEDITOR_DIRECTORY)

try:
	shutil.rmtree(tmpPathDest) # Clean the old folder
except Exception:
	pass
	
print '\tCopying ' + tmpPathOri
print '\t \t to ' + tmpPathDest
copyAnything(tmpPathOri, tmpPathDest)

##########################################################
############## DO NOT EDIT ABOVE THIS LINE ###############
##########################################################

print 'Press ENTER to continue...'
raw_input()



