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


