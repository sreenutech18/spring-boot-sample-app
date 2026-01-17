# Use Eclipse Temurin JRE for production
FROM eclipse-temurin:17-jre-focal

# Set environment variables to prevent performance data issues
ENV JAVA_TOOL_OPTIONS="-XX:-UsePerfData -Djava.io.tmpdir=/tmp"

# Create non-root user for better security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Create app directory
WORKDIR /app

# Copy the JAR file from local target directory
COPY target/java-app-1.0.0.jar web-services.jar

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose app port
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "web-services.jar"]
