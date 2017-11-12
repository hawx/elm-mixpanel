import test from 'ava';
import express from 'express';
import * as Elm from './project/main.js';
import { createServer } from 'http';

global.XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

const app = express();

const tracked = new Promise((resolve, reject) => {
  app.get('/track', (req, res) => {
    resolve(req.query);
    res.send('1');
  });
});

const server = createServer(app);

test.before(() => {
  return new Promise((resolve) => {
    server.listen(3000, function () {
      console.log('listening at :3000');
      resolve();
    });
  });
});

test(async t => {
  Elm.Main.worker({ url: 'http://localhost:3000', token: 'what', command: 'track' });

  const data = Buffer.from((await tracked).data, 'base64').toString('utf8');
  const obj = JSON.parse(data);

  t.deepEqual(obj, {event: 'game', properties: { token: 'what' }});
});

test.after(() => {
  server.close();
});
