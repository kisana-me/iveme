FROM ruby:4.0.1
RUN apt-get update && apt-get install -y build-essential imagemagick libvips
COPY ./imagemagick/policy.xml /etc/ImageMagick-6/policy.xml
RUN gem i -v 8.1.1 rails
