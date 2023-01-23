FROM ruby:3.1-bullseye

# 環境変数を利用しやすいため busybox の crond を利用する
RUN apt-get update && apt-get install busybox-static
RUN adduser --system --group diff_checker
RUN mkdir -p /var/spool/cron/crontabs
# 毎分 diff チェックを走らせる
RUN echo '* * * * * cd /app && rake check_diff' > /var/spool/cron/crontabs/diff_checker

USER diff_checker
COPY . /app
WORKDIR /app
RUN bundle install --without=test

# crond 自体は root で起動する必要があった
USER root
CMD ["busybox", "crond", "-f", "-L", "/dev/stderr"]
