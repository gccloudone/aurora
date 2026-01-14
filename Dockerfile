FROM hugomods/hugo:0.145.0
WORKDIR /site
COPY . /site
CMD ["server", "--bind", "0.0.0.0"]