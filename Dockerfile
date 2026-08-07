FROM golang:1.26.1 AS builder

WORKDIR /go/src/app
COPY . .
RUN go get
RUN make build

FROM scratch
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]