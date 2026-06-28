FROM nginx:1.25-alpine

# Remove configuração padrão
RUN rm /etc/nginx/conf.d/default.conf

# Copia a configuração do reverse proxy
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
