FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/app/dbt

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt

# Install dbt and related packages
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy dbt project files
COPY . /usr/app/dbt/

# Set environment variable for dbt profiles
ENV DBT_PROFILES_DIR=/usr/app/dbt

# Expose port for dbt docs
EXPOSE 8080

# Default command
CMD ["bash"]
