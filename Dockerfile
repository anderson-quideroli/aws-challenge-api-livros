FROM python:3.11.4-alpine

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY api_livros.py .

EXPOSE 8080

# Não defina ENV fixos aqui, pois o ECS já injeta via task definition!
# O entrypoint será sobrescrito pela task definition, então mantenha o padrão:
CMD ["python", "./api_livros.py"]