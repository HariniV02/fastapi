# Use an official Python slim image for a lightweight environment
FROM python:3.12-slim-bullseye as base

# Set environment variables for improved performance and behavior
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /myapp

# Install system dependencies in one RUN command for efficiency
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev curl && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy only the requirements.txt file to leverage Docker cache
COPY ./requirements.txt /myapp/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy the rest of your application's code
COPY . /myapp

# Copy the startup script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Run the application as a non-root user for security
RUN useradd -m myuser
USER myuser

# Expose the port the FastAPI application will run on
EXPOSE 8000

# Define build arguments for environment variables (optional)
ARG QR_CODE_DIR=/myapp/qr_codes
ARG FILL_COLOR=red
ARG BACK_COLOR=white
ENV QR_CODE_DIR=${QR_CODE_DIR}
ENV FILL_COLOR=${FILL_COLOR}
ENV BACK_COLOR=${BACK_COLOR}

# Ensure the QR code directory exists with proper permissions
RUN mkdir -p $QR_CODE_DIR && chown -R myuser:myuser $QR_CODE_DIR

# Set the default command to run the application
CMD ["/start.sh"]
