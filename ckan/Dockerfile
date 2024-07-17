FROM ckan/ckan-base:2.10.4

# Install any extensions needed by your CKAN instance
# See Dockerfile.dev for more details and examples
# Install necessary dependencies
RUN apk add --no-cache \
    gcc \
    libffi-dev \
    openssl-dev \
    python3-dev \
    make \
    musl-dev \
    linux-headers
# Set working directory
WORKDIR ${APP_DIR}

# Copy the requirements.txt file
ADD requirements.txt ${APP_DIR}
ADD force-requirements.txt ${APP_DIR}

# Install the Python packages using pip
RUN pip install -r requirements.txt
RUN pip install --no-cache-dir -r force-requirements.txt

# Copy custom initialization scripts
COPY docker-entrypoint.d/* /docker-entrypoint.d/

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY patches ${APP_DIR}/patches

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done



