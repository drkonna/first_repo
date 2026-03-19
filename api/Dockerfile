# ── Build stage ──────────────────────────────────────────────────────────────
# Override PROJECT_NAME at build time: docker build --build-arg PROJECT_NAME=YourApi .
ARG PROJECT_NAME=MyApi

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore dependencies first (layer-cached)
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the source and publish
COPY . .
RUN dotnet publish -c Release -o /app/publish

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
ARG PROJECT_NAME=MyApi
WORKDIR /app

COPY --from=build /app/publish .

# Expose the HTTP port (HTTPS is handled by Nginx in dev)
EXPOSE 5000

ENTRYPOINT ["sh", "-c", "dotnet ${PROJECT_NAME}.dll"]
