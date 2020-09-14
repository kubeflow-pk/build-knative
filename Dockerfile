FROM golang:1.14 as builder
WORKDIR /go/src/knative.dev/serving
COPY . .
RUN go mod vendor
RUN GO111MODULE=on go build -o /bin/activator cmd/activator/*.go
RUN GO111MODULE=on go build -o /bin/autoscaler-hpa cmd/autoscaler-hpa/*.go
RUN GO111MODULE=on go build -o /bin/autoscaler cmd/autoscaler/*.go
RUN GO111MODULE=on go build -o /bin/controller cmd/controller/*.go
RUN GO111MODULE=on go build -o /bin/networking-nscert cmd/networking/nscert/*.go
RUN GO111MODULE=on go build -o /bin/webhook cmd/webhook/*.go
RUN GO111MODULE=on go build -o /bin/queue cmd/queue/*.go
RUN GO111MODULE=on go build -o /bin/default-domain cmd/default-domain/*.go

FROM alpine:3.12 as activator
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/activator /bin
CMD ["activator"]

FROM alpine:3.12 as autoscaler-hpa
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/autoscaler-hpa /bin
CMD ["autoscaler-hpa"]

FROM alpine:3.12 as autoscaler
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/autoscaler /bin
CMD ["autoscaler"]

FROM alpine:3.12 as controller
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/controller /bin
CMD ["controller"]

FROM alpine:3.12 as networking-nscert
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/networking-nscert /bin
CMD ["networking-nscert"]

FROM alpine:3.12 as webhook
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/webhook /bin
CMD ["webhook"]

FROM alpine:3.12 as queue
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/queue /bin
CMD ["queue"]

FROM alpine:3.12 as default-domain
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/default-domain /bin
CMD ["default-domain"]

FROM alpine:3.12
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/activator /bin/autoscaler-hpa /bin/autoscaler /bin/networking-nscert /bin/queue /bin/default-domain /bin/webhook /bin
