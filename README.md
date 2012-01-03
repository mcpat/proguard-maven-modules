Maven modules of the ProGuard 4.7beta2beta1 release.
=========================================

For more information see http://proguard.sourceforge.net/

Pre-requisites
-----------
The artifact com.sun.kvem:kenv:2.2 is needed for compiling. This artifact is not available on Maven central and cannot be deployed given the Oracle policies.

Thus, you must add it manually to your local maven repository

 1. To install the WTK2.2 you must have a JDK1.4 or a JDK5 (for me, it doesn't work with the JDK6)
 2. Download and extract the [WTK 2.2](http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javame-419430.html#j2me_wireless_toolkit-2_2-oth-JPR)
 3. Install the needed artifact :
<pre><code> mvn install:install-file -DgroupId=com.sun.kvem -DartifactId=kenv -Dversion=2.2 -Dfile=WTK2.2/wtklib/kenv.zip -Dpackaging=jar -Dgenerate-pom=true</code></pre>