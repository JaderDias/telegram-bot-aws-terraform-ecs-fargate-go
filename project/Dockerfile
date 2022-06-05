FROM golang:1.18.3-bullseye AS golang

WORKDIR /

COPY go.mod go.sum sh.csv ./
RUN go mod download
COPY . .

RUN go build -o /demo-runner main.go
ENTRYPOINT [ "/demo-runner" ]CMD []