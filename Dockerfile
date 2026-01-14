FROM peaceiris/hugo:v0.145.0-full

WORKDIR /src

COPY . .

RUN hugo --minify

EXPOSE 1313

ENTRYPOINT ["/usr/local/bin/hugo"]

CMD ["server", "--bind", "0.0.0.0", "--port", "1313", "--baseURL", "http://localhost", "--watch=false"]