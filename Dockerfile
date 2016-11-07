FROM node:latest
MAINTAINER Ben Edmunds

# Environment variables mostly overridden from dockercompose or docker run
ENV HUBOT_SLACK_TOKEN xoxb-86458599122-dJtxMjdQgl7W22OcRIpalsSz
ENV HUBOT_NAME chatbot
ENV HUBOT_OWNER none
ENV HUBOT_DESCRIPTION Hubot
ENV EXTERNAL_SCRIPTS "hubot-help,hubot-pugme"

RUN useradd hubot -m

RUN     npm cache clean
RUN     npm install -g n
RUN     n stable
RUN     curl -L https://npmjs.org/install.sh | sh

RUN npm install -g hubot coffee-script yo generator-hubot && npm cache clear

RUN cd $(npm root -g)/npm && npm install fs-extra && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js

USER hubot

WORKDIR /home/hubot

RUN yo hubot --owner="${HUBOT_OWNER}" --name="${HUBOT_NAME}" --description="${HUBOT_DESCRIPTION}" --defaults && sed -i /redis-brain/d ./external-scripts.json && npm install hubot-scripts &&  npm install mysql && npm install hubot-slack --save

VOLUME ["/home/hubot/scripts"]

CMD node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && \
	npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))") && \
	bin/hubot -n $HUBOT_NAME --adapter slack
