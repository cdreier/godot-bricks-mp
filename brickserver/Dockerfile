FROM alpine

RUN mkdir /app
ADD brickserver /app
WORKDIR /app

EXPOSE 8080

CMD [ "./brickserver" ]