FROM python:3.11.4-alpine

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY api_livros.py .

# Variáveis de ambiente para Datadog APM
ENV DD_AGENT_HOST=datadog-agent
ENV DD_TRACE_AGENT_PORT=8126
ENV DD_ENV=production
ENV DD_SERVICE=api-livros
ENV DD_VERSION=1.0.0

EXPOSE 8080

# Inicia a aplicação com ddtrace-run para habilitar tracing automático
CMD ["ddtrace-run", "python", "./api_livros.py"]