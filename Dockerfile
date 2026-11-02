FROM nginx:1.27-alpine
LABEL maintainer="capstone-lab"
RUN rm -rf /usr/share/nginx/html/*
COPY website/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
