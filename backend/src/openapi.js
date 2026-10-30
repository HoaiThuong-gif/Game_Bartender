'use strict';
const ref = name => ({ $ref: `#/components/schemas/${name}` });
const object = (properties, required = Object.keys(properties)) => ({ type: 'object', properties, required });
const str = { type: 'string' }, integer = { type: 'integer' }, boolean = { type: 'boolean' };
const dictionary = value => ({ type: 'object', additionalProperties: value });
const json = schema => ({ 'application/json': { schema } });
const schemas = {
  Error: object({ error: object({ message: str }) }),
  SessionRequest: object({ name: { type: 'string', minLength: 1, maxLength: 24, example: 'Thuong' } }),
  Session: object({ token: str, uid: str, name: str, expiresAt: integer, serverTime: integer }),
  Player: object({ name: str, ringIndex: integer, connected: boolean, completedOrders: integer, readyInLobby: boolean }, ['name', 'ringIndex', 'connected', 'completedOrders']),
  Item: object({ type: { type: 'string', enum: ['ingredient', 'product'] }, itemId: str, fromRingIndex: integer }),
  Order: object({ recipeId: str, status: { type: 'string', enum: ['pending', 'submitted'] } }),
  Recipe: object({ id: str, productId: str, difficulty: integer, stations: { type: 'array', items: str } }),
  BartenderRoom: object({
    status: { type: 'string', enum: ['lobby', 'playing', 'ended'] }, createdAt: integer,
    players: dictionary(ref('Player')), inbox: dictionary(dictionary(ref('Item'))),
    timer: object({ startedAt: integer, endTime: integer, preparing:boolean, readyPlayers:dictionary(boolean) }, ['startedAt','endTime']),
    round: object({ number: integer, ordersPerPlayer: integer, stationAssignment: dictionary({ type: 'string', nullable: true }), progress: dictionary(integer) }),
    orders: dictionary(dictionary(ref('Order'))),
    results: object({ totalSurvivalSeconds: integer, totalTeamOrders: integer, ranking: { type: 'array', items: { allOf: [ref('Player'), object({ playerId: str })] } } }),
  }, ['status', 'createdAt', 'players', 'inbox']),
  RubikPlayer: object({ name: str, ready: boolean, loaded: boolean, finished: boolean, dnf: boolean, rematch: boolean, left: boolean, finishAt: { ...integer, nullable:true }, finishMs: { ...integer, nullable:true } }, ['name', 'ready', 'loaded', 'finished', 'dnf', 'rematch', 'left']),
  RubikRoom: object({ hostId: str, creationId: str, createdAt: integer, updatedAt: integer, round: integer,
    status: { type: 'string', enum: ['waiting', 'ready', 'countdown', 'playing', 'finished'] },
    players: dictionary(ref('RubikPlayer')), scramble: { type: 'array', items: str }, startAt: { ...integer, nullable:true }, winnerId: { ...str, nullable:true }, endedAt: integer,
  }, ['hostId', 'createdAt', 'updatedAt', 'round', 'status', 'players']),
  Health: object({ status: str, serverTime: integer, storage: str }),
  Profile: object({ uid: { ...str, readOnly: true }, gameId: { ...str, readOnly: true },
    displayName: { ...str, description: 'Non-unique display name.' }, email: str, photoURL: str,
    createdAt: { readOnly:true, description:'Original creation timestamp; legacy formats are supported.', oneOf:[{type:'string',format:'date-time'},{type:'object'},{type:'integer'}] },
    schemaVersion: { ...integer, readOnly:true },
  }, ['uid', 'gameId', 'displayName']),
  Challenge: object({ challengeId: str, email: { ...str, description: 'Masked email address.' },
    expiresAt: { ...integer, description: 'Unix milliseconds; OTP expires after 10 minutes.' }, retryAt: integer }),
  Verification: object({ customToken: { ...str, description: 'Firebase custom token for signInWithCustomToken.' },
    grant: { ...str, description: 'Biometric grant; store in OS secure storage.' }, expiresAt: integer }),
};
for (const game of ['Bartender', 'Rubik']) schemas[`${game}Response`] = object({ code: str, room: { ...schemas[`${game}Room`], nullable: true }, serverTime: integer });
const paths = {};
function route(path, method, summary, tag, response, body, publicRoute = false, created = false) {
  const errorCodes = tag === 'System' ? [] : tag === 'Session' ? [400, 413]
    : tag === 'Account' ? [400, 401, 403, 405, 409, 413, 429, 503]
      : [400, 401, 403, 404, 405, 409, 413];
  const errorDescriptions = {
    400: 'Bad request', 401: 'Unauthorized', 403: 'Forbidden',
    404: 'Not found', 405: 'Method not allowed', 409: 'Conflict',
    413: 'Payload too large', 429: 'Too many requests',
    503: 'Account service unavailable',
  };
  const operation = {
    tags: [tag], summary, operationId: `${method}_${path.replace(/[^a-zA-Z0-9]+/g, '_')}`,
    responses: { [created ? '201' : '200']: { description: 'Success', content: json(response) },
      ...Object.fromEntries(errorCodes.map(status => [status, { description: errorDescriptions[status], content: json(ref('Error')) }])) },
  };
  if (publicRoute) operation.security = [];
  if (path.includes('{code}')) operation.parameters = [{ name: 'code', in: 'path', required: true, schema: { type: 'string', pattern: tag === 'Bartender' ? '^[0-9]{4}$' : '^[A-Z2-9]{6}$' }, description: 'Room code returned by the create endpoint.' }];
  if (body) operation.requestBody = { required: true, content: json(body) };
  (paths[path] ||= {})[method] = operation;
}
route('/api/v1/health', 'get', 'Get service health', 'System', ref('Health'), null, true);
route('/api/v1/sessions', 'post', 'Create game session (24 hours)', 'Session', ref('Session'), ref('SessionRequest'), true, true);
route('/api/v1/bartender/recipes', 'get', 'List recipes', 'Bartender', object({ recipes: { type: 'array', items: ref('Recipe') } }));
for (const [game, tag] of [['bartender', 'Bartender'], ['rubik', 'Rubik']]) {
  const base = `/api/v1/${game}/rooms`, response = ref(`${tag}Response`);
  route(base, 'post', 'Create room', tag, response, null, false, true);
  route(`${base}/{code}`, 'get', 'Get room and refresh presence', tag, response);
  paths[`${base}/{code}`].get.description = 'Poll every second. Presence expires after 30 seconds without a heartbeat.';
  route(`${base}/{code}/join`, 'post', 'Join room', tag, response);
  route(`${base}/{code}/presence`, 'post', 'Update presence', tag, response, object({ online: { type: 'boolean', example: true } }));
}
for (const [action, summary, body] of [
  ['start', 'Start match (at least 2 players)', object({ waitForScene: { type:'boolean', default:false } }, [])],
  ['prepared', 'Confirm scene readiness', object({ preparationId:integer })],
  ['return', 'Return to lobby', null],
  ['leave', 'Leave room', null],
  ['end', 'End match', null],
  ['send', 'Send item to adjacent player', object({ itemId: str, toRingIndex: integer })],
  ['trash', 'Discard item', object({ itemId: str })],
  ['process', 'Process item', object({ itemId: str, station: { type: 'string', enum: ['juicer', 'cuttingBoard', 'blender', 'shaker'] } })],
  ['submit', 'Submit order (adds 5 seconds)', object({ orderId: str, productId: { type: 'string', description: 'Inbox item UUID.' } })],
]) route(`/api/v1/bartender/rooms/{code}/${action}`, 'post', summary, 'Bartender', ref('BartenderResponse'), body);
route('/api/v1/rubik/rooms/{code}/commands', 'post', 'Submit round command', 'Rubik', ref('RubikResponse'), object({ action: { type: 'string', enum: ['ready', 'loaded', 'finish', 'leave', 'rematch', 'tick'], example: 'ready' }, round: { type: 'integer', minimum: 1, example: 1 } }));
for (const [action, method, summary, response, body] of [
  ['challenge', 'post', 'Send email OTP (5/hour; 60-second cooldown)', ref('Challenge'), object({})],
  ['verify', 'post', 'Verify OTP (5 attempts)', ref('Verification'), object({ challengeId: str, code: { type:'string',pattern:'^[0-9]{6}$',description:'Six-digit email OTP.' } })],
  ['session', 'get', 'Get verified account profile', ref('Profile'), null],
  ['cancel', 'post', 'Cancel OTP challenge', object({ ok: boolean }), object({ challengeId: str })],
  ['logout', 'post', 'Revoke current session', object({ ok: boolean }), object({})],
  ['resume', 'post', 'Resume biometric session', object({ customToken: str }), object({ grant: { ...str,minLength:64,maxLength:64 } })],
]) {
  const path = `/api/v1/account/${action}`;
  route(path,method,summary,'Account',response,body,action==='resume');
  paths[path][method].security = action==='resume' ? [] : [{firebaseAuth:[]}];
  paths[path][method].description = action==='resume'
    ? 'Requires a valid biometric grant.'
    : 'Requires a Firebase ID token; game session tokens are not accepted.';
}
module.exports = {
  openapi: '3.0.3', info: { title: 'Nhóm Bar API', version: '1.0.0' },
  servers: [{ url: '/', description: 'Current server' }],
  security: [{ bearerAuth: [] }], tags: ['System', 'Session', 'Account', 'Bartender', 'Rubik'].map(name => ({ name })),
  paths, components: { securitySchemes: {
    bearerAuth: { type: 'http', scheme: 'bearer', description: 'Game session token from POST /api/v1/sessions.' },
    firebaseAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT', description: 'Firebase ID token (JWT).' },
  }, schemas },
};
