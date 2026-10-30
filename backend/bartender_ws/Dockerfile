# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy server pubspec and resolve dependencies
COPY backend/bartender_ws/pubspec.* ./backend/bartender_ws/
RUN cd backend/bartender_ws && dart pub get

# Copy shared models and server code
COPY nhombar/lib/games/bartender/models/ ./nhombar/lib/games/bartender/models/
COPY nhombar/lib/games/bartender/bartender_config.dart ./nhombar/lib/games/bartender/bartender_config.dart
COPY backend/bartender_ws/ ./backend/bartender_ws/

# Compile the server AOT binary
WORKDIR /app/backend/bartender_ws
RUN dart compile exe bin/server.dart -o bin/server

# Minimal production runtime image (suitable for VPS)
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/backend/bartender_ws/bin/server /app/bin/server

ENV PORT=8080
EXPOSE 8080
CMD ["/app/bin/server"]
