FROM golang:1.18.3-bullseye AS golang

WORKDIR /demo

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o /tmp/demo-exe main.go

FROM gcr.io/distroless/base:latest
COPY --from=golang /tmp/demo-exe /demo-runner
ENTRYPOINT [ "/demo-runner"]CMD []