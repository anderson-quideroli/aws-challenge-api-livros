FROM  python:3.11.4-alpine
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY api_livros.py .
EXPOSE 8080
CMD ["python","./api_livros.py"]
