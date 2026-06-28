#!/bin/sh
# =============================================================
# Gera certificados SSL auto-assinados para desenvolvimento local
# Requer: openssl (disponível na maioria dos sistemas)
# =============================================================

CERT_DIR="$(dirname "$0")/../nginx/certs"

mkdir -p "$CERT_DIR"

echo "🔐 Gerando certificado SSL auto-assinado..."

openssl req -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout "$CERT_DIR/key.pem" \
  -out "$CERT_DIR/cert.pem" \
  -subj "/C=BR/ST=SP/L=SaoPaulo/O=Projeto/OU=Dev/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

echo "✅ Certificados gerados em $CERT_DIR"
echo "   cert.pem — certificado público"
echo "   key.pem  — chave privada"
echo ""
echo "⚠️  Este certificado é auto-assinado — o browser exibirá um aviso."
echo "   Para ambientes de produção, utilize Let's Encrypt ou outro CA confiável."
