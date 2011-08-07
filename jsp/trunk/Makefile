

all: package

package:
	mvn package

run:
	mvn jetty:run

clean:
	mvn clean

libs:
	mvn install:install-file \
		-Dfile=lib/flickrapi-1.2.jar \
		-DgroupId=com.aetrion.flickr \
		-DartifactId=flickrapi \
		-Dversion=1.2 \
		-Dpackaging=jar
# http://maestric.com/doc/java/spring/setup
