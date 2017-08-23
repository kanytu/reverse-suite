Reverse Suite for Linux
=============

```bash
# ./rsuite.sh -h
  _____                                 _____       _ _       
 |  __ \                               / ____|     (_) |      
 | |__) |_____   _____ _ __ ___  ___  | (___  _   _ _| |_ ___ 
 |  _  // _ \ \ / / _ \ '__/ __|/ _ \  \___ \| | | | | __/ _ \ 
 | | \ \  __/\ V /  __/ |  \__ \  __/  ____) | |_| | | ||  __/
 |_|  \_\___| \_/ \___|_|  |___/\___| |_____/ \__,_|_|\__\___|
                                                                                                                            
./rsuite.sh <options>, where <options> are:

     -h                        what you are looking at
     -d <file.apk>,            disassemble the apk (convert to smali)
     -l,                       shows the name of the applications already disassembled
     -b <application_name>,    build the provided application as an apk (use with -o)
     -n,                       optimize images during build
     -x <file.apk>,            decompile the apk, and run luyten to verify the source code
     -o <file.apk>,            the name of apk that gets written (use with -b)
```

**Version of used tools:**

 - [**apktool** - v2.2.4](https://github.com/iBotPeaches/Apktool)
 - [**dex2jar** - 2.1-SNAPSHOT](https://github.com/pxb1988/dex2jar)
 - [**jd-gui** -  1.4.0](https://github.com/java-decompiler/jd-gui)
 - [**luyten** - 0.5.3](https://github.com/deathmarine/Luyten)
