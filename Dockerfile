FROM kong:3.6

COPY kong.yml /usr/local/kong/declarative/kong.yml

EXPOSE 8000 8443 8001 8444

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD curl -fs http://localhost:8001/status || exit 1

ENTRYPOINT ["kong", "start", "-v", "--conf", "/etc/kong/kong.conf.default", \
           "--declare", "/usr/local/kong/declarative/kong.yml"]
