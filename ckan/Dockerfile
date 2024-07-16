FROM ckan/ckan-base:2.10.4

# Install any extensions needed by your CKAN instance
# See Dockerfile.dev for more details and examples

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

# Install pipx and ensure the path is set correctly
RUN python3 -m pip install --user pipx && \
    python3 -m pipx ensurepath && \
    source ~/.profile


# Add pipx to PATH
ENV PATH=/root/.local/bin:$PATH
RUN pipx install poetry

# Switch to the application directory and initialize poetry
WORKDIR ${APP_DIR}
RUN poetry init --no-interaction --name=ckan --description="CKAN project" --author="CKAN Team <team@ckan.org>" --dependency=flask@^2.0
