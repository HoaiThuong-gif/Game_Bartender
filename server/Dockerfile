# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy server pubspec and resolve dependencies
COPY server/pubspec.* ./server/
RUN cd server && dart pub get

# Copy shared models and server code
COPY lib/ ./lib/
COPY server/ ./server/

# Compile the server AOT binary
WORKDIR /app/server
RUN dart compile exe bin/server.dart -o bin/server

# Minimal production runtime image (suitable for VPS)
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /app/bin/server

ENV PORT=8080
EXPOSE 8080
CMD ["/app/bin/server"]
