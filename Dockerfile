FROM quay.io/projectquay/golang:1.26 AS builder

ARG VERSION=dev

WORKDIR /go/src/app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Tests and compilation run natively for the Docker daemon platform.
RUN go test ./... && \
    CGO_ENABLED=0 go build -trimpath \
      -ldflags "-s -w -X=github.com/visys-dev/kbot/cmd.appVersion=${VERSION}" \
      -o /out/kbot .

FROM scratch
COPY --from=builder /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /out/kbot /kbot
ENTRYPOINT ["/kbot"]
