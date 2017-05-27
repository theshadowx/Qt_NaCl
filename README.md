# Qt NaCl 
![travis ci status QtNaCl](https://travis-ci.org/theshadowx/Qt_NaCl.svg?branch=master)

This repository is dedicated to compilation of [Qt](https://www.qt.io/) with [Chrome Native Client (NaCl)](https://developer.chrome.com/native-client). 
You can either use Dockerfile to generate a Docker image or the script to compile the Qt in the host machine.

This repository is linked to the Docker Hub, thus you can pull directly the image from it --> https://hub.docker.com/r/theshadowx/qt_nacl/

## From script

In your terminal:

```
$> chmod +x /path/to/QtNaCl.sh
$> /path/to/QtNaCl.sh
```
If everything goes well, the folder, from where you launched the script, will have these folders :
- nacl_sdk    : Chrome Native Client SDK
- Qt5.6          : Qt 5.6 source files
- QtNaCl_56 : Compiled Qt with NaCl (containing qmake, nacldeployqt ...)

### Usage
_**To prevent problems, it's better to use the generated binaries' full path.**_

**Generate Makefile** : 
```
$> /path/to/QtNaCl_56/qtbase/bin/qmake /path/to/pro_file
```
**Compile** : 
```
$> make
```
**Deploy** :  
```
$> /path/to/QtNaCl_56/qtbase/bin/nacldeployqt <target.bc> --run 
```

------

## From Dockerfile
To be able to use the Dockerfile, make sure you have [Docker](https://www.docker.com/) installed.

### Build the image
```
$> Docker build -t qt_nacl /path/to/Dockerfile
```
you 'll find your image by : 
```
$> Docker images
```
| REPOSITORY | TAG                 | IMAGE ID                | CREATED        | SIZE                  |
|---------------------|---------------------|----------------------------|----------------------|----------------------|
| qt_nacl | latest | \<IMAGE ID\> | \<Time Duration from time it was created\> | \<size of the image\> |

### Usage
#### Generate Makefile
```
docker run --rm -it -v /path/to/project:/path/to/project/in/container -w=/path/to/project/in/container qt_nacl:latest /opt/QtNaCl_56/qtbase/bin/qmake
```
#### Compile
```
docker run --rm -it -v /path/to/project:/path/to/project/in/container -w=/path/to/project/in/container qt_nacl:latest make
```
#### Deploy
```
docker run --rm -it -p 8000:8000 -v /path/to/project:/path/to/project/in/container -w=/path/to/project/in/container qt_nacl:latest /opt/QtNaCl_56/qtbase/bin/nacldeployqt <target.bc or target.nexe> --run
```
Open the Chrome browser and use the address : **http://172.17.0.1:8000**

Normally you'll get your app shown in the browser (after some seconds to load everything)

### Alternative
Instead of building Dockerfile yourself, you can use the image from [Docker Hub ](https://hub.docker.com/r/theshadowx/qt_nacl/).
To do so, you'll need just the pull the image
```
docker pull theshadowx/qt_nacl
```
Then just use it as it was mentioned in the previous section but this time instead of  **qt_nacl:latest** it should be **theshadowx/qt_nacl:latest**

-----
## N.B.
In order you app to work with Qt+NaCl you should modify the main function, here are some examples you can reference to : https://github.com/msorvig/qt-nacl-manualtests