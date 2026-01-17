# Use Eclipse Temurin JRE for production
FROM eclipse-temurin:17-jre-focal

# Set environment variables to prevent performance data issues
ENV JAVA_TOOL_OPTIONS="-XX:-UsePerfData -Djava.io.tmpdir=/app/tmp -XX:+UnlockExperimentalVMOptions"

# Create non-root user for better security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Create app directory and custom temp directory
WORKDIR /app
RUN mkdir -p /app/tmp && chown -R appuser:appuser /app

# Copy the JAR file from local target directory
COPY --chown=appuser:appuser target/java-app-1.0.0.jar web-services.jar

# Switch to non-root user
USER appuser

# Expose app port
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "web-services.jar"]
