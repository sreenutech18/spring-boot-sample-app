#Define your base image 
FROM eclipse-temurin:17-jdk-focal 
ENV JAVA_TOOL_OPTIONS="-XX:-UsePerfData -Djava.io.tmpdir=/tmp"

# Create non-root user for better security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Create app directory
WORKDIR /app

#Maintainer of this image
LABEL maintainer="sreenu" 

#Copying Jar file from target folder                                                                                       
COPY target/java-app-1.0.0.jar web-services.jar 

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

#Expose app to outer world on this port                                                                                                                                                                                                                                                                          
EXPOSE 8081   

#Run executable with this command  
ENTRYPOINT ["java", "-jar", "web-services.jar"]
