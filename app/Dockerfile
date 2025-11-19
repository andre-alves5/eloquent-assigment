FROM python:3.12-slim AS builder

WORKDIR /app

RUN groupadd -g 1000 appuser && useradd -u 1000 -g appuser -m -s /bin/bash appuser

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY --chown=1000:1000 . .
RUN chown -R 1000:1000 /install

FROM gcr.io/distroless/python3.12

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app /app

USER 1000

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/uvicorn" ]
CMD [ "app:app", "--host", "0.0.0.0", "--port", "8080"]
