ARG REGISTRY
ARG IMAGE
FROM $REGISTRY/$IMAGE
COPY cpr.sh partition.sh /
ENTRYPOINT ["./partition.sh"]

