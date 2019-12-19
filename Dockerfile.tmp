FROM ruby:2-slim

ARG USER_HOME_DIR="/root"
LABEL maintainer="Tibor Digaňa"
WORKDIR ${USER_HOME_DIR:-/root}

ADD . .
#ADD ./src/main/ruby/checksums/PrintDeepFilestructuresMD5.rb ${USER_HOME_DIR:-/root}/src/main/ruby/checksums/
#ADD ./src/test/ruby/**/*.txt ${USER_HOME_DIR:-/root}/src/test/ruby/
#ADD ./src/test/ruby/assets/subdir/* ${USER_HOME_DIR:-/root}/src/test/ruby/assets/subdir/

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["ruby -v /root/src/main/ruby/checksums/PrintDeepFilestructuresMD5.rb /root/src/test/ruby/assets *\\.txt"]
